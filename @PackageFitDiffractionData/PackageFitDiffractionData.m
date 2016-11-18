
classdef PackageFitDiffractionData < matlab.mixin.Copyable
    %classdef PackageFitDiffractionData < matlab.mixin.Copyable
    %   PackageFitDiffractionData Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Filename = '';	 % Cell array of name of files
        two_theta = [];	% array of full two_theta values from file
        data_fit = [];	% array of original data. Each row is intensity data from a file
        fitrange = 0.3;
        fit_parms = {};	% list of cells containing coeffvalues from the fit
        fit_parms_error = {};	 % list of cells containing coeffvalues error
        fit_results = {};
        fit_initial=[];	 % list of cells containing SP, UB, and LB
        PeakPositions % Array of peak positions
        PolyOrder = 3; % Polynomial order of background fit
        Min2T
        Max2T
        PSfxn % function names of fit; length must be equal to PeakPositions
        Fdata %  First row is two_theta, 2nd is background, 3:end are individual peaks
        Fmodel % cfit object array generated by MATLAB fit function
        Fcoeff % coefficient names;
        Constrains = [0 0 0 0]; % variable constrains for fit equations
        DisplayName = '';
        
    end
    
    properties (SetObservable)
        Status = '';
    end
    
    properties(Hidden)
        FmodelGOF
        FmodelCI
        suffix   = '';
        symdata =0;
        original_SP=[];
        azim = [0:15:345];
        binID = [1:1:24];
        lambda = 1.5405980;
        CuKa=false;
        level = 0.95;
        OutputPath = 'FitOutputs/';
        SPR_Chi % TODO to be implemented in GUI in the future
        SPR_Angle % TODO to be implemented in GUI in the future
        SPR_Data % TODO to be implemented in GUI in the future
        numAzim
        bkgd2th
        DataPath = '';
        skiplines = 0;
        recycle_results = 0;
    end
    
    methods
        function Stro = PackageFitDiffractionData(fname, path)
            if nargin ==2
                Stro.Read_Data(fname, path);
            end
        end
        
        function a = hasData(Stro)
            if ~isempty(Stro.Filename)
                a = true;
            else
                a = false;
            end
        end
        
        function npeaks = nPeaks(Stro)
            npeaks = length(Stro.PSfxn);
        end
        
        function coeff=getCoeff(Stro,fxn,constraints)
            coeff='';
            
            if nargin < 3
                constraints = Stro.Constrains;
            end
            if nargin < 2
                fxn = Stro.PSfxn;
            end
            
            if constraints(1); coeff=[coeff,{'N'}]; end
            if constraints(2); coeff=[coeff,{'f'}]; end
            if constraints(3); coeff=[coeff,{'w'}]; end
            if constraints(4); coeff=[coeff,{'m'}]; end
            
            for i=1:length(fxn)
                coeffNames = '';
                N = ['N' num2str(i)];
                xv = ['x' num2str(i)];
                f = ['f' num2str(i)];
                m = ['m' num2str(i)];
                w = ['w' num2str(i)];
                NL=['N',num2str(i),'L'];
                mL=['m',num2str(i),'L'];
                NR=['N',num2str(i),'R'];
                mR=['m',num2str(i),'R'];
                
                switch fxn{i}
                    case 'Gaussian'
                        if ~constraints(1); coeffNames = [coeffNames, {N}]; end
                        coeffNames = [coeffNames, {xv}];
                        if ~constraints(2); coeffNames = [coeffNames, {f}]; end
                        
                    case 'Lorentzian'
                        if ~constraints(1); coeffNames = [coeffNames, {N}]; end
                        coeffNames = [coeffNames, {xv}];
                        if ~constraints(2); coeffNames = [coeffNames, {f}]; end
                        
                    case 'Psuedo Voigt'
                        if ~constraints(1); coeffNames = [coeffNames, {N}]; end
                        coeffNames = [coeffNames, {xv}];
                        if ~constraints(2); coeffNames = [coeffNames, {f}]; end
                        if ~constraints(3); coeffNames = [coeffNames, {w}]; end
                        
                    case 'Pearson VII'
                        if ~constraints(1); coeffNames = [coeffNames, {N}]; end
                        coeffNames = [coeffNames, {xv}];
                        if ~constraints(2); coeffNames = [coeffNames, {f}]; end
                        if ~constraints(4); coeffNames = [coeffNames, {m}]; end
                        
                    case 'Asymmetric Pearson VII'
                        if ~constraints(1); coeffNames=[coeffNames,{NL},{NR}]; end
                        coeffNames=[coeffNames,{xv}];
                        if ~constraints(2); coeffNames=[coeffNames,{f}]; end
                        if ~constraints(4); coeffNames=[coeffNames,{mL},{mR}];end
                end
                coeff=[coeff,coeffNames];
                
            end
            
        end
        
        % Returns the background points and their indices.
        function [pts, ptsIndex] = getBkgdPoints(Stro)
            if isempty(Stro.bkgd2th)
                pts = [];
                ptsIndex = [];
                return
            end
            
            pts = Stro.bkgd2th;
            
            if nargout>1
               for i=1:length(pts)
                   ptsIndex(i) = PackageFitDiffractionData.Find2theta(Stro.two_theta, pts(i)); 
               end
            end
        end
        
        function data = getRawData(Stro,file,fitrange)
            mid = mean([Stro.Min2T Stro.Max2T]);
            leftbound = mid-fitrange/2;
            rightbound = mid+fitrange/2;
            if leftbound < Stro.Min2T
                leftbound = Stro.Min2T;
            end
            if leftbound > Stro.Max2T
                rightbound = Stro.Max2T;
            end
            
            datainMin = PackageFitDiffractionData.Find2theta(Stro.two_theta,leftbound);
            datainMax = PackageFitDiffractionData.Find2theta(Stro.two_theta,rightbound);
            
            
            data = Stro.data_fit(:,datainMin:datainMax); %Extract relevant 2theta region
            TwT = Stro.two_theta(datainMin:datainMax); %Extract relevant 2theta region
            
            %create arbitrary axis for plotting of data
            arb = 1:1:size(Stro.data_fit,1); %here
            
            TwTgridsum=TwT;
            Arbgridsum=arb;
            fitrange2T = fitrange;
            
            datasent = [TwT' data(file,:)']';
            for ii=1:size(Stro.PeakPositions,1) %Change to number of steps (instead of 2theta)
                p = mean(Stro.PeakPositions(ii,:));
                fitrangeL = PackageFitDiffractionData.Find2theta(datasent(1,:),p-fitrange2T(ii)/2);
                fitrangeH = PackageFitDiffractionData.Find2theta(datasent(1,:),p+fitrange2T(ii)/2);
                drangeH = fitrangeH-PackageFitDiffractionData.Find2theta(datasent(1,:),p);
                drangeL = PackageFitDiffractionData.Find2theta(datasent(1,:),p)-fitrangeL;
                if drangeL > drangeH
                    fitrange(ii) = drangeH * 2;
                elseif drangeH > drangeL
                    fitrange(ii) = drangeL * 2;
                else
                    fitrange(ii) = fitrangeH-fitrangeL;
                end
            end
            % 			Stro.fitrange = fitrange;
            data = datasent;
        end
        
    end
    
    methods(Static)
        function [P, S, U] = fitBkgd(data, bkgd2th, polyorder)
            % BACKGROUND FITTING
            R = 1; %in points each direction for the background averaging, must be integer
            for i=1:length(bkgd2th)
                bkgd2thX(i)=PackageFitDiffractionData.Find2theta(data(1,:),bkgd2th(i));
            end;
            
            for i=1:length(bkgd2th)
                if bkgd2thX(i) <= 1
                    bkgd2thX(i) = 2;
                elseif bkgd2thX(i) >= length(data)
                    bkgd2thX(i) = length(data) - 1;
                end
                bkgdInt(i)=mean(data(2,(bkgd2thX(i)-R:bkgd2thX(i)+R)));
            end
            % Added by Klarissa to  get rid of centering and scaling warning
            [P, S, U] = polyfit(bkgd2th,bkgdInt, polyorder);
            
          hold on
          plot(bkgd2th,bkgdInt,'ro','MarkerSize',6,'LineWidth',1.5, 'MarkerFaceColor','auto');
          hold off
            
        end
        
        
        function Exceptions(number)
            if number == 0
                disp('Please enter the initial and final file numbers')
            elseif number == 1
                disp('The fileformat you have entered is not supported.')
                disp('This program can read csv, txt, xy, fxye, dat, xrdml, chi, and spr files')
            elseif number == 2
                disp('File to read is not defined')
            end
        end
        
        function [c4] = C4(m)
            c4=2*((2^(1/m)-1)^0.5)/(pi^0.5)*gamma(m)/gamma(m-0.5);
        end
        
        function arrayposition=Find2theta(data,value2theta)
            % function arrayposition=Find2theta(data,value2theta)
            % Finds the nearest position in a vector
            % MUST be a single array of 2theta values only (most common error)
            
            if nargin~=2
                error('Incorrect number of arguments')
                arrayposition=0;
            else
                test = find(data >= value2theta);
                if isempty(test);
                    arrayposition = length(data)-1;
                else
                    arrayposition = test(1);
                end
            end
        end
        
        function position2=Ka2fromKa1(position1)
            if nargin==0
                error('Incorrect number of arguments')
            elseif ~isreal(position1)
                warning('Imaginary parts of INPUT ignored')
                position1 = real(position1);
            end
            
            lambda1 = 1.540598; %Ka1
            lambda2 = 1.544426; %Ka2
            position2 = 180 / pi * (2*asin(lambda2/lambda1*sin(pi / 180 * (position1/2))));
        end
        
        function [Y] = AsymmCutoff(x, side, xdata)
            
            numPts=length(xdata);
            
            if side == 1
                for i=1:numPts;
                    if xdata(i) < x;
                        step(i)=1;
                    else
                        step(i)=0;
                    end
                end
            elseif side == 2
                for i=1:numPts;
                    if xdata(i) < x;
                        step(i)=0;
                    else
                        step(i)=1;
                    end
                end
            end
            
            Y=step';
        end
        
    end
end