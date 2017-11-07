classdef LiprasDialogCollection
    % Class method to hold static functions that create dialog boxes.
    properties (Constant)
        ScreenSize = get(0, 'ScreenSize');
        HelpDlgTitle = 'LIPRAS Help';
    end
    
    methods (Static)
        function dlg = createCSHelpDialog()
        %csHelpDialog creates a help dialog if one doesn't already
        %exist and returns the handle to it. 
        import ui.LiprasInteractiveHelp
        helpStr = LiprasInteractiveHelp.OpeningHelpStr;
        
        dlg = helpdlg(helpStr, LiprasDialogCollection.HelpDlgTitle);
        set(dlg, 'DeleteFcn', @(o,e)helpDlg_DeleteFcn(o,e));
        utils.figAlwaysOnTop(dlg);
        end
        
        function dlg = fittingDataSet()
        % Creates a dialog box with a Cancel button while waiting for fitting to complete.
        dPosition = LiprasDialogCollection.centeredPosition([400 150]);
        msg = {'Peak fitting in progress. Please wait...', '', ...
                'Close this window or minimize to continue working. Press "Cancel" to stop fit.'};
        dlg = dialog('Name', 'Fitting Dataset...', ...
                     'Position', dPosition, ...
                     'WindowStyle', 'normal');
        uicontrol(dlg, 'Style', 'text', ...
                  'String', msg, ...
                  'FontName', 'default', ...
                  'FontSize', 11, ...
                  'Units', 'normalized', ...
                  'tag', 'text', ...
                  'Position', [0.05 0.45 0.9 0.5]);
        btnSize = [75 40];
        uicontrol(dlg, 'Style', 'pushbutton', ...
                 'Tag', 'btn', ...
                 'String', 'Cancel', ...
                 'FontName', 'default', ...
                 'FontSize', 11, ...
                 'Units', 'pixels', ...
                 'Position', [0.5*[dPosition(3)-btnSize(1), 0.6*dPosition(4)-btnSize(2)], btnSize], ...
                 'Callback', 'delete(gcf)');
        end
        
        function dlg = PolyNotUniqueWarning()
        % Issues a warning dialog when the number of background points is less than the background
        % polynomial order.
        msg = 'Polynomial is not unique; Polynomial order must be  > number of data points. Add more points to continue.';
        dlg = warndlg(msg, 'Warning');
        set(dlg, 'WindowStyle', 'modal', ...
            'WindowKeyPressFcn', 'delete(gcf)');
        end
        
        function exportPlotAsImage(handles)
        %exportPlotAsImage prompts the user to select a file output format
        % and saves the fit 
        try
        close figure 2
        catch
        end
        
        name = 'Export Plot';
        prompt = 'Select the output format:';
        listed = {'TIFF','JPEG','PNG','PDF','BMP','EPSC','SVG'};
        id=find(contains(listed,handles.profiles.ImageFormat));
        okString = 'Save';
        defaultFontSize = get(0,'DefaultUIControlFontSize');
        set(0,'DefaultUIControlFontSize',11);
        [selected, ok] = listdlg('Name', name, 'SelectionMode', 'single', 'PromptString', prompt,...
            'ListString', listed, 'ListSize', [175 120], 'okstring', okString,'InitialValue',id);
        set(0, 'DefaultUIControlFontSize', defaultFontSize);
        dpi=strsplit(handles.profiles.ImageRes);
        listed=lower(listed);

        if ok % if user presses ok, then begin save
            
            outpath = [handles.profiles.Writer.OutputPath 'ExportedImages' filesep];
            oldpath = pwd;
            
            if handles.profiles.UniqueSave % if UniqueSave is toogled it will create new folders
                index = 0;
                iprefix = '00';
            while exist(strcat(outpath,'Image_',strcat(iprefix,num2str(index))),'dir') ==7
                index = index + 1;
                if index > 100
                    iprefix = '';
                elseif index > 10
                    iprefix = '0';
                end
            end
            outpath=strcat(outpath,'Image_',strcat(iprefix,num2str(index)), filesep);  
            mkdir(outpath)
            else
            if exist(outpath,'dir')==0 % incase user deletes this folder
                mkdir(outpath)
            end
            end
            
            if ~isdir(outpath)
                mkdir(outpath);
            end
            cd(outpath); % changes to directory to begin writting files
            
                if or(~handles.profiles.ImageSaveAll, handles.radio_coeff.Value) % for Single image saving
                    
                    filename = handles.gui.FileNames{handles.gui.CurrentFile};
                    [~, filename, ~] = fileparts(filename);        
                    fig = figure('position', [50 50 500 500], 'tag', 'exportplotfig', 'Visible', 'off');
                    ax = copyobj(handles.axes1, fig);
                    lgd = legend(ax, 'show','location','best');
                    set(lgd, 'FontSize', 9, 'Box', 'off');
                    set(ax.YLabel, 'FontSize', 12);
                    set(ax.XLabel, 'FontSize', 12);
                    set(ax.Title, 'FontSize', 12);
                    ax.Position(2)=ax.Position(2)+.03;
                    set(ax,'Position',ax.Position); % could not be universal
                    if handles.radio_coeff.Value
                    filename=strcat(filename,'-Coeffs');
                    end
                    print(fig, filename, strcat('-d',listed{selected}), strcat('-r', dpi{1}));

                else % ===Saving all image of all files that were fit===
                    
                    tt=handles.profiles.getProfileResult{1}.TwoTheta;
            
            for jj=1:length(handles.popup_filename.String)
                filename = handles.gui.FileNames{jj};
                [~, filename, ~] = fileparts(filename);
                
                bkg=handles.profiles.getProfileResult{jj}.Background;
                peaks=handles.profiles.getProfileResult{jj}.FPeaks;
                fit=handles.profiles.getProfileResult{jj}.FData;
                data=handles.profiles.xrd.getData(jj);

