% Properties needed: datatype, DisplayName, ColorOrder
function  plotX(app, mode, varargin)
% All lines that would require re-plotting in d-space are initially not visible. They become visible
% after calling plotter.XScale.
persistent previousPlot_
try
    plotter = utils.plotutils.AxPlotter(app);
    filenum = app.DropDown.Value;
    filenames = app.profiles.FileNames;
    xrd = app.profiles.xrd;
    if nargin < 2
        if isempty(previousPlot_)
            mode = plotter.Mode;
        else
            mode = previousPlot_;
        end
    else
        if isempty(previousPlot_) && isempty(mode)
            mode = 'data';
        elseif isempty(mode)
            mode = previousPlot_;
        end
    end
    
    
%     app.checkbox_superimpose.Value = 0; % to superimpose data
    % try
    
        % Disable the figure while its plotting
%     focusedObj = gcbo;
%     enabledObjs = findobj(app.figure1,'Tag','listbox_results');
%     set(enabledObjs, 'enable', 'inactive');
    
    switch lower(mode)
        case 'data'
            plotData(app, mode);
%             resizeAxes1ForErrorPlot(app, 'data');
            previousPlot_ = 'data';
        case 'background'
            plotData(app,mode);
            if app.profiles.xrd.hasBackground
                plotBackgroundPoints(app);
                plotBackgroundFit(app);
            end
            previousPlot_ = 'background';
        case 'backgroundpoints'
            plotBackgroundPoints(app);
            
        case 'backgroundfit'
            plotBackgroundFit(app);
        case 'limits'
            updateLim(app);
        case 'superimpose'
            plotSuperimposed(app);
            utils.plotutils.resizeAxes1ForErrorPlot(app, 'data');
        case 'fit'
            R1=num2str(round(app.profiles.FitResults{1}{filenum}.Rp,4));
            R2=num2str(round(app.profiles.FitResults{1}{filenum}.Rwp,4));
            R3=num2str(round(app.profiles.FitResults{1}{filenum}.Rchi2,4));
            Resi1=['Rp:' ' ' R1 ' %'];
            Resi2=['Rwp:' ' ' R2 ' %'];
            Resi3=['GOF:' ' ' R3];
%             app.FitStats1.FontSize=11; app.FitStats1.FontWeight='bold';            
%             app.FitStats2.FontSize=11; app.FitStats2.FontWeight='bold';          
%             app.FitStats3.FontSize=11; app.FitStats3.FontWeight='bold'; 
%             app.FitStats1.String=Resi1;
%             app.FitStats2.String=Resi2;
%             app.FitStats3.String=Resi3;
%             app.FitStats1.Visible='on';
%             app.FitStats2.Visible='on';
%             app.FitStats3.Visible='on';

%             resizeAxes1ForErrorPlot(app, 'fit');


            delete(app.UIAxes.Children(~contains({app.UIAxes.Children.Tag},'Obs'))) % deletes all but whatever is specified in Tag

            plotData(app,mode);
            plotFitError(app);
            plotFit(app, app.UIAxes, app.DropDown.Value);
            previousPlot_ = 'fit';
        case 'sample'
            plotSampleFit(app,mode);
            previousPlot_ = 'sample';
        case 'allfits'
            plotAllFits(app);
        case 'error'
            plotFitError(app);
            utils.plotutils.resizeAxes1ForErrorPlot(app, 'fit');
        case 'coeff' %TODO
            plotCoefficients(app);
            previousPlot_ = 'coeff';
        case 'stats' %TODO
            plotFitStats(app);
    end
    plotter.Mode = previousPlot_;
    app.gui.Legend = 'reset';
    set(app.UIAxes.Children,'visible','on');
    if strcmp(previousPlot_,'fit')
       set(app.UIAxes2.Children,'visible','on');
    end
    
%     set(enabledObjs, 'Enable', 'on');
%     currentFig = get(0,'CurrentFigure');
%     if ~isempty(currentFig) && contains(currentFig.Name, 'LIPRAS') && ~isempty(focusedObj)
%         if strcmpi(focusedObj.Type, 'uitable')
%             uitable(focusedObj);
%         elseif isfield(focusedObj,'Style') && strcmpi(focusedObj.Style, 'listbox') % no focusedObk.Style is created
%             uicontrol(focusedObj); % why is this here?
%         end
%     end
    app.gui.Legend = 'reset';
catch ex
    ex.getReport
%     set(enabledObjs, 'Enable', 'on');
    errordlg(ex.message)
