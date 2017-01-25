
classdef PackageFitDiffractionData < matlab.mixin.Copyable & matlab.mixin.SetGet
    %PACKAGEFITDIFFRACTIONDATA Contains the data for
    
    properties 
        % structure with fields 'start', 'lower', and 'upper'
        FitInitial
        
        AbsoluteRange
    end
    
    properties (Access = protected)
        DataSet % cell array of DiffractionData objects
        
        Background % Background instance; the same fit for all datasets
        
        FitFunctions % cell array of objects subclassing FitFunctionInterface
        
        FitOutput
        
        FitResults % cell array of fit outputs
        
        FitWeight
        
        Results % An instance of FitResults
        
        DisplayName = '';
        
        Constraints_
        
        PeakPositions_
        
    end
    
    properties (Dependent)
        Min2T
        
        Max2T
        
        NumFiles
        
        NumFuncs 
        
        PeakPositions
        
    end
    
    properties (Hidden)
        CuKa = false;
        DataPath
        FullTwoThetaRange
        FullIntensityData
        Temperature
        KAlpha1
        KAlpha2
        KBeta
        RKa1Ka2
    end
    
    properties (Constant, Hidden)
       azim = 0:15:345;
    end
    
    properties(Hidden)
        suffix   = '';
        symdata = 0;
        binID = 1:1:24;
        lambda = 1.5405980;
        OutputPath = 'FitOutputs/';
        numAzim
        recycle_results = 0;
    end
    
    % ======================================================================== %
    methods
        function Stro = PackageFitDiffractionData(x, y, filenames)
        % Constructor
        import model.*
        if nargin >= 1
            if ischar(filenames)
                filenames = {filenames};
            end
            for i=1:size(y, 1)
                dataInput = [x; y(i,:)];
                Stro.DataSet{i} = DiffractionData(dataInput, filenames{i});
            end
            Stro.AbsoluteRange = [x(1) x(end)];
            Stro.Background = model.Background(Stro);
            str = strsplit(which(filenames{1}), filesep);
            Stro.DataPath = fullfile(filesep, str{1:end-1}, filesep);
        end
        end
        
        % ==================================================================== %
    end
    
    methods
        function result = hasCuKa(Stro)
        if ~isempty(Stro.KAlpha2)
            result = true;
        else
            result = false;
        end
        end
        
        function result = getFileNames(Stro, file)
        if nargin < 2
            for i=1:length(Stro.DataSet)
                names{i} = Stro.DataSet{i}.FileName;
            end
        else
            names = Stro.DataSet{file}.FileName;
        end
        result = names;
        end
        % ==================================================================== %
        
        function output = getPeakPosition(Stro, fcnID)
        if nargin > 1
            output = Stro.FitFunctions{fcnID}.PeakPosition;
        else
            output = cell(1, Stro.NumFuncs);
            for i=1:Stro.NumFuncs
                if ~isempty(Stro.FitFunctions{i})
                    output{i} = Stro.FitFunctions{i}.PeakPosition;
                end
            end
        end
        end
        % ==================================================================== %
        
        function Stro = setPeakPosition(Stro, value, fcnID)
        %SETPEAKPOSITION sets the peak position of a function.
        import utils.*
        pos = Stro.PeakPositions_;
        if nargin < 3
            if isempty(value)
                pos = cell(1, Stro.NumFuncs);
            else
                for i=1:length(value)
                    if isempty(Stro.FitFunctions{i})
                        pos{i} = [];
                    else
                        pos{i} = value(i);
                    end  
                end
            end
            
            xConstrainedIdx = find(contains(Stro.getConstraints, 'x'));
            xUniqueIdx = find(~contains(Stro.getConstraints, 'x'));
            
            if ~isempty(xConstrainedIdx)
                % Distribute the first peak value to all constrained x's
                for i=1:length(xConstrainedIdx)
                    idx = xConstrainedIdx(i);
                    Stro.FitFunctions{idx}.PeakPosition = value(1);
                end
                value = value(2:end);
            end
            
            for i=1:length(xUniqueIdx)
                idx = xUniqueIdx(i);
                Stro.FitFunctions{idx}.PeakPosition = value(i);
            end
            
        else
            Stro.FitFunctions{fcnID}.PeakPosition = value;
        end
        
        Stro.PeakPositions_ = pos;
        end
        % ==================================================================== %
        
        function vals = get.PeakPositions(Stro)
        if isempty(Stro.PeakPositions_)
            vals = zeros(1, Stro.NumFuncs);
        else
            vals = Stro.PeakPositions_;
        end
        end
        
        function set.PeakPositions(Stro, val)
        %VAL is a cell array
        pos = zeros(1, Stro.NumFuncs);
        for i=1:length(pos)
            pos(i) = val(i);
        end
        Stro.PeakPositions_ = pos;
        end
        
        function result = getCoeffs(Stro, fcnID)
        %GETCOEFF Returns a string cell array of the coefficient names used in
        %   the fit equation.
        if nargin > 1
            result = Stro.FitFunctions{fcnID}.getCoeffs;
        else
            constrained = [];
            unconstrained = [];
            for i=1:length(Stro.FitFunctions)
                if isempty(Stro.FitFunctions{i})
                    result = [];
                    return
                end
                constrained = [constrained Stro.FitFunctions{i}.getConstrainedCoeffs];
                unconstrained = [unconstrained Stro.FitFunctions{i}.getUnconstrainedCoeffs];
            end
            result = unique([constrained unconstrained], 'stable');
        end
        end
        % ==================================================================== %
        
        function value = get.NumFiles(Stro)
        if isempty(Stro.DataSet)
            value = 0;
        else
            value = length(Stro.DataSet);
        end
        
        end
        % ==================================================================== %
        
        function value = getFunctionNames(Stro, file)
        value = [];
        
        if nargin < 2
            if ~isempty(Stro.FitFunctions)
                value = cell(1, length(Stro.FitFunctions));
                
                for i=1:length(Stro.FitFunctions)
                    if isempty(Stro.FitFunctions{i})
                        value{i} = [];
                    else
                        value{i} = Stro.FitFunctions{i}.Name;
                    end
                end
                
            end
        else
            value = Stro.FitFunctions{file}.Name;
        end
        end
        % ==================================================================== %
        
        function result = get.NumFuncs(Stro)
        
        if isempty(Stro.FitFunctions)
            result = 0;
        else
            result = length(Stro.FitFunctions);
        end
        
        end
        % ==================================================================== %
        
        function Stro = constrain(Stro, coeff, fcnID)
        %CONSTRAIN(STRO, COEFF, FCNID) constrains the coefficient name (without
        %   numbers) specified in COEFF for the function at index FCNID.
        %
        %   CONSTRAIN(STRO, COEFF) constrains the coefficient COEFF for all
        %   functions. 
        %
        %   If COEFF is a character, then all functions will constrain COEFF. If
        %   COEFF is a cell array, then it constrains the coefficient in the
        %   function at the same index. 
        if nargin > 2 && fcnID > length(Stro.FitFunctions)
            error('fcnID out of bounds.')
        end
        
        if nargin > 2
            Stro.FitFunctions{fcnID}.constrain(coeff);
            
        else
             c = cell(1, Stro.NumFuncs);
            if ischar(coeff)
                c(:) = {coeff};
            
            elseif iscell(coeff) 
                for i=1:length(coeff)
                    c{i} = coeff{i};
                end
            end
            
            for i=1:Stro.NumFuncs
                if ~isempty(Stro.FitFunctions{i})
                    Stro.FitFunctions{i}.constrain(c{i});
                end
            end
        end
        
        
        end
        % ==================================================================== %
        
        function Stro = unconstrain(Stro, coeff, fcnID)
        if nargin > 2 && fcnID > length(Stro.FitFunctions)
            error('fcnID out of bounds.')
        end
        
        if nargin > 2
            Stro.constrain(coeff, fcnID);
            
        else
            c = cell(1, Stro.NumFuncs);
            if ischar(coeff)
                c(:) = {coeff};
            
            elseif iscell(coeff) 
                for i=1:length(coeff)
                    c{i} = coeff{i};
                end
            end
            
            for i=1:Stro.NumFuncs
                if ~isempty(Stro.FitFunctions{i})
                    Stro.FitFunctions{i}.unconstrain(c{i});
                end
            end
        end
        
        
        end
        % ==================================================================== %
        
        function output = getConstraints(Stro, arg)
        %OUTPUT = GETCONSTRAINTS_(STRO, ARG) returns two different types of
        %   OUTPUT depending on the type of ARG.
        %
        %   If ARG is a number, OUTPUT is the constraints as a string for the 
        %   fit function at index ARG.
        %
        %   If 'ARG' is a char, it returns a logical array the same size as the 
        %   number of functions, where an element is TRUE if the function at
        %   the same index has the constraint 'ARG'.
        if nargin > 1
            cons = {cell2mat(Stro.FitFunctions{arg}.ConstrainedCoeffs)};
            
        else
            cons = cell(1,length(Stro.FitFunctions));
            for i=1:length(Stro.FitFunctions)
                if isempty(Stro.FitFunctions{i})
                    cons{i} = [];
                else
                    cons{i} = cell2mat(Stro.FitFunctions{i}.ConstrainedCoeffs);
                end
            end
        end
        output = cons;
        end
                
        function output = isConstrained(Stro, coeff, fcnID)
        constraints = Stro.getConstraints;
        
        if nargin > 2
            if isempty(constraints{fcnID})
                output = false;
            else
                output = contains(constraints{fcnID}, coeff);
            end
            
        else
            for i=1:Stro.NumFuncs
                if isempty(constraints{i})
                    output(i) = false;
                else
                    output(i) = contains(constraints{i}, coeff);
                end
            end
            
        end
        
        end
        % ==================================================================== %
        
        function result = getEqnStr(Stro)
        %GETEQNSTR Returns a combined string equation of all the functions in the
        %   Functions cell array.
        result = '';
        fcns = Stro.FitFunctions;
        
        for i=1:length(fcns)
            result = [result fcns{i}.getEqnStr]; %#ok<*AGROW>
            
            if i ~= length(fcns)
                result = [result ' + '];
            end
        end
        
        end
        % ==================================================================== %
        
        function out = calculateBackground(Stro, file)
        Stro.Background.update2T([Stro.Min2T Stro.Max2T]);
        if nargin < 2
            file = 1;
        end
        out = Stro.Background.calculateFit(file);
        end
        % ==================================================================== %
        
        function output = calculateFitInitial(Stro, fitinitial)
        %CALCULATEFITINITIAL calculates the current functions and returns an
        %   array, where each row is the fit for each function for the current
        %   two theta region. 
        output = [];
        if nargin < 2
            fitinitial = Stro.FitInitial.start;
        end
        coeffnames = Stro.getCoeffs;            
        for i=1:length(Stro.FitFunctions)
            fcnCoeffNames = Stro.FitFunctions{i}.getCoeffs;
            for j=1:length(fcnCoeffNames)
                idx(j) = find(strcmpi(coeffnames, fcnCoeffNames{j}),1);
            end
            output(i,:) = Stro.FitFunctions{i}.calculateFit(Stro.getTwoTheta, fitinitial(idx));
        end
        end
        % ==================================================================== %

        function output = calculateFit(Stro, fcnID)
        if nargin > 1
            output = Stro.FitResults{fcnID}.FData;
        else
            for i=1:Stro.NumFuncs
                output(i, :) = Stro.calculateFit(i);
            end
        end
        end

        
        function Stro = setBackgroundPoints(Stro, points, mode)
        %
        %
        %X - The 2theta position
        %
        %MODE - 'new', 'add', 'delete'
        bg = Stro.Background;
        Stro.Background = bg.update2T([Stro.Min2T, Stro.Max2T]);
        
        if nargin < 3 || isempty(bg.InitialPoints)
            mode = 'new';
        end
        
        if strcmpi(mode, 'new')
            Stro.Background.InitialPoints = points;
            
        elseif strcmpi(mode, 'append')
            Stro.Background.InitialPoints = [bg.InitialPoints points];
            
        elseif strcmpi(mode, 'delete')
            idx = utils.findIndex(bg.InitialPoints, points);
            Stro.Background.InitialPoints(idx) = [];
        end
        
        end
        % ======================================================================
        
        function Stro = setBackgroundOrder(Stro, value)
        Stro.Background.Order = value;
        end
        
        function value = getBackgroundOrder(Stro)
        value = Stro.Background.Order;
        end
        
        function Stro = setBackgroundModel(Stro, name)
        Stro.Background.Model = name;
        end
        
        function value = getBackgroundModel(Stro)
        value = Stro.Background.Model;
        end
        
        function [result idx] = getBackgroundPoints(Stro)
        if isempty(Stro.Background.InitialPoints)
            result = [];
            idx = [];
        else
            result = Stro.Background.InitialPoints;
            idx = Stro.Background.InitialPointsIdx;
        end
        
        end
        
        function result = getData(Stro, file)
        %GETDATA Returns data within the Min2T and Max2T range of the file
        %   number specified in the argument 'file'. If no file is specified,
        %   data from the first file is returned.
        if nargin <= 1
            file = 1;
        end
        
        result = Stro.DataSet{file}.getDataIntensity;
        end
        
        function result = getTwoTheta(Stro, file)
        % Assuming two theta is identical for all datasets
        if nargin > 1
            result = Stro.DataSet{file}.getDataTwoTheta();
        else
            result = Stro.DataSet{1}.getDataTwoTheta();
        end
        
        end
        
        function result = getDataNoBackground(Stro, file)
        %GETDATANOBACKGROUND Returns the intensity after subtracting the
        %   background fit.
        %
        if isempty(Stro.Background) || isempty(Stro.Background.InitialPoints)
            error('No background points')
        end
        
        if nargin < 2
            file = 1;
        end
        
        data = Stro.getData(file);
        bg = Stro.Background.calculateFit(file);
        result = data - bg;
        end
        
        function output = isFuncAsymmetric(~, name)
        output = contains(lower(name), 'asym');
        
        end
        
        function fcnName = setFunctions(Stro, fcnName, fcnID)
        %SETFUNCTIONS Creates the FitFunction objects of type Gaussian, Lorentzian,
        %   Pearson VII, and Pseudo-Voigt, or any of their corresponding
        %   asymmetric functions. The function type is specified by the string
        %   fcnNames.
        %
        %   SETFUNCTIONS(STRO, FCNNAME) creates a cell array of FitFunction 
        %   objects specified in FCNNAME and saves it into the property 
        %   FITFUNCTIONS.
        %
        %   SETFUNCTIONS(STRO, FCNNAME, FCNID)
        %
        %   FCNNAME = SETFUNCTIONS(STRO, FCNNAME, FCNID) 
        %
        %   FCNNAMES = A string cel array specifying the name of the fit functions
        %   to use.
        %
        
        %   Logical array of size shape specifying if the function is supposed to
        %   be asymmetric
        %
        %   FCNNAME options:
        %       Gaussian              -
        %       Lorentzian            -
        %       Pearson VII           -
        %       Asymmetric Pearson VII-
        %       Pseudo-Voigt          -
        
        if isempty(fcnName)
            Stro.FitFunctions = [];
            return
        end
        if nargin > 2
            Stro.FitFunctions{fcnID} = Stro.setFitFunction_(fcnName, fcnID); 
        else
           if ischar(fcnName)
               fcnName = {fcnName};
           end
           newfcns = cell(1, length(fcnName));
           if isempty(Stro.FitFunctions)
               oldfcns = newfcns;
           else
               oldfcns = Stro.FitFunctions;
           end
           for i=1:length(fcnName)
               if i > length(oldfcns)
                   break
               elseif isempty(oldfcns{i}) 
                   newfcns{i} = Stro.setFitFunction_(fcnName{i}, i);
               elseif isequal(oldfcns{i}.Name, fcnName{i})
                   newfcns{i} = Stro.FitFunctions{i};
               end
           end
           Stro.FitFunctions = newfcns;
        end
        end
        
        function fcnName = setFitFunction_(Stro, fcnName, fcnID)
        %SETFUNCTION Creates the FitFunction objects of type Gaussian, Lorentzian,
        %   Pearson VII, and Pseudo-Voigt, or any of their corresponding
        %   asymmetric functions. The function type is specified by the string
        %   fcnNames.
        %
        %FCNNAMES - A string cel array specifying the name of the fit functions
        %   to use.
        %
        
        % Logical array of size shape specifying if the function is supposed to
        %   be asymmetric
        if isempty(fcnName)
            fcnName = [];
            return
        end
        
        allowedFcns = {'Gaussian' 'Lorentzian' 'Pearson VII' 'Pseudo-Voigt'};
        allowedFcns_ = {'Gaussian' 'Lorentzian' 'PearsonVII' 'PseudoVoigt'};
        
        isAsym = Stro.isFuncAsymmetric(fcnName);
        
        % if the function name is asymmetrical, get function name without
        %    'Asymmetrical' prefix
        if isAsym
            [~, fcnName] = strtok(fcnName);
            fcnName = fcnName(2:end); % skip leading whitespace
        end
        
        % Get the index of function name into list of allowed functions
        idx = find(contains(allowedFcns, fcnName), 1);
        
        if isempty(idx)
            msgID = ['LIPRAS:' class(Stro) ':setFunction:InvalidArgument'];
            msg = ['The argument ''fcnNames'' must be contain the any of the functions: ', ...
                ' ''Gaussian'', ''Lorentzian'', ''Pearson VII'', or ''Pseudo Voigt'''];
            e = MException(msgID, msg);
            throw(e)
        end
        
        someFunc = allowedFcns_{idx};
        
        if isAsym
            fcnName = model.fitcomponents.Asymmetric(fcnID, '', someFunc);
        else
            fcnName = model.fitcomponents.(someFunc)(fcnID); 
        end
        end
        % ==================================================================== %
        
        function output = getFunctions(Stro, fcnID)
        output = [];
        
        if nargin > 1
            output = Stro.FitFunctions{fcnID};
            
        else
            for i=1:length(Stro.FitFunctions)
                output{i} = Stro.FitFunctions{i};
            end
        end
        end
        
        function result = getFitType(Stro)
        % Assumes that Stro.FitFunctions is not empty
        coeffs = Stro.getCoeffs;
        eqnStr = Stro.getEqnStr;
        
        result = fittype(eqnStr, 'coefficients', coeffs, 'independent', 'xv');
        end
        % ==================================================================== %
        
        function status = fitDataSet(Stro)
        % Fits the entire dataset and saves it as a cell array of FitResults.
        %
        %   STATUS is TRUE if the fit was successful. 
        status = false;
        try
        h = waitbar(0, '1', 'Name', 'Fitting dataset...', ...
            'CreateCancelBtn', ...
            'setappdata(gcbf,''canceling'', 1)');
        setappdata(h, 'canceling', 0);
        catch
        end
        steps = Stro.NumFiles;
        fitresults = cell(1, steps);
        xdata = Stro.getTwoTheta;
        for step=1:steps
            if exist('h', 'var') && getappdata(h, 'canceling')
                break
            end
            % Report current status of fitting dataset
            msg = ['Fitting Dataset ' num2str(step) ' of ' num2str(steps)];
            if exist('h', 'var')
            waitbar(step/steps, h, msg);
            else
                disp(msg)
            end
            ydata = Stro.getDataNoBackground(step);
            fitType = Stro.getFitType();
            fitOptions = Stro.getFitOptions();
            fitresults{step} = model.FitResults(Stro, step);
        end
        if exist('h', 'var') && ~getappdata(h, 'canceling')
            Stro.FitResults = fitresults;
            status = true;
        end
        delete(h);
        end
        
        function output = getFitResults(Stro)
        output = Stro.FitResults;
        end
        
        function output = getFitInitial(Stro, bound, coeffs)
        %
        %
        %   BOUND - 'start', 'lower', or 'upper'
        fitinitial = Stro.FitInitial;
        if ~isfield(fitinitial, 'start')
            fitinitial.start = [];
        end
        if ~isfield(fitinitial, 'lower')
            fitinitial.lower = [];
        end
        if ~isfield(fitinitial, 'upper')
            fitinitial.upper = [];
        end
        if nargin == 1
            output = fitinitial;
            
        elseif nargin == 2
            bound = lower(bound);
            output = fitinitial.(bound);
            
        elseif nargin == 3
            if ischar(coeffs)
                coeffs = {coeffs};
            end
            
            coefflist = Stro.getCoeffs;
            result = zeros(1, length(coeffs));
            vals = Stro.FitInitial.(lower(bound));

            for i=1:length(coeffs)
                idx = find(strcmpi(coefflist, coeffs{i}),1);
                result(i) = vals(idx);
            end
            
            output = result;
        end
        end
        
        function setFitInitial(Stro, bound, coeffs, values)
        %
        %
        %   BOUND - 'start', 'lower', or 'upper'
        %
        %   COEFFS - string or cell array of coefficients names. Must match the
        %   length of VALUES.
        bound = lower(bound);
        
        if isempty(bound)
            Stro.FitInitial = [];
            return
        end
        
        if isempty(coeffs)
            Stro.FitInitial.(bound) = [];
            return
        end
        
        if ischar(coeffs)
            coeffs = {coeffs};
        end
        
        if length(values) ~= length(coeffs)
            error('Values and coeffs argument length must match.')
        end
        
        currentvals = Stro.getFitInitial(bound);
        coefflist = Stro.getCoeffs;
        
        for i=1:length(coeffs)
            idx = find(strcmpi(coefflist, coeffs{i}), 1);
            currentvals(idx) = values(i);
        end
        
        Stro.FitInitial.(bound) = currentvals;
        
        end
        
        function s = getFitOptions(Stro)
        %FITDATA_ Helper function for fitDataSet. Fits a single file.
        SP = Stro.getFitInitial('start');
        LB = Stro.getFitInitial('lower');
        UB = Stro.getFitInitial('upper');
        weight = Stro.FitWeight;
        
        s = fitoptions('Method', 'NonlinearLeastSquares', ...
            'StartPoint', SP, ...
            'Lower', LB, ...
            'Upper', UB, ...
            'Weight',weight);
        end
        
        function output = getDefaultStartingBounds(Stro)
        if isempty(Stro.FitFunctions) || isempty(Stro.PeakPositions)
            output = [];
            return
        end
        if nargin < 2
            file = 1;
        end
        
        coefflist = Stro.getCoeffs;
        result = zeros(1, length(coefflist));
        for i=1:length(Stro.FitFunctions)
            Stro.FitFunctions{i}.PeakPosition = Stro.PeakPositions(i);
        end
        
        for i=1:length(coefflist)
            c = coefflist{i};
            % Finds the first function to have a coefficient with the same name
            for j=1:length(Stro.FitFunctions)
                fcn = Stro.FitFunctions{j};
                fcn.RawData = [Stro.getTwoTheta; Stro.getDataNoBackground()];
                
                vals = fcn.getDefaultInitialValues(fcn.RawData);
                fc = fcn.getCoeffs;
                idx = find(strcmpi(fc, c), 1);
                
                if ~isempty(idx)
                    result(i) = vals.(c(1));
                    break
                end
            end
            
        end
        
        output = result;
        
        
        end
         
        function output = getDefaultLowerBounds(Stro)
        if isempty(Stro.FitFunctions)
            error('No fit functions')
        elseif isempty(Stro.getPeakPosition)
            error('No peak position')
        end
        
        coefflist = Stro.getCoeffs;
        result = zeros(1, length(coefflist));
        
        for i=1:length(coefflist)
            c = coefflist{i};
            
            for j=1:length(Stro.FitFunctions)
                fcn = Stro.FitFunctions{j};
                fcn.RawData = [Stro.getTwoTheta; Stro.getDataNoBackground()];
                
                vals = fcn.getDefaultLowerBounds(fcn.RawData);
                fc = fcn.getCoeffs;
                idx = find(strcmpi(fc, c), 1);
                
                if ~isempty(idx)
                    result(i) = vals.(c(1));
                    break
                end
            end
            
        end
        
        output = result;
        end
        
        function output = getDefaultUpperBounds(Stro)
        if isempty(Stro.FitFunctions)
            error('No fit functions')
        elseif isempty(Stro.getPeakPosition)
            error('No peak position')
        end
        
        coefflist = Stro.getCoeffs;
        result = zeros(1, length(coefflist));
        
        for i=1:length(coefflist)
            c = coefflist{i};
            
            for j=1:length(Stro.FitFunctions)
                fcn = Stro.FitFunctions{j};
                fcn.RawData = [Stro.getTwoTheta; Stro.getDataNoBackground()];
                
                vals = fcn.getDefaultUpperBounds(fcn.RawData);
                fc = fcn.getCoeffs;
                idx = find(strcmpi(fc, c), 1);
                
                if ~isempty(idx)
                    result(i) = vals.(c(1));
                    break
                end
            end
            
        end
        
        output = result;
        end
        
        
    end
    
    % ==================================================================== %
    
    methods
        function value = get.Min2T(Stro)
        % Assumes all datasets have identical Min2T
        value = Stro.DataSet{1}.Min2T;
        end
        
        function set.Min2T(Stro, value)
        for i=1:length(Stro.DataSet)
            Stro.DataSet{i}.Min2T = value;
        end
        end
        
        function value = get.Max2T(Stro)
        % Assumes all datasets have identical Max2T
        value = Stro.DataSet{1}.Max2T;
        end
        
        
        function set.Max2T(Stro, value)
        for i=1:length(Stro.DataSet)
            Stro.DataSet{i}.Max2T = value;
        end
        end
        
        
        function a = hasData(Stro)
        if ~isempty(Stro.DataSet)
            a = true;
        else
            a = false;
        end
        end
        % ==================================================================== %
        
        
        function a = hasFit(Stro)
        if isempty(Stro.FitResults)
            a = false;
        else
            a = true;
        end
        
        end
        
        function a = hasBackground(Stro)
        if isempty(Stro.Background) || isempty(Stro.Background.getInitialPoints)
            a = false;
        else
            a = true;
        end
        
        end
    end
    
    methods(Static)
        
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
        % ==================================================================== %
        
        
        
        function [x]=SaveFitData(filename,dataMatrix)
        %
        % function [x]=SaveFitData(filename,dataMatrix)
        % JJones, 23 Nov 2007
        %
        
        if nargin~=2 %number of required input arguments
            error('Incorrect number of arguments')
            x=0; %means unsuccessful
        else
            fid = fopen(filename,'w');
            fprintf(fid, 'This is an output file from a MATLAB routine.\n');
            fprintf(fid, 'All single peak data (column 3+) does not include background intensity.\n');
            fprintf(fid, '2theta \t IntMeas \t BkgdFit \t Peak1 \t Peak2 \t Etc...\n');
            dataformat = '%f\n';
            for i=1:(size(dataMatrix,1)-1);
                dataformat = strcat('%f\t',dataformat);
            end
            fprintf(fid, dataformat, dataMatrix);
            fclose(fid);
            x=1; %means successful
        end
        end
        % ==================================================================== %
        
        function [x]=SaveFitValues(filename,PSfxn,Fmodel,Fcoeff,FmodelGOF,FmodelCI)
        % function
        %      [x]=SaveFitValues(filename,PSfxn,Fmodel,Fcoeff,FmodelGOF,FmodelCI)
        %
        % JJones, 23 Nov 2007
        %
        
        if nargin~=6 %number of required input arguments
            error('Incorrect number of arguments')
            x=0; %means unsuccessful
        else
            fid = fopen(filename,'w');
            
            fprintf(fid, 'This is an output file from a MATLAB routine.\n');
            for i=1:1 % Modified by GIO on 11-23-2016
                if i==1; test=0; else test=strcmp(PSfxn{i},PSfxn{i-1}); end
                %write coefficient names
                if or(i==1,test==0);
                    fprintf(fid, strcat('The following peaks are all of the type:', PSfxn{i}, '\n'));
                    %first output fitted values
                    for j=1:length(Fcoeff{i});
                        fprintf(fid, '%s\t', char(Fcoeff{i}(j))); %write coefficient names
                    end
                    %second output GOF values
                    
                    fprintf(fid, 'sse \t rsquare \t dfe \t adjrsquare \t rmse \t'); %write GOF names
                    %third output Confidence Intervals (CI)
                    for j=1:size(FmodelCI{i},2)
                        fprintf(fid, '%s\t', strcat('LowCI:',char(Fcoeff{i}(j)))); %write LB names
                        fprintf(fid, '%s\t', strcat('UppCI:',char(Fcoeff{i}(j)))); %write UB names
                    end
                    fprintf(fid, '\n');
                end
                %write coefficient values
                for j=1:length(Fcoeff{i});
                    fprintf(fid, '%f\t', Fmodel{i}.(Fcoeff{i}(j))); %write coefficient values
                end
                
                GOFoutputs=[FmodelGOF{i}.sse FmodelGOF{i}.rsquare FmodelGOF{i}.dfe FmodelGOF{i}.adjrsquare FmodelGOF{i}.rmse];
                fprintf(fid, '%f\t%f\t%f\t%f\t%f\t',GOFoutputs); %write GOF values
                for j=1:size(FmodelCI{i},2)
                    fprintf(fid, '%f\t', FmodelCI{i}(1,j)); %write lower bound values
                    fprintf(fid, '%f\t', FmodelCI{i}(2,j)); %write upper bound values
                end
                fprintf(fid, '\n');
            end
            fclose(fid);
            x=1; %means successful
        end
        
        end
        % ==================================================================== %
    end
end
