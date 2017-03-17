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
        hFig % handle to the figure where cshelp was turned on
    end
   
    properties (Hidden)
        % handle to the help dialog used to display information about the 
        % clicked object. If the user closes the help dialog, CSHelpMode 
        % is also turned off.
        HelpDlg_ 
        HelpStr_ = '';
    end
    
    % Tex-enabled help messages for components in the GUI
    properties (Constant, Hidden)
        Format         = '\fontsize{11}';
        OpeningHelpStr = {'Welcome to the interactive help for LIPRAS!' ... 
                          '' ...
                          'To learn more about what each button does, click on anything inside the figure.' ...
                          '' ...
                          'Close this window to exit Help Mode.'};
        
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
        % Executes when the help mode for FIG is turned on. It creates
        %   a new help dialog that is always on top and returns it.
        dlg = LiprasDialogCollection.createCSHelpDialog();
        setappdata(dlg, 'helper', this);
        setappdata(this.hFig, 'hDlg', dlg);
        end
        
        function set.HelpStr(this, str)
        this.HelpStr_ = str;
        title = LiprasDialogCollection.HelpDlgTitle;
        oldDlg = getappdata(this.hFig, 'hDlg');
        if isempty(oldDlg) || ~isvalid(oldDlg)
            location = this.hFig.Position(1:2);
        else
            location = oldDlg.Position(1:2);
        end
        dlg = helpdlg(str, title);
        set(dlg, 'Position', [location dlg.Position(3:4)]);
        
        setappdata(dlg, 'helper', this);
        setappdata(this.hFig, 'hDlg', dlg);
        end
        
        function str = get.HelpStr(this)
        str = this.HelpStr_;
        end
        
        function helpModeDidTurnOff(this, fig)
        % Executes when the help mode for FIG is turned off. Deletes
        % the help dialog if it exists
        delete(this.HelpDlg_);
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

% Default message to display if there is no tooltip
noHelpYetString = {'Sorry, there is no help available yet.', ...
                   '', ...
                   'Coming soon!'};
try
    clickedObj = gco;
    helper = getappdata(dlg, 'helper');
    msg = clickedObj.TooltipString;
    if isempty(noHelpYetString)
        msg = noHelpYetString;
    end
catch ME
    msg = noHelpYetString;
end

helper.HelpStr = msg;
end
