classdef DiffractionData
    %DIFFRACTIONDATA Contains the raw data to be used for fitting.
    
    properties
        FileName
        DataPath
        Min2T
        Max2T
        
    end
    
    properties (Hidden, GetAccess = protected, SetAccess = immutable)
        FullTwoTheta
        FullIntensityData
    end
    
    properties (Hidden)
        FileIndex
        
    end
    
    methods
        function this = DiffractionData(data, filename, fileIndex)
        % Constructor
        this.FullTwoTheta = data.two_theta(fileIndex,:);
        this.FullIntensityData = data.data_fit(fileIndex,:);
        [path, name, ext] = fileparts(filename);
        this.DataPath = path;
        this.FileName = [name ext];
        this.Min2T = min(this.FullTwoTheta);
        this.Max2T = max(this.FullTwoTheta);
        this.FileIndex = fileIndex;
        end
    end
    
    methods
        
        function result = getDataIntensity(this, range)
        %GETDATAINTENSITY Returns the intensity data in the range specified by
        %   the argument 'range'. If the range isn't specified, it uses the
        %   Min2T and Max2T properties.
        %
        %RANGE - 1x2 numeric array of the two theta range
        if nargin < 2
            range = [this.Min2T this.Max2T];
        end
        
        indices = utils.findIndex(this.FullTwoTheta, range);
        
        result = this.FullIntensityData(indices(1):indices(2));
        end
        
        function result = getDataTwoTheta(this, range)
        %GETDATATWOTHETA Returns the two theta points in the range specified in the
        %   argument 'range'. If the range isn't specified, it uses the Min2T
        %   and Max2T properties.
        %
        %RANGE - 1x2 numeric array of the two theta range
        if nargin < 2
            range = [this.Min2T this.Max2T];
        end
        
        indices = utils.findIndex(this.FullTwoTheta, range);
        
        result = this.FullTwoTheta(indices(1):indices(2));
        end
        
    end
    
    methods (Static)
        function answer = isXRDML()
        answer = false;
        end
        
    end
    
end

