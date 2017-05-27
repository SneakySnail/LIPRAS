classdef FitResults
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        FileName        % Name used when printing out to a file

        ProfileNum 
        
        FunctionNames

        Fmodel
        
        FmodelGOF
        
        LSWeights
        
        Rp
        
        Rwp
        
        Rchi2
        
        FitInfo
        
        FmodelCI

        CovJacobianFit
        
        CoeffNames

        CoeffValues

        CoeffError

        TwoTheta

        Background      % Background fit

        FitInitial      % Struct with fields 'start', 'lower', and 'upper'

        FData           % Numeric array result after fitting TwoTheta with Fmodel

        FPeaks          % Numeric array result of each function's fits
        
        FCuKa2Peaks     % Empty if no Cu-Ka2 
    end
    
    properties
        CuKa = false;
        
        KAlpha1
        
        KAlpha2
    end
    
    
    properties (Hidden) % Because they were used for getting the fit
        BackgroundModel
        
        BackgroundOrder
        
        BackgroundPoints
        
        Intensity       % Raw data
        
        PeakPositions
        
        Constraints
        
        FitOptions
        
        OutputPath

        FitType
        FitFunctions
        CuKa2Functions
    end

properties (Access = protected)
%     FitType
%     FitFunctions

end

properties (Constant)
CONFIDENCE_LEVEL = 0.95;
end
    
    methods
        function this = FitResults(profile, filenumber)
        %FITRESULTS constructor for fitting the data. It saves the fit results and also the fit
        %   parameters that were used.
        %
        %   
        if profile.CuKa
            this.CuKa = true;
            this.CuKa2Functions = profile.xrd.CuKa2Peak;
            this.KAlpha1 = profile.xrd.KAlpha1;
            this.KAlpha2 = profile.xrd.KAlpha2;
        end
        xrd = profile.xrd;
        this.FileName      = strrep(xrd.getFileNames{filenumber}, '.', '_');
        this.ProfileNum    = profile.getCurrentProfileNumber;
        this.OutputPath    = profile.OutputPath;
        this.FunctionNames = xrd.getFunctionNames;
        this.TwoTheta      = xrd.getTwoTheta;
        this.Intensity     = xrd.getData(filenumber);
        if xrd.BkgLS
        else
        this.Background    = xrd.calculateBackground(filenumber);
        end
        this.BackgroundOrder = xrd.getBackgroundOrder;
        this.BackgroundModel = xrd.getBackgroundModel;
        this.BackgroundPoints = xrd.getBackgroundPoints;
        this.PeakPositions = xrd.PeakPositions;
        this.Constraints = xrd.getConstraints;
        this.FitType       = xrd.getFitType;
        
        if and(filenumber>1,xrd.recycle_results==1)
            this.FitOptions    = xrd.getFitOptions(filenumber);
        elseif filenumber==1 && xrd.BkgLS && xrd.recycle_results
            xrd.recycle_results=0;
            this.FitOptions    = xrd.getFitOptions(filenumber);
            xrd.recycle_results=1;
        else
        this.FitOptions    = xrd.getFitOptions(filenumber);
        end
        
        if strcmp(profile.Weights,'Default')
            if ~isempty(profile.Errors)
                this.FitOptions.Weights=1./(xrd.DataSet{filenumber}.getDataErrors).^2; % default to 1/sigma^2 when errors are read in or generated upon file read
            else
                this.FitOptions.Weights=1./xrd.DataSet{filenumber}.getDataIntensity;
            end
        end
        this.CoeffNames    = coeffnames(this.FitType)';
        this.FitFunctions  = xrd.getFunctions;
        
        if xrd.BkgLS && ~isempty(xrd.BkgCoeff) && filenumber==1 % handling bkgCoeff refined and how they cycle after being refined
            if length(xrd.BkgCoeff)==this.BackgroundOrder+1           % when BkgOrder is switched after a refined bkg has been done    
            this.FitOptions.StartPoint(1:this.BackgroundOrder+1)=xrd.BkgCoeff;            
            end
            
        elseif xrd.BkgLS && ~isempty(xrd.BkgCoeff) && this.BackgroundOrder+1<length(xrd.BkgCoeff) && filenumber==1
            disp('Bkg Order less than Bkg coefficients stored')
        elseif xrd.BkgLS && xrd.recycle_results && ~isempty(xrd.BkgCoeff)
            %Nothing keep it rolling
        end