end


    function dataLine = plotData(app, mode, axx, j)
    % PLOTDATA Plots the Obs data for a specified file number in axes1. 
    %     If there are lines, remove all other lines except data line
    if strcmp(mode,'fit')~=1
        axx = app.UIAxes;
        ydata = xrd.getData(filenum);
    elseif and(strcmp(mode,'fit')==1,nargin< 3)
        axx = app.UIAxes;
        ydata = xrd.getData(filenum);
    else
        ydata = xrd.getData(j);
    end
    dataLine = findobj(axx, 'tag', 'Obs'); % produces 0x0 Graphic placeholder
    notDataLineIdx = ~strcmpi(get(dataLine, 'DisplayName'), 'Measured Data');
    if ~isempty(dataLine)
        delete(dataLine(notDataLineIdx));
        dataLine = dataLine(~notDataLineIdx);
    end
    xdata = xrd.getTwoTheta(filenum);
    props = {'LineStyle', '-', 'LineWidth', 1, 'MarkerFaceColor', [1 1 1], ...
        'Color', 'k', 'Visible', 'on', 'MarkerSize', 5};
    if isvalid(dataLine)

        setappdata(dataLine, 'xdata', xdata);
        setappdata(dataLine, 'ydata', ydata);
        handles.gui.Plotter.transform(dataLine);
%         drawnow;

    elseif nargin==4
                dataLine = plotter.plotObsData(axx, ...
                            'LineStyle', '-', ...
                            'LineWidth', 1, ...
                            'MarkerFaceColor', [1 1 1], ...
                            'Color', 'k', ...
                            'Visible', 'on');
            line = plot(axx,xdata,ydata,'o',...
            'DisplayName', 'Measured Data', ...
            'tag', 'Obs', ...        setappda
            'MarkerFaceColor', [1 1 1], ...
            'MarkerEdgeColor', 'auto', ...
            'MarkerSize', 5, ...
            'visible', 'on');

                        
        filenum=j;                
        dataLine = findobj(axx, 'tag', 'Obs');
        xdata = xrd.getTwoTheta(j);
        set(dataLine, 'XData', xdata, 'YData', ydata);
        setappdata(dataLine, 'xdata', xdata);
        setappdata(dataLine, 'ydata', ydata);
%         app.gui.Plotter.transform(dataLine);
    else
        dataLine = plotter.plotObsData(axx, ...
                            'LineStyle', '-', ...
                            'LineWidth', 1, ...
                            'MarkerFaceColor', [1 1 1], ...
                            'Color', 'k', ...
                            'Visible', 'on');
    end
    plotter.updateXYLim(axx,mode);
    end

    function plotFit(app, ax, fileID)
    % Plots the current fit in app.axes1
    import utils.plotutils.*
    if nargin < 2
        ax = app.UITable;
        fileID = filenum;
    end
    fitted = app.profiles.getProfileResult{fileID};
    % Obs Data
    dataLine = findobj(ax, 'tag', 'Obs');
    set(dataLine, 'LineStyle', 'none', 'MarkerSize', 3.5, 'MarkerFaceColor', [0.08 .17 0.65],'MarkerEdgeColor',[0.08 0.17 0.65]);
    plotOverallFit(app, ax,fitted);
    if app.profiles.xrd.BkgLS % background specific to BkgLS otherwise, peaks undershoot in plot window
    plotBgFit(app, ax,filenum,fitted.Background);
    else
    plotBgFit(app, ax,filenum);
    end
    for ii=1:xrd.NumFuncs
        plotFittedPeak(app,ax,fitted,ii);
    end
%     if isequal(ax, app.UIAxes) % not supported for UIAxes
%         linkaxes([app.UIAxes app.UIAxes2], 'x');
%     end
    if nargin < 2
        updateXYLim(app, app.UIAxes);
    end
    if ~strcmp(previousPlot_, 'fit')
        app.gui.Legend = 'reset';
    end
    app.UIAxes2.Visible=1;
    end

    function plotFitError(app)
    fitted = app.profiles.getProfileResult{filenum};
    plotFitErr(app,app.UIAxes2, fitted);
    
    end

% Plot an example fit using the starting values from table.
    function app = plotSampleFit(app,mode)

    
     if ~strcmpi(plotter.Mode, mode)
        cla(app.UIAxes);
     end
  plotData(app,mode,app.UIAxes,app.DropDown.Value);
  plotBackgroundFit(app);
    
    if ~canPlotSample(app)
        return
    end
    % Plot background fit
    plotBgFit(app, app.UIAxes, app.DropDown.Value, app.profiles.xrd.calculateBackground);    
    for i=1:xrd.NumFuncs
        plotSamplePeak(app ,app.UIAxes, i);
    end
