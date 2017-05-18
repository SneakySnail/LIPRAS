classdef FileWriter < handle
%FILEWRITER writes output files of the fit results for PackageFitDiffractionData.
   properties
       OutputPath
       
   end
   
   properties (Hidden)
       Profiles
   end
   
   properties (Constant, Hidden)
       DEFAULT_OUTPUT_PATH = ['FitOutputs' filesep];
   end
   
   
   methods 
       function this1 = FileWriter(profiles)
       this1.Profiles = profiles;
       this1.OutputPath = profiles.OutputPath;
       if exist(this1.OutputPath, 'dir') ~= 7
           mkdir(this1.OutputPath);
       end
       fitoutpath = [this1.OutputPath 'FitData' filesep];
       if exist(fitoutpath, 'dir') ~= 7
           mkdir(fitoutpath);
       end
       end
   end 
   
   methods
       function printFitOutputs(this, fits)
       %PRINTFILEOUTPUTS prints the results of the fit for each file in a .Fdata, .Fmodel, and the
       %    master .Fmodel file.
       if ~iscell(fits)
           fits = {fits};
       end
       profnum = this.Profiles.getCurrentProfileNumber;
       if this.Profiles.xrd.UniqueSave
              index = 0;
            iprefix = '00';
            while exist(strcat(this.OutputPath,'Fit_',strcat(iprefix,num2str(index))),'dir') ==7
                index = index + 1;
                if index > 100
                    iprefix = '';
                elseif index > 10
                    iprefix = '0';
                end
            end
            outpath=strcat(this.OutputPath,'Fit_',strcat(iprefix,num2str(index)), filesep);  
            mkdir(outpath)
       else
            outpath = [this.OutputPath 'FitData' filesep];
            if exist(outpath,'dir')==0 % incase user deletes this folder
                mkdir(outpath)
            end
       end
      
       masterfilename = [outpath fits{1}.FileName '_Master_Profile_' '.Fmodel'];
       fidmaster = fopen(masterfilename, 'w');
       this.printFmodelHeader(fits{1}, fidmaster);
       
       for i=1:length(fits)
           filename = [fits{i}.FileName '_Profile_' num2str(profnum)];
           
    % For individual Fmodels, activate this section