%         disp(this.FitOptions.StartPoint) % to check SP being recycled

        if xrd.BkgLS
                    [fmodel, fmodelgof, outputMatrix] = fit(this.TwoTheta', ...
                                 (this.Intensity)', ...
                                  this.FitType, this.FitOptions);
        else
        [fmodel, fmodelgof, outputMatrix] = fit(this.TwoTheta', ...
                                 (this.Intensity - this.Background)', ...
                                  this.FitType, this.FitOptions);
        end
        fmodelci = confint(fmodel, this.CONFIDENCE_LEVEL);
        
        this.Fmodel    = fmodel;
        this.FmodelGOF = fmodelgof;
        this.FmodelCI  = fmodelci;
        this.LSWeights=this.FitOptions.Weights;
        this.FitInfo=outputMatrix;
%         this.CovJacobianFit=(this.FitInfo.Jacobian'*this.FitInfo.Jacobian)^(-1)*this.FmodelGOF.rmse^2;
        this.FData       = fmodel(this.TwoTheta)';
        this.FPeaks      = zeros(length(xrd.getFunctions),length(this.FData));
        this.FCuKa2Peaks = zeros(length(xrd.getFunctions),length(this.FData));
        this.CoeffValues = coeffvalues(fmodel);
        this.CoeffError  = 0.5 * (fmodelci(2,:) - fmodelci(1,:));
        
% Rp, Rwp, and Rchi2 Calculations
  obs=this.Intensity';
  w=this.LSWeights';

    if any(contains(this.CoeffNames,'bkg')) % for when BkgLS is checked
        calc=this.FData'; 
        DOF = this.FmodelGOF.dfe; % degrees of freedom from error
        er=transpose(xrd.DataSet{filenumber}.getDataErrors);
        
        this.Rp = (sum(abs(obs-calc))./(sum(obs))) * 100; %calculates Rp
        this.Rwp = sqrt(sum(((obs-calc)./er).^2)./sum(obs.^2./er.^2))*100 ; %Calculate Rwp
        if strcmp(profile.Weights,'None')
         this.Rchi2=sum((obs-calc).^2./obs)/DOF;   
        else
        this. Rchi2= this.FmodelGOF.sse/DOF; % true Red-Chi^2
        end
    else
        obs = this.Intensity';
        calc = this.Background' + this.FData';        
        DOF = this.FmodelGOF.dfe; % degrees of freedom from error
        er=transpose(xrd.DataSet{filenumber}.getDataErrors);
        
        this.Rp = (sum(abs(obs-calc))./(sum(obs))) * 100; %calculates Rp
        this.Rwp = sqrt(sum(((obs-calc)./er).^2)./sum(obs.^2./er.^2))*100 ; %Calculate Rwp
        if strcmp(profile.Weights,'None')
         this.Rchi2=sum((obs-calc).^2./obs)/DOF;   
        else
        this. Rchi2= this.FmodelGOF.sse/DOF; % true Red-Chi^2
        end
    end

        for i=1:length(this.FitFunctions)
             peak = this.calculatePeakFit(i);
             this.FPeaks(i,:) = peak(1,:);
            if this.CuKa
                this.FCuKa2Peaks(i,:) = peak(2,:);
            end
        end
        
        if and(filenumber>1,xrd.recycle_results==1)
        xrd.FitInitial.start=this.CoeffValues;
        elseif filenumber==1 && xrd.BkgLS && xrd.recycle_results
            xrd.FitInitial.start = this.CoeffValues;
        else
        this.FitInitial.start = this.FitOptions.StartPoint;
        end
            
        if xrd.BkgLS % evaluates Poly Bkg based on refined Bkg Coefficients
            this.CoeffValues(1,1:this.BackgroundOrder+1)=fliplr(this.CoeffValues(1,1:this.BackgroundOrder+1));
           this.Background=polyval(this.CoeffValues(1,1:this.BackgroundOrder+1), this.TwoTheta); 
        else
        end
        this.FitInitial.coeffs = this.CoeffNames;
        this.FitInitial.lower = this.FitOptions.Lower;
        this.FitInitial.upper = this.FitOptions.Upper;
        end
        
        function output = calculateFitNoBackground(this, fcnID)
        %CALCULATEFIT returns an array 
        output = this.FData;
        end

        function output = calculateError(this)
        output = this.FData - this.Intensity;
        end

        function output = calculatePeakFit(this, fcnID)
        % calculatePeakFit  
        twotheta = this.TwoTheta;
        fcnCoeffNames = this.FitFunctions{fcnID}.getCoeffs;
        idx = zeros(1,length(fcnCoeffNames));
        for i=1:length(fcnCoeffNames)
            idx(i) = find(strcmpi(this.CoeffNames, fcnCoeffNames{i}),1);
        end
        coeffvals = this.CoeffValues(idx);
        output = this.FitFunctions{fcnID}.calculateFit(twotheta, coeffvals);
        if this.CuKa
            output(2,:) = this.CuKa2Functions{fcnID}.calculateFit(twotheta,coeffvals);
        end
        end
        end
end

