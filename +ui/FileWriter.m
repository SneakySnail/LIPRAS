classdef FileWriter < handle
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
       function this = FileWriter(profiles)
       this.Profiles = profiles;
       this.OutputPath = profiles.OutputPath;
       end
   end 
   
   methods
       
       function this = saveAsMasterFile(this, fits)
       %SAVEASMASTERFILE
       %
       %    FITS - Cell array of FitResult objects to save.
       profile = model.ProfileListManager.getInstance;
       if nargin < 3
           filename = [this.OutputPath fits{1}.FileName '_Master_Profile_' num2str(profile.getCurrentProfileNumber) ...
                       '.Fmodel'];
       end

       fid = fopen(filename, 'w');
       fprintf(fid, 'This is an output file from a MATLAB routine.\n');
       fprintf(fid, 'The following peaks are all of the type: ');
       fprintf(fid, '%s; ', fits{1}.FunctionNames{:});
       fprintf(fid, '\n');
       fprintf(fid, '%s ', fits{1}.CoeffNames{:});
       fprintf(fid, '\n');
       
       GOFnames = fieldnames(fits{1}.FmodelGOF)';
       fprintf(fid, '%s\t', GOFnames{:});
       
       for i=1:length(fits{1}.CoeffNames)
           fprintf(fid, '%s\t', ['LowCI:' fits{1}.CoeffNames{i}]);
           fprintf(fid, '%s\t', ['UppCI:' fits{1}.CoeffNames{i}]);
       end

       for i=1:length(fits)
           printMasterFile(fits{i}, fid);
       end
       
       fclose(fid);
       end
       
       function filename = saveAsParametersFile(this)
       %SAVEPARAMETERSTOFILE 
       %
       %FILENAME
       
       if ~exist(this.OutputPath, 'dir')
           mkdir(this.OutputPath);
       end
       profiles = this.Profiles;
       fits = profiles.xrd.getFitResults;
       fitted = fits{1};
       
       filename = this.getFileName(['Fit_Parameters_' fitted.FileName], '.txt');
       
       %the name of the file it will write containing the statistics of the fit
       fid = fopen(filename, 'w'); 
       
       
       fprintf(fid, 'Filenames: ');
       fprintf(fid, '%s ', profiles.getFileNames{:});
       fprintf(fid, '\n\n');
       
       fprintf(fid, '2ThetaRange: %f %f\n\n',fitted.TwoTheta(1), fitted.TwoTheta(end));
       fprintf(fid, 'BackgroundModel: %s\n', fitted.BackgroundModel);
       fprintf(fid, 'PolynomialOrder: %i\n', fitted.BackgroundOrder);
       fprintf(fid, 'BackgroundPoints:');
       fprintf(fid, ' %f', fitted.BackgroundPoints);
       
       fprintf(fid,'\n\nFitFunction(s):\n');
       fprintf(fid,'%s; ', fitted.FunctionNames{:});
       fprintf(fid,'\nConstraints:');
       fprintf(fid, ' {''%s''}', fitted.Constraints{:});
       fprintf(fid, '\nPeakPosition(s): ');
       fprintf(fid, '%f ', fitted.PeakPositions);
       
       
       
       fprintf(fid, '\n\n== Initial Fit Parameters ==\n');
       fprintf(fid, '%s ', fitted.CoeffNames{:}); %write coefficient names
       fprintf(fid, '\nSP: ');
       fprintf(fid, '%#.5g ', fitted.FitOptions.StartPoint);
       fprintf(fid, '\nLB: ');
       fprintf(fid, '%#.5g ', fitted.FitOptions.Lower);
       fprintf(fid, '\nUB: ');
       fprintf(fid, '%#.5g ', fitted.FitOptions.Upper);
       
       fclose(fid);
       end
       
       function output = getFileName(this, name, ext)
       % mode = type of file output
       % mode = 'Fit_Parameters_', 'Master', 
       profiles = this.Profiles;
       fits = this.Profiles.xrd.getFitResults;
       if nargin < 3
           ext = '';
       end
       
        outFilePrefix = [this.OutputPath, name, '_'];
       
       if length(fits) > 1
           outFilePrefix = [outFilePrefix 'Series_'];
       end
       
       index = 0;
       iprefix = '00';
       profileNumber = profiles.getCurrentProfileNumber;
       outFileSuffix = ['_Profile_', num2str(profileNumber), ext];
       filename = [outFilePrefix, iprefix, num2str(index), outFileSuffix];
       while exist(filename, 'file') == 2
           index = index + 1;
           if index > 100
               iprefix = '';
           elseif index > 10
               iprefix = '0';
           end
           filename = [outFilePrefix, iprefix, num2str(index), outFileSuffix];
       end
       
       output = filename;
       end
       
       function printFmodelFiles(this, fits)
       profilenumber = this.Profiles.getCurrentProfileNumber;
       if ~iscell(fits)
           fits = {fits};
       end
       for i=1:length(fits)
           filename = [this.OutputPath fits{i}.FileName '_Profile_' num2str(profilenumber) '_' ...
                       'file_' num2str(i) '.Fmodel'];
           fid = fopen(filename, 'w');
           printFmodelFile(fits{i}, fid);
           fclose(fid);
       end
       end

       function printFdataFiles(this, fits)
       %PRINTFDATAFILES prints the results of the fit to a file.
       if ~exist(this.OutputPath, 'dir')
           mkdir(this.OutputPath);
       end
       for i=1:length(fits)
           filename = this.getFileName(fits{i}.FileName, '.Fdata');
           fid = fopen(filename, 'w');
           printFdataFile(fits{i}, fid);
           fclose(fid);
       end
       end

   end
   
   methods (Static)

       
   end
   
    
end