%            fmodelfilename = [outpath filename '.Fmodel'];
%            fidmodel = fopen(fmodelfilename, 'w');
%            this.printFmodelHeader(fits{i}, fidmodel);
%            this.printFmodelValues(fits{i}, fidmodel);
%            fclose(fidmodel);
           
           fdatafilename = [outpath filename '.Fdata'];
           fiddata = fopen(fdatafilename, 'w');
           this.printFdata(fits{i}, fiddata);
           fclose(fiddata);
           
           this.printFmodelValues(fits{i}, fidmaster);
       end
       fclose(fidmaster);
       end
       
       function saveAsFitParameters(this, fits)
       fitted = fits{1};
       fullfile = this.getFullFileName(fitted.OutputPath, fitted.FileName, 'Parameters', '.txt');
       fid = fopen(fullfile,'w');
       this.printFitParameters(fits, fid);
       fclose(fid);
       
       [~, filename, ext] = fileparts(fullfile);
       msg = ['Fit parameters were successfully saved as the file ' filename ext '.'];
       msgbox(msg, 'Saved')
       end
       
       function str = getFullFileName(this, outpath, fitname, varargin)
       % If FILENAME already exists, append it with ' (n)' where n is the number of files with the
       % name FILENAME that already exists.
       %
       %FITNAME is the name of the file that was fitted. 
       %
       %VARARGIN must have at least 1 element, where the last element is the extension to the file.
       str = [outpath fitname];
       for i=1:length(varargin)-1
           str = [str '_' varargin{i}]; %#ok<AGROW>
       end
       ext = varargin{end};
       
            index = 0;
            iprefix = '00';
       while exist(strcat(str,'_',strcat(iprefix,num2str(index)),'.txt'),'file') ==2
                index = index + 1;
                if index > 100
                    iprefix = '';
                elseif index > 10
                    iprefix = '0';
                end
        end
            str=[strcat(str,'_',strcat(iprefix,num2str(index))) ext];  
       
       end
       
   end
   
   methods (Static)
       function printFitParameters(fits, fid)
       %SAVEPARAMETERSTOFILE 
       fitted = fits{1};
       fprintf(fid, '2ThetaRange: %.5f %.5f\n\n',fitted.TwoTheta(1), fitted.TwoTheta(end));
       fprintf(fid, 'BackgroundModel: %s\n', fitted.BackgroundModel);
       fprintf(fid, 'PolynomialOrder: %i\n', fitted.BackgroundOrder);
       fprintf(fid, 'BackgroundPoints:');
       fprintf(fid, ' %f', fitted.BackgroundPoints);
       if ~isempty(fitted.KAlpha1)
           fprintf(fid, '\nCu-KAlpha1: %f\n', fitted.KAlpha1);
       else
           fprintf(fid, '\nCu-KAlpha1: n/a\n');
       end
       if fitted.CuKa
           fprintf(fid, 'Cu-KAlpha2: %f\n', fitted.KAlpha2);
       else
           fprintf(fid, '\nCu-KAlpha2: n/a\n');
       end
       
       fprintf(fid,'\nFitFunction(s):\n');
       fprintf(fid,'%s; ', fitted.FunctionNames{:});
       fprintf(fid,'\nConstraints:');
       fprintf(fid, ' {''%s''}', fitted.Constraints{:});
       fprintf(fid, '\nPeakPosition(s): ');
       fprintf(fid, '%f ', fitted.PeakPositions);
       if any(contains(fitted.CoeffNames, 'bkg'))  
          id=max(1:fitted.BackgroundOrder+2); % so that bkg coefficients dont get written to output parameter file
          bkgc=1;
       else
           id=1; % should not trigger unless bkg was not refined
           bkgc=0;
       end
       fprintf(fid, '\n\n== Initial Fit Parameters ==\n');
       fprintf(fid, '%s ', fitted.CoeffNames{id:end}); %write coefficient names
       fprintf(fid, '\nSP: ');
       fprintf(fid, '%#.5f ', fitted.FitOptions.StartPoint(id:end));
       fprintf(fid, '\nLB: ');
       if isempty(fitted.FitOptions.Lower) % when No Bounds was checked
       fprintf(fid, '%#.5f ', (fitted.CoeffValues(id:end)-5*fitted.CoeffError(id:end)));
       fprintf(fid, '\nUB: ');
       fprintf(fid, '%#.5f ', (fitted.CoeffValues(id:end)+5*fitted.CoeffError(id:end)));   
       else
       fprintf(fid, '%#.5f ', fitted.FitOptions.Lower(id:end));
       fprintf(fid, '\nUB: ');
       fprintf(fid, '%#.5f ', fitted.FitOptions.Upper(id:end));
       end
       
       if bkgc
       fprintf(fid, '\n\n== Bkg Coeffs ==\n');
       fprintf(fid,'SP: ');
       fprintf(fid, '%#.5f ', fitted.FitOptions.StartPoint(1:id-1));
       end
       
       end
        
       function printFmodelValues(fitted, fid)
       

           fprintf(fid, '%s\t',fitted.FileName);
       
       if any(contains(fitted.CoeffNames, 'bkg'))  
          id=max(1:fitted.BackgroundOrder+2); % so that bkg coefficients dont get written to output parameter file
       else
           id=1; % should not trigger unless bkg was not refined
       end
       
       % print coeffvalues of Fmodel
       for i=1:length(fitted.CoeffValues(id:end))
           fprintf(fid, '%.5f\t%.5f\t', fitted.CoeffValues(id+i-1), fitted.CoeffError(id+i-1));
       end
       % print FmodelGOF
       fprintf(fid, '%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t%.5f\t', fitted.FmodelGOF.sse, ...
           fitted.FmodelGOF.rsquare, fitted.FmodelGOF.dfe, fitted.FmodelGOF.adjrsquare, ...
           fitted.FmodelGOF.rmse,fitted.Rp,fitted.Rwp,fitted.Rchi2);
       fprintf(fid, '\n');
       end
       
       function printFmodelHeader(fitted, fid)
       fprintf(fid, 'This is an output file from a MATLAB routine.\n');
       fprintf(fid, 'The following peaks are all of the type: ');
       fprintf(fid, '%s; ', fitted.FunctionNames{:});     
       fprintf(fid, '\n\n');
       
        if any(contains(fitted.CoeffNames, 'bkg'))  
          id=max(1:fitted.BackgroundOrder+2); % so that bkg coefficients dont get written to output parameter file
       else
           id=1; % should not trigger unless bkg was not refined
       end
       
       % Write column headers in the order: 
       %    FileName, N1, N1_Error, x1, x1_Error, (more coeffs)..., sse, rsquare, dfe, adjrsquare, rmse
       fprintf(fid, 'FileName\t');
       for i=1:length(fitted.CoeffValues(id:end))
           fprintf(fid, '%s\t%s\t', fitted.CoeffNames{id+i-1}, [fitted.CoeffNames{id+i-1} '_Error']);
       end
       fields = fieldnames(fitted.FmodelGOF);
       fields{end+1}='%Rp';
       fields{end+1}='%Rwp';
       fields{end+1}='RChi2';

       fprintf(fid, '%s\t', fields{:}); % write GOF names
       fprintf(fid, '\n');
       end
       
       function printFdata(fitted, fid)
       %PRINTFDATAFILES prints the results of the fit specified by FITTED to a file.
       fprintf(fid, 'This is an output file from a MATLAB routine.\n');
       fprintf(fid, 'All single peak data (column 3+) does not include background intensity.\n\n');
       nPeaks=size(fitted.FPeaks,1);
        for p=1:nPeaks
                vars{:,p}=strcat(' Peak',num2str(p), ' \t');
        end
                    if fitted.CuKa && ~isempty(fitted.FCuKa2Peaks) % this is for Kalpha2
                        vars{:,p+1}=strcat('Kalpha2...',' \t');                   
                    end
        t='2theta \t Obs \t Calc \t BkgdFit \t';
        nw=strcat(t,[vars{:}],' \n');
       fprintf(fid, nw);
       
       twotheta = fitted.TwoTheta';
       intmeas = fitted.Intensity';
       calc=fitted.FData;
       background = fitted.Background';  
                       if fitted.CuKa && ~isempty(fitted.FCuKa2Peaks)
                            peaks=[fitted.FPeaks' fitted.FCuKa2Peaks']; % combines the matrixes together to write to FData
                       else
                            peaks=fitted.FPeaks';
                       end
       for i=1:length(twotheta)
           line = [twotheta(i), intmeas(i), calc(i), background(i), peaks(i,:)];
           fprintf(fid, '%2.5f\t', line(:));
           fprintf(fid, '\n');
       end
       end
       
   end

end