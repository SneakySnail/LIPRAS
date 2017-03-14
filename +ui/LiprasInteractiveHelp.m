classdef LiprasInteractiveHelp < handle
    %LIPRASINTERACTIVEHELP is a class to manage what the GUI will do when the 
    %   context-sensitive help (CS) for the Lipras figure is activated. 
    %   To activate the context-sensitive help, type
    %       handles.figure1.CSHelpMode = 'on';
    %   To turn it off, type
    %       handles.figure1.CSHelpMode = 'off';
    %   When CS help is turned on, clicking on any object in the figure
    %   executes the figure's HelpFcn callback.  This callback function
    %   can implement any desired context-sensitive help format, which 
    %   are defined in the methods below.
    %
    %   See also UTILS.CSHELP
    
    %   Author(s): Klarissa Ramos 03/2017
    
    properties
        hFig % handle to the figure where cshelp is turned on
    end
   
    properties (Hidden)
        % handle to the help dialog used to display information about the 
        % clicked object. If the user closes the help dialog, CSHelpMode 
        % is also turned off.
        HelpDlg_ 
        HelpStr_
    end
    
    % Tex-enabled help messages for components in the GUI
    properties (Constant, Hidden)
        Formatting     = {'\fontsize{11}'};
        OpeningHelpStr = {'Welcome to the interactive help for LIPRAS!' ... 
                          '' ...
                          'Click on anything inside the figure to learn more about it.' ...
                          ''
                          'Close this dialog or '};
        
    end
  
    properties (Dependent)
        % The string to display in the help dialog when an 
        % object in the figure is clicked
        HelpStr 
    end
    
    methods (Access = private)
        function this = LiprasInteractiveHelp(fig)
        % Constructor
        
        this.hFig = fig;
        end
    end
       
    methods
        function helpModeDidTurnOn(this, fig)
        % Executes when the help mode for FIG is turned on. It creates and returns
        %   a new help dialog that is always on top.
        dlg = LiprasDialogCollection.createCSHelpDialog();
        this.HelpDlg_ = dlg;
        setappdata(dlg, 'helper', fig);
        end


        function edit_2T_HelpFcn(hObject, evt)
        %EDIT_2T_HELPFCN executes when the edit 2T boxes are clicked while 
        %   CSHelpMode is on.
        end
        
        function backgroundEditMode_HelpFcn(hObject, evt)
        %BACKGROUNDEDITMODE_HELPFCN executes when anything inside the 
        %   background's Edit Mode panel is clicked while CSHelpMode is on.
        
        end
        
        
    end
    
    methods
        function set.HelpStr(this, str)
        this.HelpStr_ = str;
        
        end
        
        function str = get.HelpStr(this)
        str = this.HelpStr_;
        end
    end
    
    methods (Static)
        function init(fig)
        %INIT initializes the Lipras interactive help for the figure
        %   specified by FIG. It adds HelpFcn callbacks to fig objects.
        utils.cshelp(fig);
        set(fig, 'HelpFcn', @(o,e)fig_HelpFcn(o,e));
        setappdata(fig, 'helper', ui.LiprasInteractiveHelp(fig));
        end  
        
    end
    
end


function fig_HelpFcn(dlg, evt)
%FIG_HELPFCN is the callback function that executes when the
%   user clicks somewhere inside the figure if `CSHelpMode`
%   is turned on.

% Open a help dialog
clickedObj = gco;

end