%     utils.plotutils.resizeAxes1ForErrorPlot(app, 'data');

    updateXYLim(app,app.UIAxes,'sample'); % this always comes from sample
    end

    function plotSuperimposed(app)
    % Like plotData, except turns on hold to enable multiple
    %    data to be plotted in app.axes1.
    import utils.plotutils.*
    if ~ishold(app.UIAxes)
        hold(app.UIAxes, 'on');
    end
    lines = app.UIAxes.Children;
    %     If there are lines, remove all other lines except data line
    notDataLineIdx = ~strcmpi(get(lines, 'tag'), 'superimposed');
    if ~isempty(lines)
        delete(lines(notDataLineIdx));
    end
    app.menuPlot_superimpose.Checked='on';
    activeFileLinePlot = findobj(app.UIAxes, 'DisplayName', filenames{filenum});
    if isempty(activeFileLinePlot)
        % If not already plotted, add to plot
        plotter.plotObsData(app.UIAxes,...
                            'Tag', 'superimposed', ...
                            'LineStyle',':',...
                            'LineWidth', 0.8,...
                            'DisplayName',filenames{filenum}, ...
                            'MarkerFaceColor', 'none');
        % If already plotted && is not the only plotted data, delete line
    else
        if length(app.UIAxes.Children) > 1
            delete(activeFileLinePlot);
        end
    end
    app.gui.Legend = 'on';
    app.gui.Legend = 'reset';
    updateXYLim(app,app.UIAxes);
    end

% Makes a new figure and plots each fit for the entire dataset.
    function plotAllFits(app)
    import utils.plotutils.*
    try
        screen = get(0, 'ScreenSize');
        nRows = floor(sqrt(xrd.NumFiles));
        nColumns = ceil(xrd.NumFiles/nRows);
        fWidth = min(400*nColumns, screen(3));
        fHeight = min(400*nRows, screen(4));
        wPos = (screen(3)-fWidth)/4;
        hPos = (screen(4)-fHeight)/4;
        delete(findall(0, 'tag', 'AllFitsFig'));
        f = figure('Name', 'Plot All Fits', ...
            'tag', 'AllFitsFig', ...
            'Units', 'pixels', ...
            'Position', [wPos hPos fWidth fHeight], ...
            'Visible', 'off');
        ax = gobjects(1,xrd.NumFiles);
        for j=1:xrd.NumFiles
            ax(j) = subplot(nRows, nColumns, j);
            if ~ishold(ax(j))
                hold(ax(j), 'on');
            end
            dataLine = plotData(app, 'fit',ax(j),j); % 'fit' added to be specific with which function its coming from
            set(dataLine, 'LineStyle', 'none', ...
                'MarkerSize', 3.5, ...
                'MarkerFaceColor', [0 0.18 0.65]);
            plotFit(app, ax(j), j);
            
            filename = filenames{j};
            title(ax(j), [filename ' (' num2str(j) ' of ' num2str(length(filenames)) ')'], ...
                'Interpreter', 'none', ...
                'FontSize', 12, ...
                'FontName','default');
        end
        linkaxes(ax,'xy');
        set(ax, 'box', 'on');
        set(findobj(f), 'Visible', 'on');
        plotter.updateXLabel(ax);
        plotter.updateYLabel(ax);
    catch exception
        delete(f);
        rethrow(exception)
    end
end

    function plotCoefficients(app)
    cla(app.UIAxes)
