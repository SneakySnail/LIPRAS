classdef ProfileListManager < handle
    %PROFILELISTMANAGER Maintains a list of PackageFitDiffractionData objects.
    %   Only a single instance is allowed. To get the handle to the currently
    %   existing ProfileListManager instance, call the static method
    %   ProfileListManager.getInstance.
   properties
       FileNames 
       
       NumFiles = 0;
       
       DataPath = [];
       
       OutputPath = ['FitOutputs' filesep];
       
       FitResults % each profile results in a cell
       
   end
   
   properties (Dependent)
       ActiveProfile
       
       xrd
       
       CuKa
       
       KAlpha1 = 1.540598; % nm
       KAlpha2 = 1.544426; % nm
   end
   
   properties (Hidden)
       ext % file type for this dataset
       FullTwoThetaRange
       FullIntensityData
       Temperature
       
       kBeta
       RKa1Ka2
       
       ValidFunctions = {'Gaussian', 'Lorentzian', 'Pearson VII', 'Pseudo-Voigt', 'Asymmetric Pearson VII'};
       
       xrdContainer
       
       initialXRD_
       
       Writer
              
      CurrentProfileNumber_ = 0;
      
   end
   
   
   methods (Access = private)
       function this = ProfileListManager()
       this.xrdContainer = [];
       end
   end
   
   methods
       function isNew = newXRD(this, path, filename)
       isNew = false;
       if nargin < 2
           [data, filename, path] = utils.fileutils.newDataSet(this.DataPath);
           if isempty(data)
               return
           end
       else % if xrd was already created, just save as the new xrd
           data = utils.fileutils.newDataSet(path,filename);
       end
       isNew = true;
       this.reset();
       this.initialXRD_ = PackageFitDiffractionData(data, filename);
       this.initialXRD_.DataPath = path;
       this.ext = data(1).ext;
       
       xrdItem = this.initialXRD_;
       this.FullTwoThetaRange = xrdItem.getTwoTheta;
       this.DataPath = xrdItem.DataPath;
       xrdItem.OutputPath = [xrdItem.DataPath 'FitOutputs' filesep];
       this.FileNames = xrdItem.getFileNames;
       this.NumFiles = length(this.FileNames);
       this.OutputPath = xrdItem.OutputPath;
       this.addProfile;
       this.Writer = ui.FileWriter(this);
       
       if strcmpi(this.ext, '.xrdml')
           this.Temperature = {data.Temperature};
           this.KAlpha1 = data(1).KAlpha1;
           this.KAlpha2 = data(1).KAlpha2;
           this.kBeta = data(1).kBeta;
           this.RKa1Ka2 = data(1).RKa1Ka2;
           this.CuKa = true;
       else
           this.CuKa = false;
       end
       end
       
       function set.CuKa(this, value)
       this.xrd.CuKa = value;
      
       end
       
       function val = get.CuKa(this)
       val = this.xrd.CuKa;
       end
       
       function set.KAlpha1(this, value)
       if ~isempty(this.xrd)
           this.xrd.KAlpha1 = value;
       end
       end
       
       function val = get.KAlpha1(this)
       val = [];
       if ~isempty(this.xrd)
           val = this.xrd.KAlpha1;
       end
       end
       
       function set.KAlpha2(this, value)
       if ~isempty(this.xrd)
           this.xrd.KAlpha2 = value;
       end
       end
       
       function val = get.KAlpha2(this)
       val = [];
       if ~isempty(this.xrd)
           val = this.xrd.KAlpha2;
       end
       end
       function set.ActiveProfile(this, number)
       if number < 1
           this.CurrentProfileNumber_ = 1;
       elseif number > this.getNumProfiles
           this.CurrentProfileNumber_ = this.getNumProfiles;
       else
           this.CurrentProfileNumber_ = number;
       end
       end
       
       function number = get.ActiveProfile(this)
       number = this.CurrentProfileNumber_;
       end
       
       function this = addProfile(this)
       %ADDPROFILE Adds a profile to the GUI.
       if ~isempty(this.xrdContainer)
           this.xrdContainer(end+1) = copy(this.initialXRD_);
       else
           this.xrdContainer = copy(this.initialXRD_);
       end
       this.CurrentProfileNumber_ = length(this.xrdContainer);
       end
        
       function this = deleteProfile(this, id) 
        % Make sure profiles are in bounds
        if id > this.getNumProfiles || id < 0
            error(message('LIPRAS:ProfileListManager:InvalidProfile'))
        end
        this.xrdContainer(id) = [];
        this.CurrentProfileNumber_ = this.CurrentProfileNumber_ - 1;
       end
       
       function this = reset(this)
       this.xrdContainer = [];
       this.CurrentProfileNumber_ = 0;
       this.NumFiles = 0;
       this.Writer = [];
       end
       
       function output = hasData(this)
        if isempty(this.xrdContainer)
            output = false;
        else
            output = true;
        end
       end 
       
       function a = hasFit(this)
        if isempty(this.FitResults) || isempty(this.FitResults{this.getCurrentProfileNumber})
            a = false;
        else
            a = true;
        end
        end
       
       function this = setCurrentProfileNumber(this, id)
       % Check if within bounds
       if id < 1
           this.CurrentProfileNumber_ = 1;
       elseif id > this.getNumProfiles
           this.CurrentProfileNumber_ = this.getNumProfiles;
       else
           this.CurrentProfileNumber_ = id;
       end
       end
       
       function num = getCurrentProfileNumber(this)
       num = this.CurrentProfileNumber_;
       end
       
       function result = getCurrentProfile(this)
       if isempty(this.xrdContainer)
           result = [];
       else
           result = this.xrd;
       end
       end
       
       function value = getNumProfiles(this)
       %GETNUMPROFILES Returns the total number of profiles.
       if isempty(this.xrdContainer)
           value = 0;
       else
           value = length(this.xrdContainer);
       end
       end
       
       function value = getNumFiles(this)
       %GETNUMFILES Returns the total number of Diffraction Data files.
       if isempty(this.xrdContainer)
           value = 0;
       else
           value = this.xrd.NumFiles;
       end
       end
       
       function this = exportProfileParametersFile(this)
       % Assuming there is already a fit
       this.Writer.saveAsFitParameters(this.getProfileResult);
       end
        
       function this = importProfileParametersFile(this, filename)
       %IMPORTPROFILEPARAMETERSFILE(PATH, FILENAME) Reads a parameters file into
       %    the current profile.
       fid = fopen(filename, 'r');
       if fid == -1
           error('Parameter file could not be opened.')
       end
       while ~feof(fid)
          line = fgetl(fid);
          a = strsplit(line,' ');
          switch a{1}
              case '2ThetaRange:'
                  min = str2double(a{2});
                  max = str2double(a{3});
              case 'BackgroundModel:'
                  model = a{2};
              case 'PolynomialOrder:'
                  polyorder = str2double(a{2});
              case 'BackgroundPoints:'
                bkgdpoints = str2double(a(2:end));
              case 'FitFunction(s):'
                line = fgetl(fid);
                fxn = strsplit(line, '; ');
                if isempty(fxn{end})
                    fxn(end) = [];
                end
              case 'PeakPosition(s):'
                peakpos = str2double(a(2:end));
                peakpos = peakpos(1:length(fxn));
              case 'Constraints:'
                  this.xrd.unconstrain('Nxfwm');
                  str = a(2:end);
            case '=='
                break
              otherwise
          end
       end
       this.xrd.Min2T = min;
       this.xrd.Max2T = max;
       this.xrd.setBackgroundModel(model);
       this.xrd.setBackgroundOrder(polyorder);
       this.xrd.setBackgroundPoints(bkgdpoints);
       this.xrd.setFunctions(fxn);
       this.xrd.PeakPositions = peakpos;
       for i=1:length(str)
           cons = strtok(str{i}, '{''''}');
           this.xrd.constrain(cons, i);
       end
       % Read coefficient names
       line  = fgetl(fid);
       coeff = textscan(line, '%s');
       coeff = coeff{1}';
       if ~isequal(coeff, this.xrd.getCoeffs)
           error('Coefficients do not match')
       end
       % Read SP values
       line  = fgetl(fid);
       start    = textscan(line,'%s');
       start    = start{1}';
       init.start    = str2double(start(2:end));
       % Read UB values
       line  = fgetl(fid);
       lower    = textscan(line,'%s');
       lower    = lower{1}';
       init.lower    = str2double(lower(2:end));
       % Read LB values
       line  = fgetl(fid);
       ub    = textscan(line,'%s');
       ub    = ub{1}';
       init.upper    = str2double(ub(2:end));
       this.xrd.FitInitial = init;
       fclose(fid);
       end
       
       
       function results = getProfileResult(this, profnum)
       if nargin < 2
           profnum = this.getCurrentProfileNumber;
       end
       results = this.FitResults{profnum};
       end
       
       function fitresults = fitDataSet(this, gui, prfn)
        % Fits the entire dataset for the current profile and saves it as a cell array of FitResults.
        if nargin < 3
            prfn = this.getCurrentProfileNumber;
        end
        gui.Status = ['Fitting dataset ' num2str(1) ' of ' num2str(this.NumFiles)];
        fitresults = cell(1, this.NumFiles);
        msg = msgbox('Please wait... Press OK to stop the fit.', 'Fitting Dataset...');
        for i=1:this.NumFiles
            try
            % stop the fit if the user closes the msgbox
            if ~isvalid(msg)
                return
            end
            fitresults{i} = model.FitResults(this, i);
            gui.Status = ['Fitting dataset ' num2str(i) ' of ' num2str(this.NumFiles)];
            catch exception
               delete(msg)
               exception.getReport
               rethrow(exception)
            end
        end
        delete(msg);
        this.FitResults{prfn} = fitresults;
        this.Writer.printFitOutputs(fitresults);
        end
   end
        
   methods
       function value = get.xrd(this)
       if isempty(this.xrdContainer)
           value = [];
       else
           value = this.xrdContainer(this.CurrentProfileNumber_);
       end
       end
       
       function set.xrd(this, xrd)
       this.xrdContainer(this.CurrentProfileNumber_) = xrd;
       end
       
       function xdata = dspace(this, twotheta)
        xdata = this.KAlpha1 ./ (2*sind(twotheta));
       end
       
       function xdata = twotheta(this, dspace)
       xdata = asind(this.KAlpha1 ./ (2*dspace));
       end
   end
   
   methods (Static)
       
       function singleObj = getInstance(obj)
       persistent localObj;
       if nargin > 0
           localObj = obj;
       elseif isempty(localObj) || ~isvalid(localObj)
           localObj = model.ProfileListManager(); 
       end
       singleObj = localObj;
       end
   end
   
   
end