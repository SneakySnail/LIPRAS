classdef ProfileData < handle
	properties
		xrd;
		min2t;
		max2t;
		
	end
	
	properties (SetObservable)
		
	end
	
	methods
		
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