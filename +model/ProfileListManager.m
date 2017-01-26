classdef ProfileListManager < matlab.mixin.Copyable
    %PROFILELISTMANAGER Maintains a list of PackageFitDiffractionData objects.
    %   Only a single instance is allowed. To get the handle to the currently
    %   existing ProfileListManager instance, call the static method
    %   ProfileListManager.getInstance.
   properties
       xrdContainer
       
       DataPath
       
       OutputPath
   end
   
   properties (Dependent)
       xrd
   end
   
   properties (Hidden)
       ValidFunctions = {'Gaussian', 'Lorentzian', 'Pearson VII', 'Pseudo-Voigt', 'Asymmetric Pearson VII'};
       
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
       function this = newXRD(this, xrd)
           if nargin < 2
               [data, filename, path] = utils.fileutils.newDataSet();
               if ~isempty(data)
                   this.reset();
                   this.initialXRD_ = PackageFitDiffractionData(data.two_theta, data.data_fit, filename);
               end
           else
               this.reset();
               this.initialXRD_ = xrd;
           end
           if ~isempty(this.initialXRD_) && this.initialXRD_.hasData
               xrd = this.initialXRD_;
               this.DataPath = xrd.DataPath;
               this.OutputPath = [xrd.DataPath 'FitOutputs' filesep];
               this.addProfile;
           end
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
       end
       
       function output = hasData(this)
        if isempty(this.xrdContainer)
            output = false;
        else
            output = true;
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
       
       function this = setCoeffInitialValue(this, coeff, value)
       %SETCOEFFINITIAL Sets the fit initial value of the coefficient specified
       %   in the argument. Also updates table_fitinitial to display the
       %   updated value.
       end
       
       function output = getFileNames(this, file)
       % Assuming listbox_files and popup_filename values are identical.
       if nargin > 1
           output = this.xrd.getFileNames(file);
       else
           output = this.xrd.getFileNames;
       end
       end
       
       function this = exportProfileParametersFile(this)
        if isempty(this.Writer)
            this.Writer = ui.FileWriter(this);
        end
        this.Writer.saveAsParametersFile();
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
                  this.xrd.Min2T = str2double(a{2});
                  this.xrd.Max2T = str2double(a{3});
              case 'BackgroundModel:'
                  this.xrd.setBackgroundModel(a{2});
              case 'PolynomialOrder:'
                  polyorder = str2double(a{2});
                  this.xrd.setBackgroundOrder(polyorder);
              case 'BackgroundPoints:'
                bkgdpoints = str2double(a(2:end));
                this.xrd.setBackgroundPoints(bkgdpoints);
              case 'FitFunction(s):'
                line = fgetl(fid);
                fxn = strsplit(line, '; ');
                if isempty(fxn{end})
                    fxn(end) = [];
                end
                this.xrd.setFunctions(fxn);
              case 'PeakPosition(s):'
                peakpos = str2double(a(2:end));
                peakpos = peakpos(1:length(this.xrd.getFunctions));
                this.xrd.PeakPositions = peakpos;
              case 'Constraints:'
                  this.xrd.unconstrain('Nxfwm');
                  str = a(2:end);
                  for i=1:length(str)
                     cons = strtok(str{i}, '{''''}'); 
                     this.xrd.constrain(cons, i);
                  end
            case '=='
                break
              otherwise
          end
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
       sp    = textscan(line,'%s');
       sp    = sp{1}';
       sp    = str2double(sp(2:end));
       this.xrd.setFitInitial('start', coeff, sp);
       % Read UB values
       line  = fgetl(fid);
       lb    = textscan(line,'%s');
       lb    = lb{1}';
       lb    = str2double(lb(2:end));
       this.xrd.setFitInitial('lower', coeff, lb);
       % Read LB values
       line  = fgetl(fid);
       ub    = textscan(line,'%s');
       ub    = ub{1}';
       ub    = str2double(ub(2:end));
       this.xrd.setFitInitial('upper', coeff, ub);
       fclose(fid);
       end
       
       function this = exportProfileMasterFile(this)
       if isempty(this.Writer)
           this.Writer = ui.FileWriter(this);
       end
       this.Writer.saveAsMasterFile();
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