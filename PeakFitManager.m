classdef PeakFitManager < handle
		%UNTITLED2 Summary of this class goes here
		%   Detailed explanation goes here
		
		properties
				
				
		end
		
		properties (Access = private)
				hgui; % FDGUI handles structure
		end
		
		methods
				
				function this = PeakFitManager
				this.hgui = guihandles(FDGUI);
				
				end
				
				
		end
		
end

