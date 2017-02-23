
classdef PackageFitDiffractionData < matlab.mixin.Copyable & matlab.mixin.SetGet
    %PACKAGEFITDIFFRACTIONDATA Contains the data for
    
    properties 
        % structure with fields 'start', 'lower', and 'upper'
        FitInitial
        
        AbsoluteRange
        
        XData
        
    end
    
    properties (Access = protected)
        DataSet % cell array of DiffractionData objects
        
        Background % Background instance; the same fit for all datasets
        
        FitFunctions % cell array of objects subclassing FitFunctionInterface
        
        FitOutput
        
        FitWeight
        
        Results % An instance of FitResults
        
        DisplayName = '';
                
        PeakPositions_
        
    end
    
    properties (Dependent)
        
        NumFiles
        
        NumFuncs 
        
        PeakPositions
        
    end
    
    properties (Dependent, Hidden)
        DataPath
        KAlpha1
        KAlpha2 = 1.544426; % nm
        Min2T
        Max2T
    end
    
    properties (Hidden)
        CuKa = false;
        FitResults % cell array of fit outputs
        FullTwoThetaRange
        FullIntensityData
        Temperature
        KBeta
        RKa1Ka2
    end
    
    properties (Constant, Hidden)
       azim = 0:15:345;
    end
    
    properties(Hidden)
        suffix   = '';
        CuKa2Peak
        KAlpha1_ = [];
        KAlpha2_ = 1.544426; % nm
        symdata = 0;
        binID = 1:1:24;
        lambda = 1.5405980;
        OutputPath = ['FitOutputs' filesep];
        numAzim
        recycle_results = 0;
    end
    
    % ======================================================================== %
    methods
        function Stro = PackageFitDiffractionData(data, filenames, path)
        % Constructor
        import model.*
        if nargin >= 1
            if ischar(filenames)
                filenames = {filenames};
            end
            x = data(1).two_theta;
            Stro.DataSet = cell(1, size(x,1));
            for i=1:size(x,1)
                if isequal(data(1).ext,'.xrdml')
                    fn = [filenames{1} ' (scan ' num2str(i) ')'];
                    Stro.DataSet{i} = model.XRDMLData(data, fn, i);
                else
                    Stro.DataSet{i} = model.DiffractionData(data, filenames{i}, i);
                end
            end
            Stro.AbsoluteRange = [x(1) x(end)];
            Stro.Background = model.Background(Stro);
        end
        
        if nargin > 2
            Stro.DataPath = path;
            Stro.OutputPath = [path Stro.OutputPath];
        end
        end
        
        % ==================================================================== %
    end
    
    methods
        function set.DataPath(Stro, datapath)
            for i=1:length(Stro.DataSet)
                Stro.DataSet{i}.DataPath = datapath;
            end
        end
        
        function set.KAlpha1(Stro, value)
        for i=1:Stro.NumFuncs
           if ~isempty(Stro.CuKa2Peak{i})
               Stro.CuKa2Peak{i}.KAlpha1 = value;
           end
        end
        Stro.KAlpha1_ = value;
        end
        
        function value = get.KAlpha1(Stro)
        value = Stro.KAlpha1_;
        end
        
        function set.KAlpha2(Stro, value)
        for i=1:Stro.NumFuncs
           if ~isempty(Stro.CuKa2Peak{i})
               Stro.CuKa2Peak{i}.KAlpha2 = value;
           end
        end
        Stro.KAlpha2_ = value;
        end
        
        function value = get.KAlpha2(Stro)
        value = Stro.KAlpha2_;
        end
        
        function datapath = get.DataPath(Stro)
        datapath = Stro.DataSet{1}.DataPath;
        end
        
        function result = hasCuKa(Stro)
        if Stro.CuKa
            result = true;
        else
            result = false;
        end
        end
        
        function result = getFileNames(Stro, file)
        result = [];
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
        
        function vals = get.PeakPositions(Stro)
        vals = zeros(1, Stro.NumFuncs);
        if ~isempty(Stro.PeakPositions_)
            for i=1:length(vals)
                if i <= length(Stro.PeakPositions_)
                    vals(i) = Stro.PeakPositions_(i);
                end
            end
        end
        end
        
        function set.PeakPositions(Stro, val)
        %VAL is a numeric array
        val = sort(val);
        pos = zeros(1, Stro.NumFuncs);
        for i=1:length(pos)
            pos(i) = val(i);
        end
        Stro.PeakPositions_ = pos;
        end
        
        
        function coeffvals = startingValuesForPeak(Stro, fcnID)
        %STARTINGVALUESFORPEAK returns the coefficient values stored in Stro.FitInitial for the peak
        %   specified in FCNID. 
        %
        %   (Originally created to help with plotting CuKa2 peaks)
        coeffvals = [];
        if isempty(Stro.FitInitial) 
            return
        end
        coeffs = Stro.getCoeffs;
        start = Stro.FitInitial.start;
        fcnCoeffNames = Stro.FitFunctions{fcnID}.getCoeffs;
        coeffIdx = zeros(1, length(fcnCoeffNames));
        for i=1:length(fcnCoeffNames)
            coeffIdx(i) = find(strcmp(coeffs, fcnCoeffNames{i}),1);
        end
        coeffvals = start(coeffIdx);
        end
        
        
        function output = calculateCuKaPeak(Stro, fcnID, coeffvals)
        output = [];
        if nargin < 3
            coeffvals = Stro.startingValuesForPeak(fcnID); 
        end
        if isempty(coeffvals)
            return
        end
        output = Stro.CuKa2Peak{fcnID}.calculateFit(Stro.getTwoTheta, coeffvals);
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
        if isempty(coeff)
            return
        end
        if nargin > 2
            Stro.FitFunctions{fcnID}.constrain(coeff);
        else
            if ischar(coeff)
                coeffcells = cell(1,Stro.NumFuncs);
                coeffcells(:) = {coeff};
                coeff = coeffcells;
            end
            % c = string of constrained coefficients. Can be any letter in 'Nxfwm' in any order
            c = unique([coeff{:}]);
            % For every constraint, check to make sure there are at least 2 functions
            % constrained
            for i=1:length(c)
                idx = find(utils.contains(coeff, c(i)));
                if length(idx) < 2
                    coeff{idx} = strrep(coeff{idx}, c(i), '');
                end
            end
            
            for i=1:Stro.NumFuncs
                if ~isempty(Stro.FitFunctions{i}) && ~isempty(coeff{i})
                    Stro.constrain(coeff{i}, i);
                end
            end
        end
        end
        % ==================================================================== %
        
        function Stro = unconstrain(Stro, coeff, fcnID)
        % COEFF is a string
        if nargin > 2 && fcnID > length(Stro.FitFunctions)
            error('fcnID out of bounds.')
        end
        
        if nargin > 2 
            if ischar(coeff) && ~isempty(Stro.FitFunctions{fcnID})
                Stro.FitFunctions{fcnID}.unconstrain(coeff);
            end
        else
            for i=1:Stro.NumFuncs
                if ~isempty(Stro.FitFunctions{i})
                    Stro.FitFunctions{i}.unconstrain(coeff);
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
        import utils.contains
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
        
        function str = getEqnStr(Stro)
        %GETEQNSTR Returns a combined string equation of all the functions in the
        %   Functions cell array.
        str = '';
        fcns = Stro.FitFunctions;
        for i=1:length(fcns)
            if isempty(fcns{i})
                str = ''; return
            end
            str = [str fcns{i}.getEqnStr]; %#ok<*AGROW>
            if Stro.CuKa
                str = [str ' + ' Stro.CuKa2Peak{i}.getEqnStr];
            end
            if i ~= length(fcns)
                str = [str ' + '];
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
        %
        %   If FITINITIAL isn't specified, it uses the starting fit initial values.
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
            invalidNums = isnan(output(i,:));
            output(i,invalidNums) = 0;
        end
        end
        % ==================================================================== %

        function Stro = setBackgroundPoints(Stro, points)
        %
        %
        %X - The 2theta position
        %
        %MODE - 'new', 'add', 'delete'
        Stro.Background = Stro.Background.update2T([Stro.Min2T, Stro.Max2T]);
        Stro.Background.InitialPoints = points;
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
        
        function [result, idx] = getBackgroundPoints(Stro)
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
            result = [];
            return
        end
        Stro.Background.update2T([Stro.Min2T Stro.Max2T]);
        if nargin < 2
            file = 1;
        end
        data = Stro.getData(file);
        bg = Stro.Background.calculateFit(file);
        result = data - bg;
        end
        
        function output = isFuncAsymmetric(~, name)
        output = utils.contains(lower(name), 'asym');
        
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
                        
        function s = getFitOptions(Stro)
        %FITDATA_ Helper function for fitDataSet. Fits a single file.
        SP = Stro.FitInitial.start;
        LB = Stro.FitInitial.lower;
        UB = Stro.FitInitial.upper;
        weight = Stro.FitWeight;
        s = fitoptions('Method', 'NonlinearLeastSquares', ...
            'StartPoint', SP, ...
            'Lower', LB, ...
            'Upper', UB, ...
            'Weight',weight);
        end
        
        function values = generateDefaultFitBounds(Stro)
        % Generates the default starting, lower, and upper bounds based on the peak
        % positions and saves it into the property FitInitial.
        
        % Check if peak positions and fit functions are valid
        if ~isempty(find(Stro.PeakPositions==0,1)) || ~isempty(find(cellfun(@isempty,Stro.FitFunctions),1))
            return
        end
        Stro.FitInitial.start = Stro.getDefaultBounds('start');
        Stro.FitInitial.lower = Stro.getDefaultBounds('lower');
        Stro.FitInitial.upper = Stro.getDefaultBounds('upper');
        values = Stro.FitInitial;
        end
        
        function position2 = Ka2fromKa1(Stro, position1)
        %KA2FROMKA1 calculates the second peak position using KAlpha1 and KAlpha2.
        %
        %   POSITION1 is the 2theta position of the first peak.
        lambda1 = Stro.KAlpha1; %Ka1
        lambda2 = Stro.KAlpha2; %Ka2
        position2 = 180 / pi * (2*asin(lambda2/lambda1*sin(pi / 180 * (position1/2))));
        end
        % ==================================================================== %
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
        Stro.FitWeight = 1./abs(Stro.getTwoTheta);
        end
        
        function value = get.Max2T(Stro)
        % Assumes all datasets have identical Max2T
        value = Stro.DataSet{1}.Max2T;
        end
        
        
        function set.Max2T(Stro, value)
        for i=1:length(Stro.DataSet)
            Stro.DataSet{i}.Max2T = value;
        end
        Stro.FitWeight = 1./abs(Stro.getTwoTheta);
        end
        
        
        function a = hasData(Stro)
        if ~isempty(Stro.DataSet)
            a = true;
        else
            a = false;
        end
        end
        % ==================================================================== %
        
        function a = hasBackground(Stro)
        if isempty(Stro.Background) || isempty(Stro.Background.getInitialPoints)
            a = false;
        else
            a = true;
        end
        
        end
    end
    
    
end
