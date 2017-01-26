classdef FitResults
    %FITRESULTS
    
    properties (SetAccess = protected)
        % A ProfileData instance
        Profile
        
        
        % Fitted intensity results for each file per row
        IntensityFit
        
        % Possible make into a function only
        IntensityFitError
        
        
        % i.e. PackageFitDiffractionData.fit_parms
        % List of cells containing coeffvalues from the fit. Identical to
        %   PackageFitDiffractionData.fit_parms
        CoeffValues
        
        % i.e. PackageFitDiffractionData.fit_parms_error
        % List of cells containing coeffvalues error. Identical to
        %   PackageFitDiffractionData.fit_parms_error
        CoeffValuesError
    end
    
    properties (SetAccess = protected, Hidden)
        Fmodel
        FmodelGOF
        FmodelCI
        
        
    end
    
    methods
        function this = FitResults(profiledata)
        this.Profile = profiledata;
        
        
        
        end
    end
    
    methods
        
        
        
    end
    
    methods (Static)
        
        
        
        
        
    end
    
    
    methods
        
        function this = saveIntensity(this)
        
        end
        
    end
    
end