if contains(handles.profiles.FitResults{1}{1}.CoeffNames{1},'bkg') % for when Bkg was refined
                    if jj>1                        
                        if ~ishandle(figa(1))
                            return
                        end
                yybkg=[data;fit;bkg;peaks+bkg];
                set(figa(1),'YData',yybkg(1,:));
                set(figa(2),'YData',yybkg(2,:));
                set(figa(3),'YData',yybkg(3,:));
                    for m=1:size(peaks,1) % shapes to size of peaks
                    set(figa(m+3),'YData',yybkg(m+3,:));
                    end
                title(figax,filename)
                legend(hLegend.String,'box','off','Location','best','FontSize',9);
                print(figas, filename, strcat('-d',listed{selected}), strcat('-r', dpi{1}));                
                    else    % For the first file             
                yy=[data;fit;bkg;peaks+bkg];
                figure(2)
                figa=plot(tt,yy,'--','LineWidth',1.5);
                set(figa(1),'MarkerFaceColor',[0.08 0.17 0.65],'MarkerEdgeColor','none','Marker','o','MarkerSize',5,'LineStyle','none');
                set(figa(2),'LineWidth',1,'Color',[0 .5 0],'LineStyle','-');
                set(figa(3),'Color',[1 0 0],'LineStyle','--');
                xlabel('2\theta')
                ylabel('Intensity (a.u.)')
                xlim([handles.gui.Min2T handles.gui.Max2T]);
                if handles.radio_coeff.Value
                else
                xlim(handles.axes1.XLim);
                end
                figas=gcf;
                figax=gca;
                hLegend = findobj(handles.figure1, 'Type', 'Legend');
                legend(hLegend.String,'box','off','Location','best','FontSize',9);
                set(0, 'CurrentFigure', figas);  %# for figures
                set(figax,'FontSize',12);
                title(figax,filename,'Interpreter','none')
                print(figas, filename, strcat('-d',listed{selected}), strcat('-r', dpi{1}));
                    end
                    
else % ===BkgLS Not on===                
if jj>1
        yybkg=[data;fit+bkg;bkg;peaks+bkg];
        set(figa(1),'YData',yybkg(1,:));
        set(figa(2),'YData',yybkg(2,:));
        set(figa(3),'YData',yybkg(3,:));

        for m=1:size(peaks,1) % shapes to size of peaks
        set(figa(m+3),'YData',yybkg(m+3,:));
        end
                title(figax,filename)
                legend(hLegend.String,'box','off','Location','best','FontSize',9);
                print(figas, filename, strcat('-d',listed{selected}), strcat('-r', dpi{1}));
else
                yy=[data;fit+bkg;bkg;peaks+bkg];
                figure(2)                           
                figa=plot(tt,yy,'--','LineWidth',1.5);
                set(figa(1),'MarkerFaceColor',[0.08 0.17 0.65],'MarkerEdgeColor','none','Marker','o','MarkerSize',5,'LineStyle','none');
                set(figa(2),'LineWidth',1,'Color',[0 .5 0],'LineStyle','-');
                set(figa(3),'Color',[1 0 0],'LineStyle','--');
                xlabel('2\theta')
                ylabel('Intensity (a.u.)')
                xlim([handles.gui.Min2T handles.gui.Max2T]);
                if handles.radio_coeff.Value
                else
                xlim(handles.axes1.XLim);
                end
                figas=gcf;
                figax=gca;
                hLegend = findobj(handles.figure1, 'Type', 'Legend');
                legend(hLegend.String,'box','off','Location','best','FontSize',9);
                set(0, 'CurrentFigure', figas);  %# for figures
                set(figax,'FontSize',12);
                title(figax,filename,'Interpreter','none')
                print(figas, filename, strcat('-d',listed{selected}), strcat('-r', dpi{1}));
end
end
            end
                        cd(oldpath);           
                end
        handles.gui.PriorityStatus = 'Successfully exported plot as an image file.';
        close figure 2
        end
        
        end
        
        function pos = centeredPosition(dSize)
        % Returns a 1x2 numeric array POS of the position the dialog box of size DSIZE should be 
        %   located to be centered on the screen.
        pos = 0.5*[LiprasDialogCollection.ScreenSize(3)-dSize(1), ...
                   LiprasDialogCollection.ScreenSize(4)-dSize(2)];
        pos = [pos dSize];
        end
    end
end

function helpDlg_DeleteFcn(hObject, ~)
%helpDlg_DeleteFcn executes when the cshelp dialog box is closed.
helper = getappdata(hObject, 'helper');
try
    if ~isempty(helper.hFig) && isvalid(helper.hFig)
        handles = guidata(helper.hFig);
        handles.gui.HelpMode = 'off';
    end
catch ME
    errordlg(getReport(ME))
end
delete(hObject);
end