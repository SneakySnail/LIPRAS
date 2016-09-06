classdef PeakFitManager < handle
		%UNTITLED2 Summary of this class goes here
		%   Detailed explanation goes here
		
		properties
				hfig; %  [1x1 Figure]
				uipanel17; %  [0x0 GraphicsPlaceholder]
				uipanel18; %  [0x0 GraphicsPlaceholder]
				panel_rightside; %  [1x1 Panel]
				uipanel3; %  [1x1 Panel]
				uipanel2; %  [1x1 Panel]
				checkbox_lambda; %  [1x1 UIControl]
				edit_lambda; %  [1x1 UIControl]
				uipanel1; %  [1x1 Panel]
				edit7; %  [1x1 UIControl]
				edit_max2t; %  [1x1 UIControl]
				edit_min2t; %  [1x1 UIControl]
				uipanel10; %  [1x1 Panel]
				popup_numpeaks; %  [1x1 UIControl]
				text_filenum; %  [1x1 UIControl]
				popup_filename; %  [1x1 UIControl]
				push_viewall; %  [1x1 UIControl]
				radiobutton1; %  [1x1 UIControl]
				checkbox10; %  [1x1 UIControl]
				axes2; %  [1x1 Axes]
				axes1; %  [1x1 Axes]
				push_nextprofile; %  [1x1 UIControl]
				push_prevprofile; %  [1x1 UIControl]
				uipanel4; %  [1x1 Panel]
				uipanel16; %  [1x1 Panel]
				text_numprofile; %  [1x1 UIControl]
				push_addprofile; %  [1x1 UIControl]
				push_removeprofile; %  [1x1 UIControl]
				button_browse; %  [1x1 UIControl]
				edit8; %  [1x1 UIControl]
				push_newbkgd; %  [1x1 UIControl]
				togglebutton_showbkgd; %  [1x1 UIControl]
				edit_bkgdpoints; %  [1x1 UIControl]
				edit_polyorder; %  [1x1 UIControl]
				push_update; %  [1x1 UIControl]
				uipanel6; %  [1x1 Panel]
				uipanel5; %  [1x1 Panel]
				pushbutton17; %  [1x1 UIControl]
				push_default; %  [1x1 UIControl]
				push_fitdata; %  [1x1 UIControl]
				uitable1; %  [1x1 Table]
				popup_function6; %  [1x1 UIControl]
				popup_function5; %  [1x1 UIControl]
				popup_function4; %  [1x1 UIControl]
				popup_function3; %  [1x1 UIControl]
				popup_function2; %  [1x1 UIControl]
				popup_function1; %  [1x1 UIControl]
				checkboxm; %  [1x1 UIControl]
				checkboxw; %  [1x1 UIControl]
				checkboxf; %  [1x1 UIControl]
				checkboxN; %  [1x1 UIControl]
				tabgroup; %  [1x1 TabGroup]
				tab_setup; %  [1x1 Tab]
				tab_peak; %  [1x1 Tab]
				profiles; %  [1x7 Panel]
				xrd; %  [1x1 PackageFitDiffractionData]
				text_status; %  [1x1 com.mathworks.mwswing.MJStatusBar]
				
		end
		
		properties (Access = private)
				handles; % handle from FDGUI
				xrdContainer; %  [1x6 PackageFitDiffractionData]
				output; %  [1x1 Figure]
				
		end
		
		methods
				
				function this = PeakFitManager
				this.handles = guihandles(FDGUI);
				
				end
				
				
		end
		
end

