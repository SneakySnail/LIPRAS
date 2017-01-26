classdef FitResults
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        FileName

        FunctionNames

        Fmodel
        
        FmodelGOF
        
        FmodelCI

        CoeffNames

        CoeffValues

        CoeffError

        TwoTheta

        Background      % Background fit

        FitInitial      % Struct with fields 'start', 'lower', and 'upper'

        FData           % Numeric array result after fitting TwoTheta with Fmodel

        FPeaks          % Numeric array result of each function's fits
    end
    
    
    properties (Hidden) % Because they were used for getting the fit
        BackgroundModel
        
        BackgroundOrder
        
        BackgroundPoints
        
        Intensity       % Raw data
        
        PeakPositions
        
        Constraints
        
        FitOptions

    end

properties (Access = protected)
    FitType


    FitFunctions

end

properties (Constant)
CONFIDENCE_LEVEL = 0.95;
end
    
    methods
        function this = FitResults(xrd, filenumber)
        %FITRESULTS constructor for fitting the data. It saves the fit results and also the fit
        %   parameters that were used.
        %
        %   
        this.FileName      = strrep(xrd.getFileNames{filenumber}, '.', '_');
        this.FunctionNames = xrd.getFunctionNames;
        this.TwoTheta      = xrd.getTwoTheta;
        this.Intensity     = xrd.getData(filenumber);
        this.Background    = xrd.calculateBackground(filenumber);
        this.BackgroundOrder = xrd.getBackgroundOrder;
        this.BackgroundModel = xrd.getBackgroundModel;
        this.BackgroundPoints = xrd.getBackgroundPoints;
        this.PeakPositions = xrd.PeakPositions;
        this.Constraints = xrd.getConstraints;
        this.FitType       = xrd.getFitType;
        this.FitOptions    = xrd.getFitOptions;
        this.CoeffNames    = coeffnames(this.FitType)';
        this.FitFunctions  = xrd.getFunctions;
        
        [fmodel, fmodelgof] = fit(this.TwoTheta', ...
                                 (this.Intensity - this.Background)', ...
                                  this.FitType, this.FitOptions);
        fmodelci = confint(fmodel, this.CONFIDENCE_LEVEL);
        
        this.Fmodel    = fmodel;
        this.FmodelGOF = fmodelgof;
        this.FmodelCI  = fmodelci;
        
        this.FData       = fmodel(this.TwoTheta)';
        this.CoeffValues = coeffvalues(fmodel);
        this.CoeffError  = 0.5 * (fmodelci(2,:) - fmodelci(1,:));

        for i=1:length(this.FitFunctions)
            this.FPeaks(i,:) = this.calculatePeakFit(i);
        end

        this.FitInitial.start = this.FitOptions.StartPoint;
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
        output = [];
        if nargin > 1
            twotheta = this.TwoTheta;
            fcnCoeffNames = this.FitFunctions{fcnID}.getCoeffs;
            
            for i=1:length(fcnCoeffNames)
                idx(i) = find(strcmpi(this.CoeffNames, fcnCoeffNames{i}),1);
            end
            
            coeffvals = this.CoeffValues(idx);
            output = this.FitFunctions{fcnID}.calculateFit(twotheta, coeffvals);
        
        else
             for i=1:length(this.FitFunctions)
                output(i,:) = this.calculatePeakFit(i);
            end
        end
        end

        function writeParametersToFile(this, fid, varargin)
        %PRINTPARAMETERS writes the parameters used to get this fit into the file specified by the
        %   file FID.
        
        
        
        
        end
        
        function printMasterFile(this, fid)
        %PRINTMASTERFILE print
        GOFvals = struct2cell(this.FmodelGOF);
        fprintf(fid, '%#.5g\t', GOFvals{:});
        fprintf(fid, '%#.5g\t', this.FmodelCI(1,:));
        fprintf(fid, '%#.5g\t', this.FmodelCI(2,:));
        fprintf(fid, '\n');
        end


        function printFmodelFile(this, fid)
        
        fprintf(fid, 'This is an output file from a MATLAB routine.\n');
        fprintf(fid, 'The following peaks are all of the type: ');
        fprintf(fid, '%s; ', this.FunctionNames{:});      % write function names
        fprintf(fid, '%s\t', this.CoeffNames{:});         % write coefficient names
        fprintf(fid, '%s\t', fieldnames(this.FmodelGOF)); % write GOF names

        %third output Confidence Intervals (CI)
        for i=1:length(this.CoeffNames)
            fprintf(fid, '%s\t', ['LowCI:', this.CoeffNames{i}]); %write LB names
            fprintf(fid, '%s\t', ['UppCI:', this.CoeffNames{i}]); %write UB names
        end
        fprintf(fid, '\n');
        end

        function printFdataFile(this, fid)
        fprintf(fid, 'This is an output file from a MATLAB routine.\n');
        fprintf(fid, 'All single peak data (column 3+) does not include background intensity.\n');
        fprintf(fid, '2theta \t IntMeas \t BkgdFit \t Peak1 \t Peak2 \t Etc...\n');
        
        twotheta = this.TwoTheta';
        background = this.Background';
        peaks = this.FData;
        totalfit = this.Background 
        
        for i=1:(size(dataMatrix,1)-1);
            dataformat = strcat('%f\t',dataformat);
        end
        fprintf(fid, dataformat, dataMatrix);
        fclose(fid);
        
        end
    end
end

