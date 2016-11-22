% Contains the data for each profile as it is updated in the GUI. It is completely independent from the
% PackageFitDiffractionData class.
classdef GuiData < handle
	properties
		nProfiles = 0;
        iProfile;
        Filename;
		
	end
	
	properties (SetObservable)
		
    end
    
    properties (Hidden)
        ProfileData;
    end
    
    properties (Dependent)
        Min2t;
        Max2t;
        PolyOrder;
        bModel; % background model name
        nBkgdPoints;
        
        nPeaks;
        PeakPositions;
        lambda;
        PSfxn;
        Constraints;
        fitrange;
        fit_initial;
    end
    
    
	methods
        function this = GuiData
            
        end
        
        
	end
	
end

% classdef myObj2 < handle
% 
% properties
%     myStruct = struct('myField', []);
% end
% 
% events
%     myFieldChanged
% end
% 
% methods
%     function self = myObj2(fieldVal)
%         self.myStruct.myField = fieldVal;
%         addlistener(self, 'myFieldChanged', @self.callbackFnc);
%     end
% 
%     function set.myStruct(obj, val)
%         oldProp = obj.myStruct;
%         obj.myStruct = val;
%         if obj.myStruct.myField ~= oldProp.myField
%             notify(obj,'myFieldChanged')
%         end
%     end
% 
%     function callbackFnc(self, varargin)
%         fprintf(['self.myStruct.myField is now ', num2str(self.myStruct.myField), '\n'])
%     end
% 
% end
% 
% end