%     if app.panel_choosePlotView.SelectedObject ~= app.radio_coeff %
%     commneted out on 07/03/2020
%         keyboard % delete -- testing only
%         return
%     end
%     utils.plotutils.resizeAxes1ForErrorPlot(app, 'data');    
    hTable = app.UITable3;
    row = app.FilesListBox.Value;
    NumCoef_all=size(hTable.Data,1);
    NumCoef=length(app.FilesListBox.Items);
    if NumCoef_all~=NumCoef %for when bkg was refined, this way bkg coeffs dont get plotted
        row=NumCoef_all-NumCoef+row;
    end
    CI = zeros(1, app.profiles.NumFiles);
    for gh=1:app.profiles.NumFiles
        fitted = app.profiles.FitResults{1}{gh};
        CI(gh) = fitted.FmodelCI(1,row);
    end
    rowvals = cell2mat(hTable.Data(row,:));
    err=rowvals-CI;
    line = errorbar(app.UIAxes, ...
        1:xrd.NumFiles, rowvals, err,'-d', ...
        'Color','b',...    
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', hTable.RowName{row});
    
    set(app.UIAxes, 'XTickMode', 'auto');
    xlim(app.UIAxes,[0 xrd.NumFiles+1])
    ylim(app.UIAxes,'auto')
    app.UIAxes.XAxis.TickLabelsMode = 'auto';
    app.UIAxes.XLabel.String = 'File Number';
    app.UIAxes.YLabel.String = [];
    app.gui.Legend = 'reset';
    end

% plots the statistics of all the fits, when 'Fit Statistics' is selected
    function plotFitStats(app)
    hTable = app.UITable3;
    fits = app.profiles.getProfileResult;
    numfiles = length(fits);
      for ss=1:numfiles
    fitted = fits{ss};
    obs = fitted.Intensity';
    
if strcmp(app.profiles.xrd.Weights,'None')
    w=obs./obs;
elseif strcmp(app.profiles.xrd.Weights,'1/obs')||strcmp(app.profiles.xrd.Weights,'Default')
    w = 1./obs;
elseif strcmp(app.profiles.xrd.Weights,'1/sqrt(obs)')
    w=1./sqrt(obs);
elseif strcmp(app.profiles.xrd.Weights,'1/max(obs)')
    w=obs./max(obs);
elseif strcmp(app.profiles.xrd.Weights,'Linear')
    w=obs;
elseif strcmp(app.profiles.xrd.Weights,'Sqrt')
    w=sqrt(obs);
elseif strcmp(app.profiles.xrd.Weights,'Log10')
    w=log10(obs);
end
    
    if app.profiles.xrd.BkgLS % for when BkgLS is checked
        calc=fitted.FData'; 
        rsquared(ss) = fitted.FmodelGOF.rsquare;
        adjrsquared(ss) = fitted.FmodelGOF.adjrsquare;
        rmse(ss) = fitted.FmodelGOF.rmse;
        Rp(ss) = (sum(abs(obs-calc))./(sum(obs))) * 100; %calculates Rp
        w(w==Inf)=mean(w(w~=Inf)); %obs=obs(w~=Inf); calc=calc(w~=Inf); % this number has to match weight in FitResults line 153
        
        DOF = fitted.FmodelGOF.dfe; % degrees of freedom from error
%         er=transpose(app.profiles.xrd.DataSet{ss}.getDataErrors);
%         er(er==0)=10;% Remove infinity values, this number has to be 1/w^2
        
        Rwp(ss) = (sqrt(sum(w.*(obs-calc).^2)./sum(w.*obs.^2)))*100;
%         Rwp(ss) = sqrt(sum(((obs-calc)./er).^2)./sum(obs.^2./er.^2))*100; %Calculate Rwp equivalent to line about        
        Rexp(ss)=sqrt(DOF/sum(w.*obs.^2))*100;
%         Rexp(ss)=sqrt(DOF/sum(obs.^2./er.^2))*100; % Rexpected, same as line above
        Rchi2(ss)=fitted.FmodelGOF.sse/DOF;
%         Rchi2(ss)= sum(((obs-calc)./er).^2)/DOF; % true Red-Chi^2, equivalent to line above
%         Rchi2(ss)= sum(w.*((obs-calc)).^2)/DOF; , equivalent to line above
%         Rchi2(ss)=(Rwp(ss)/Rexp(ss))^2;
    
    else
        obs = fitted.Intensity';
        calc = fitted.Background' + fitted.FData';
        rsquared(ss) = fitted.FmodelGOF.rsquare;
        adjrsquared(ss) = fitted.FmodelGOF.adjrsquare;
        rmse(ss) = fitted.FmodelGOF.rmse;
        Rp(ss) = (sum(abs(obs-calc))./(sum(obs))) * 100; %calculates Rp
        w(w==Inf)=mean(w(w~=Inf)); %obs=obs(w~=Inf); calc=calc(w~=Inf); % this number has to match weight in FitResults line 153
        
        DOF = fitted.FmodelGOF.dfe; % degrees of freedom from error
%         er=transpose(app.profiles.xrd.DataSet{ss}.getDataErrors);
%         er(er==0)=10;% Remove infinity values, this number has to be 1/w^2
        
        Rwp(ss) = (sqrt(sum(w.*(obs-calc).^2)./sum(w.*obs.^2)))*100;
%         Rwp(ss) = sqrt(sum(((obs-calc)./er).^2)./sum(obs.^2./er.^2))*100; %Calculate Rwp equivalent to line about        
        Rexp(ss)=sqrt(DOF/sum(w.*obs.^2))*100;
%         Rexp(ss)=sqrt(DOF/sum(obs.^2./er.^2))*100; % Rexpected, same as line above
        Rchi2(ss)=fitted.FmodelGOF.sse/DOF;
%         Rchi2(ss)= sum(((obs-calc)./er).^2)/DOF; % true Red-Chi^2, equivalent to line above
%         Rchi2(ss)= sum(w.*((obs-calc)).^2)/DOF; , equivalent to line above
%         Rchi2(ss)=(Rwp(ss)/Rexp(ss))^2;
    
    end
      end
%     
%     close(figure(5))
    scrsz = get(groot,'ScreenSize');
    figure('Name', 'Fit Statistics', 'tag', 'fitstats', 'Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2]);
    hold on
    for j=1:6
        ax(j)=subplot(2, 3, j);
    end
    
    plot(ax(1),1:numfiles, rsquared, '-ob', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'R^2')
    ylabel(ax(1),'R^2','FontSize',12);

    plot(ax(2),1:numfiles, adjrsquared, '-or', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'AdjR^2')
    ylabel(ax(2),'Adjusted R^2','FontSize',12);

    plot(ax(3),1:numfiles, rmse, '-og', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'RMSE');
    ylabel(ax(3),'Root MSE','FontSize',12);
    
    plot(ax(4),1:numfiles, Rp, '-o','Color',[0.85 0.33 0], ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'Rp');
    ylabel(ax(4),'Rp','FontSize',12);
    
    plot(ax(5),1:numfiles, Rwp, '-om', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'RMSE')
    ylabel(ax(5),'Rwp','FontSize',12)
    
    plot(ax(6),1:numfiles, Rchi2, '-o', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'Reduced \chi^2')
    ylabel(ax(6),'Reduced \chi^2','FontSize',12)
    
    for ii=1:length(ax)
        xlabel(ax(ii),'File Number');
    end
    xlim(ax, [0 numfiles+1]);
    linkaxes(ax, 'x')
    end

    function result = plotBackgroundFit(app)
    %UNTITLED9 Summary of this function goes here
    %   Detailed explanation goes here
    Bkg=app.profiles.xrd.calculateBackground(app.DropDown.Value);
    if ~ishold(app.UIAxes)
        hold(app.UIAxes, 'on');
    end
    line = plotBgFit(app,app.UIAxes,app.DropDown.Value,Bkg); 
    if ~isempty(line)
        result = line.YData;
    else
        result = [];
    end
    end

    function plotBackgroundPoints(app) % plots points and BkgFit
    % The current file TODO: "getCurrentFile(app.popup_filename)"
    if ~ishold(app.UIAxes)
        hold(app.UIAxes, 'on');
    end
    plotBgPoints(app,app.UIAxes);
    end

    function updateXLabel(this, axx)
        set(axx, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');
        if ~ishold(axx), hold(axx, 'on'); end
        state = warning('query', 'MATLAB:handle_graphics:exceptions:SceneNode');
        warning('off', state.identifier);
        switch this.XScale
            case 'linear'
                set([axx.XLabel], 'String', '2\theta (\circ)');
                
                if ~isempty(this.profiles.XRDMLScan) % For changing XLabel on different XRDML scans
                        FiID=this.profiles.XRDMLScan{this.gui.CurrentFile};
                    if strcmpi(FiID, 'Gonio') || strcmpi(FiID, '2Theta') 
                                   set([axx.XLabel], 'String', '2\theta (\circ)');
                    elseif strcmpi(FiID,'Omega')
                                   set([axx.XLabel], 'String', '\omega (\circ)');
                    elseif strcmpi(FiID,'Chi')
                                   set([axx.XLabel], 'String', '\chi (\circ)');
                    elseif strcmpi(FiID,'Phi')
                                   set([axx.XLabel], 'String', '\phi (\circ)');
                    end
                end
            case 'dspace'
                set([axx.XLabel], 'String', ['{\itd}-space (' char(197) ')']);
        end
        dObsnow limitrate % limit rate added for speed
        warning(state.state, state.identifier);
    end

    function updateXLim(this, axx)
            h=guidata(this.figure1);
            if isempty(h)

        if isempty([axx.Children]), return, end
        xrange = [this.profiles.Min2T this.profiles.Max2T];
        switch this.XScale
            case 'linear'
                set(axx, 'XLim', xrange);
            case 'dspace'
                set(axx, 'XLim', sort(this.profiles.dspace(xrange)));
        end
            else
               
                              if isempty([axx.Children]), return, end
                                    xrange = [this.profiles.Min2T this.profiles.Max2T];
                                    switch this.XScale
                                        case 'linear'
                                            set(axx, 'XLim', xrange);
                                        case 'dspace'
                                            set(axx, 'XLim', sort(this.profiles.dspace(xrange)));
                                    end
            end
        end
        
    function updateYLabel(this, axx)
        %updateYAxisLabel modifies the y-axis label to display the correct title according to the
        %   y-axis scale.
        state = warning('query', 'MATLAB:handle_graphics:exceptions:SceneNode');
        warning('off', state.identifier);
        switch this.YScale
            case 'linear'
                set([axx.YLabel], 'Interpreter', 'tex', 'String', 'Intensity (a.u.)');
            case 'log'
                set([axx.YLabel], 'Interpreter', 'tex', 'String', 'ln(Intensity) (a.u.)');
            case 'sqrt'
                set([axx.YLabel], 'Interpreter', 'latex', 'String', '$$\sqrt{Intensity}$$ (a.u.)');
        end
        dObsnow limitrate
        warning(state.state, state.identifier);
        end
        
    function updateYLim(this, axx)
        %updateYAxis modifies the y-axis limits based on the minimum and maximum values of the
        %   plotted lines.
         h=guidata(axx);
         if isempty(h)
         else
         zoomstate = getappdata(h.figure1, 'ZoomOnState');
         if isequal(zoomstate, 'on')
             return
         end
        
        if isempty([axx.Children]), return, end
        ydata = get(findobj(axx, 'tag', 'Obs'), 'YData');
        if isempty(ydata)
            ydata = get(findobj(axx, 'tag', 'superimposed'), 'YData');
        end
        if iscell(ydata)
            ydata = [ydata{:}];
        elseif isempty(ydata)
            return
        end
        ydiff = max(ydata) - min(ydata);
        ymin = min(ydata)-0.05*ydiff;
        ymax = max(ydata)+0.2*ydiff;
        set(axx, 'YLim', sort([ymin ymax]));
         end
        end
        
    function updateXYLim(this, axx,mode)
        %UPDATEXYLIM makes sure the plot is within range and displayed in the appropriate size.
        if nargin < 3
            axx = this;
            mode='na';
        end
        
        if strcmp(mode,'sample')   % should trigger when plotting sample
        else
        updateXLim(this,axx);
        updateYLim(this,axx);
        end
        
        end

    function resizeAxes1ForErrorPlot(handles, size)
% resize is either 'larger' or 'smaller'
    if ~handles.profiles.hasData
        return
    end
        axes1Pos = getappdata(handles.UIAxes, 'OriginalSize');
        axes2Pos = getappdata(handles.UIAxes2, 'OriginalSize');
        axes2height = 0.8*axes2Pos(4);
        if nargin <= 1
            if handles.profiles.hasData
                size = 'fit';
            else
                size = 'data';
            end
        end
        if strcmpi(size, 'fit') % && large == false
            set(findobj(handles.UIAxes2), 'visible', 'on');
            handles.UIAxes.OuterPosition = axes1Pos + [0 axes2height 0 -axes2height];
        elseif strcmpi(size, 'data') % && large == true
            set(findobj(handles.UIAxes2), 'visible', 'off');
            handles.UIAxes.OuterPosition = axes1Pos;
            cla(handles.UIAxes2)    
        end
    end

    function line = plotBgPoints(this, ax)
        line = gobjects(0);
        points = this.profiles.xrd.getBackgroundPoints;
        if isempty(points)
            return
        end
        xdata = this.profiles.xrd.getTwoTheta;
        ydata = this.profiles.xrd.getData(this.DropDown.Value);
        idx = utils.findIndex(xdata, points);
        line = findobj(ax, 'tag', 'Bkgpts');
        if isempty(line)
            line = plot(ax, points, ydata(idx), ...
                        'rd', 'MarkerSize', 5, ...
                        'MarkerEdgeColor', 'r', ...
                        'MarkerFaceColor', 'r', ...
                        'DisplayName', 'Background',...
                        'Tag', 'background', ...
                        'Visible', 'off');
        else
            set(line, 'MarkerIndices', idx, 'MarkerFaceColor', 'r','LineWidth',2);
        end
        setappdata(line, 'xdata', line.XData);
        setappdata(line, 'ydata', line.YData);
%         this.transform(line);
        end

    function line = plotBgFit(this, ax, file,Bkg)
        line = findobj(ax, 'tag', 'background');
        if nargin<4
        file=this.DropDown.Value;
        end
        if length(this.profiles.xrd.getBackgroundPoints) < this.profiles.xrd.getBackgroundOrder
            if ~isempty(line), delete(line); end
            return
        end
        if nargin==4
            bkgdArray=Bkg;
        else
        bkgdArray = this.profiles.xrd.calculateBackground(file);
        end
        
        if isempty(bkgdArray)
            return
        end
        if isempty(line) || ~isvalid(line)
            line = plot(ax, this.profiles.xrd.getTwoTheta(file), bkgdArray,...
                '--r','LineWidth', 1.5, ...
                'Tag', 'background', ...
                'DisplayName', 'Background', ...
                'Visible', 'off');
        else
            set(line, ...
                'LineStyle', '--', ...
                'XData', this.profiles.xrd.getTwoTheta(file), ...
                'YData', bkgdArray, ...
                'Marker', 'none', ...
                'LineWidth', 1.5);
        end
        setappdata(line,'xdata',line.XData);
        setappdata(line,'ydata',line.YData);
%         this.transform(line);
    end
    
    function answer = canPlotSample(this)
        % canPlotSample returns true if the Fit Bounds table has all cells filled.
        answer = false;
        fitInitialValues = this.profiles.FitInitial;
        if isempty(fitInitialValues)
            return
        end
        if isfield(fitInitialValues, 'start')
            noInput = find(fitInitialValues.start == -1, 1);
            if isempty(noInput)
                answer = true;
            end
        end 
    end    

    function line = plotSamplePeak(this, ax, fcnID)
        %plotSamplePeak Plots one peak function number specified by FCNID to the axes specified by 
        %   AX and outputs a line object. If the CuKAlpha2 peak should be calculated, it outputs two
        %   line objects.
        try
            xdata = this.profiles.xrd.getTwoTheta;
            fitsample = this.profiles.xrd.calculateFitInitial(this.profiles.FitInitial.start);
            background = this.profiles.xrd.calculateBackground(this.profiles.xrd.CurrentPro);
            fcnNumStr = num2str(fcnID);
            line = findobj(ax.Children, 'tag', ['sample' fcnNumStr]);
            if isempty(line)
                line = plot(ax, xdata, fitsample(fcnID,:)+background, ...
                            '--', 'LineWidth', 1, ...
                            'DisplayName', ['(' fcnNumStr ') ' this.profiles.FcnNames{fcnID}], ...
                            'Tag', ['sample' fcnNumStr], ...
                            'Visible', 'off');
            else
                set(line, 'XData', xdata)
                set(line, 'YData', fitsample(fcnID,:)+background, ...
                    'DisplayName', ['(' fcnNumStr ') ' this.profiles.FcnNames{fcnID}]);
            end
            if this.profiles.CuKa
                cuKalpha2 = this.profiles.xrd.calculateCuKaPeak(fcnID);
                cukaLine = findobj([ax.Children], 'tag', ['cuka' fcnNumStr]);
                if isempty(cukaLine)
                    line(2) = plot(ax, xdata, cuKalpha2+background, ...
                                   ':','LineWidth',2,...
                                   'DisplayName',['(' fcnNumStr ') Cu-K\alpha2'], ...
                                   'Tag', ['cuka' fcnNumStr], ...
                                   'Visible', 'off');
                else
                    line(2) = cukaLine;
                    set(line(2), 'YData', cuKalpha2+background, ...
                    'DisplayName', ['(' fcnNumStr ') Cu-K\alpha2']);
                end
            end
            for i=1:length(line)
                setappdata(line(i),'xdata',line(i).XData);
                setappdata(line(i),'ydata',line(i).YData);
            end
        catch ex
            ex.getReport
            rethrow(ex)
        end
%         this.transform(line);
    end

    function line = plotFitErr(this, ax, fitted)
        Bkg_LS=this.profiles.xrd.BkgLS;
        if nargin < 1
            ax = this.axerr;
        end
        cla(ax)
        if Bkg_LS
                    line = plot(ax, fitted.TwoTheta, fitted.Intensity - (fitted.FData), ...
                    'r', 'Tag', 'error', ...
                    'visible','off','LineWidth',1); 
        else
        line = plot(ax, fitted.TwoTheta, fitted.Intensity - (fitted.FData+fitted.Background), ...
                    'r', 'Tag', 'error', ...
                    'visible','off','LineWidth',1); 
        end
        set(ax, 'LineWidth', 1, ...
                'XLim', [min(fitted.TwoTheta) max(fitted.TwoTheta)]);
        setappdata(line,'xdata',line.XData);
        setappdata(line,'ydata',line.YData);
%         this.transformXData_(line);
    end
    
    function line = plotOverallFit(this, ax, fitted)
        line = findobj(ax, 'tag', 'OverallFit');
        lineP1=findobj(ax,'tag','95% CI Low');
        lineP2=findobj(ax,'tag','95% CI High');

        Bkg_LS=this.profiles.xrd.BkgLS;
        if isempty(line)
            if Bkg_LS
                            line = plot(ax, fitted.TwoTheta, fitted.FData, ...
                        'k','LineWidth',1,...
                        'DisplayName','Overall Fit',...
                        'Color',[0 0.5 0], ...
                        'Tag', 'OverallFit',...
                        'Visible', 'off'); % Overall Fit
%             lineP1=plot(ax, fitted.TwoTheta,fitted.PredictInt(:,1),...
%                         '--', 'LineWidth',1,...
%                         'DisplayName', '95% CI Low','Tag','95% CI Low',...
%                         'Color',[0.5 0.5 0.5],'Visible','off');
%             lineP2=plot(ax, fitted.TwoTheta,fitted.PredictInt(:,2),...
%                         '--', 'LineWidth',1,...
%                         'DisplayName', '95% CI High','Tag','95% CI High',...
%                         'Color',[0.5 0.5 0.5]);
                    
            else
            line = plot(ax, fitted.TwoTheta, fitted.FData+fitted.Background, ...
                        'k','LineWidth',1,...
                        'DisplayName','Overall Fit',...
                        'Color',[0 0.5 0], ...
                        'Tag', 'OverallFit',...
                        'Visible', 'off'); % Overall Fit
                    % For Plotting Predicted Interval based on CI after
                    % fit, makes plots too cluttered
%             lineP1=plot(ax, fitted.TwoTheta,fitted.PredictInt(:,1)+fitted.Background',...
%                         '--', 'LineWidth',1,...
%                         'DisplayName', '95% CI Low','Tag','95% CI Low',...
%                         'Color',[0.5 0.5 0.5],'Visible','off');
%             lineP2=plot(ax, fitted.TwoTheta,fitted.PredictInt(:,2)+fitted.Background',...
%                         '--', 'LineWidth',1,...
%                         'DisplayName', '95% CI High','Tag','95% CI High',...
%                         'Color',[0.5 0.5 0.5]);
            end
        else
            if Bkg_LS
                            set(line, 'XData', fitted.TwoTheta, ...
                      'YData', fitted.FData,'LineWidth',1.4,'Color',[.0 .5 .0]);
                                      % For Plotting Predicted Interval based on CI after fit
%             set(lineP1, 'XData', fitted.TwoTheta,'YData', fitted.PredictInt(:,1), 'LineWidth',1, 'Color',[0.5 0.5 0.5])
%             set(lineP2,'XData',fitted.TwoTheta, 'YData', fitted.PredictInt(:,2),'LineWidth',1, 'Color',[0.5 0.5 0.5]);
            
            else
            set(line, 'XData', fitted.TwoTheta, ...
                      'YData', fitted.FData+fitted.Background,'LineWidth',1.4,'Color',[.0 .5 .0]);
                                      % For Plotting Predicted Interval based on CI after fit
%             set(lineP1, 'XData', fitted.TwoTheta,'YData', fitted.PredictInt(:,1)+fitted.Background', 'LineWidth',1, 'Color',[0.5 0.5 0.5])
%             set(lineP2,'XData',fitted.TwoTheta, 'YData', fitted.PredictInt(:,2)+fitted.Background','LineWidth',1, 'Color',[0.5 0.5 0.5]);
            end
        end
        setappdata(line,'xdata',line.XData);
        setappdata(line,'ydata',line.YData);
%         this.transform(line);
    end
    
    function line = plotFittedPeak(this, ax, fitted, fcnID)
        %plotFittedPeak     Returns a line object that represents the fit for the function number
        %   specified by fcnID.
        file=this.DropDown.Value;
        Bkg_LS=this.profiles.xrd.BkgLS;
        fcns = fitted.FunctionNames;
        line = findobj(ax, 'tag', ['f' num2str(fcnID)]);
        if isempty(line)
            if Bkg_LS % plotting of Bkg in LS
                            line = plot(ax, fitted.TwoTheta, fitted.FPeaks(fcnID,:)+fitted.Background, ...
                        'LineWidth',1,...
                        'DisplayName',['(' num2str(fcnID) ') ' fcns{fcnID}], ...
                        'Tag', ['f' num2str(fcnID)],...
                        'Visible', 'off');
            else
                
            line = plot(ax, fitted.TwoTheta, fitted.FPeaks(fcnID,:)+fitted.Background, ...
                        'LineWidth',1,...
                        'DisplayName',['(' num2str(fcnID) ') ' fcns{fcnID}], ...
                        'Tag', ['f' num2str(fcnID)],...
                        'Visible', 'off');
            end
        else
            if Bkg_LS % plotting if Bkg in LS
                            set(line, 'XData', fitted.TwoTheta, ...
                      'YData', fitted.FPeaks(fcnID,:)+fitted.Background); % needs to be modified based on Bkg from LS
            else
            set(line, 'XData', fitted.TwoTheta, ...
                      'YData', fitted.FPeaks(fcnID,:)+fitted.Background);
            end
        end
        if fitted.CuKa
            kaLine = findobj(ax, 'tag', ['cuka' num2str(fcnID)]);
            if isempty(kaLine)
                line(2) = plot(ax,fitted.TwoTheta,fitted.FCuKa2Peaks(fcnID,:)+fitted.Background,...
                    ':', 'LineWidth', 2, ...
                    'DisplayName', ['Cu-K\alpha2 (Peak ', num2str(fcnID), ')'], ...
                    'Tag', ['cuka' num2str(fcnID)], ...
                    'Visible', 'off');
            else
                line(2) = kaLine(1);
                set(line(2),...
                    'XData', fitted.TwoTheta, ...
                    'YData', fitted.FCuKa2Peaks(fcnID,:)+fitted.Background, ...
                    'LineStyle', ':',...
                    'LineWidth', 2, ...
                    'DisplayName', ['Cu-K\alpha2 (Peak ', num2str(fcnID), ')'], ...
                    'Visible', 'off');
                    
            end
        end
        for i=1:length(line)
            setappdata(line(i),'xdata',line(i).XData);
            setappdata(line(i),'ydata',line(i).YData);
        end
%         this.transform(line);
        end

end