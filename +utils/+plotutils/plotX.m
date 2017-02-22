% Properties needed: datatype, DisplayName, ColorOrder
function  plotX(handles, mode, varargin)
% All lines that would require re-plotting in d-space are initially not visible. They become visible
% after calling plotter.XScale.
persistent previousPlot_
try
    % Disable the figure while its plotting
    focusedObj = gcbo;
    enabledObjs = findobj(handles.figure1, 'Enable', 'on');
    for ii=1:length(enabledObjs)
        try
            set(enabledObjs(ii), 'Enable', 'inactive');
        catch
        end
    end
    plotter = handles.gui.Plotter;
    filenum = handles.gui.CurrentFile;
    filenames = handles.gui.getFileNames;
    xrd = handles.profiles.xrd;
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
    
    if strcmpi(mode, 'fit') && (~handles.profiles.hasFit || handles.gui.isFitDirty)
        mode = 'sample';
    end
    
    handles.checkbox_superimpose.Value = 0;
    % try
    switch lower(mode)
        case 'data'
            plotData(handles);
            previousPlot_ = 'data';
        case 'background'
            plotData(handles);
            if handles.profiles.xrd.hasBackground
                plotBackgroundPoints(handles);
                plotBackgroundFit(handles);
            end
            previousPlot_ = 'background';
        case 'backgroundpoints'
            plotBackgroundPoints(handles);
            
        case 'backgroundfit'
            plotBackgroundFit(handles);
        case 'limits'
            updateLim(handles);
        case 'superimpose'
            plotSuperimposed(handles);
            utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
        case 'fit'
            plotFitError(handles);
            plotFit(handles);
            set(handles.axes2.Children, 'Visible', 'on');
            previousPlot_ = 'fit';
        case 'sample'
            plotData(handles);
            plotSampleFit(handles);
            previousPlot_ = 'sample';
        case 'allfits'
            plotAllFits(handles);
        case 'error'
            plotFitError(handles);
            utils.plotutils.resizeAxes1ForErrorPlot(handles, 'fit');
        case 'coeff' %TODO
            plotCoefficients(handles);
            previousPlot_ = 'coeff';
        case 'stats' %TODO
            plotFitStats(handles);
    end
    plotter.Mode = previousPlot_;
    set(handles.axes1.Children,'visible','on');
    set(enabledObjs, 'Enable', 'on');
    currentFig = get(0,'CurrentFigure');
    if ~isempty(currentFig) && contains(currentFig.Name, 'LIPRAS') && ~isempty(focusedObj)
        if strcmpi(focusedObj.Type, 'uicontrol')
            uicontrol(focusedObj);
        elseif strcmpi(focusedObj.Type, 'uitable')
            uitable(focusedObj);
        end
    end
catch ex
    ex.getReport
    set(enabledObjs, 'Enable', 'on');
    errordlg(ex.message)
end

% ==============================================================================

    function plotData(handles)
    % PLOTDATA Plots the raw data for a specified file number in axes1.
    cla(handles.axes1)
    plotter.plotRawData(handles.axes1, 'LineStyle', '-', 'LineWidth', 1, 'MarkerFaceColor', [1 1 1]);
    utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
    handles.gui.Legend = 'reset';
    plotter.updateAxis(handles.axes1);
    end
% ==============================================================================


    function plotFit(handles, ax, fileID)
    % Plots the current fit in handles.axes1
    import utils.plotutils.*
    if nargin < 2
        ax = handles.axes1;
        fileID = filenum;
        cla(ax)
    end
    fitted = handles.profiles.getProfileResult{fileID};
    % Raw Data
    plotter.plotRawData(ax, 'MarkerSize', 3.5, 'MarkerFaceColor', [0 0.18 0.65]);
    if isequal(ax, handles.axes1)
        linkaxes([handles.axes2 handles.axes1], 'x');
    end
    plotter.plotBgFit(ax);
    plotter.plotOverallFit(ax,fitted);
    for ii=1:xrd.NumFuncs
        plotter.plotFittedPeak(ax,fitted,ii);
    end
    handles.gui.Legend = 'reset';
    if nargin < 2
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'fit');
        plotter.updateAxis(handles.axes1);
    end
    end
% ==============================================================================

%
    function plotFitError(handles)
    fitted = handles.profiles.getProfileResult{filenum};
    plotter.plotFitErr(handles.axes2, fitted);
    
    end
% ==============================================================================

% Plot an example fit using the starting values from table.
    function handles = plotSampleFit(handles)
    import ui.control.*
    import utils.plotutils.*
    if ~plotter.canPlotSample
        return
    end
    % Plot background fit
    plotter.plotBgFit(handles.axes1);
    for i=1:xrd.NumFuncs
        plotter.plotSamplePeak(handles.axes1, i);
    end
    utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
    handles.gui.Legend = 'reset';
    plotter.updateAxis(handles.axes1);
    end
% ==============================================================================

    function plotSuperimposed(handles)
    % Like plotData, except turns on hold to enable multiple
    %    data to be plotted in handles.axes1.
    import utils.plotutils.*
    if ~ishold(handles.axes1)
        hold(handles.axes1, 'on');
    end
    handles.checkbox_superimpose.Value = 1;
    line = findobj(handles.axes1.Children,'DisplayName', filenames{filenum});
    if isempty(line)
        % If not already plotted, add to plot
        plotter.plotRawData(handles.axes1,'LineStyle','-','DisplayName',filenames{filenum});
    else
        % If already plotted && is not the only plotted data, delete line
        if length(handles.axes1.Children) > 1
            delete(line);
        end
    end
    handles.gui.Legend = 'reset';
    plotter.updateAxis(handles.axes1);
    end
% ==============================================================================

% Makes a new figure and plots each fit for the entire dataset.
    function plotAllFits(handles)
    import utils.plotutils.*
    try
        screen = get(0, 'ScreenSize');
        nRows = floor(sqrt(xrd.NumFiles));
        nColumns = ceil(xrd.NumFiles/nRows);
        fWidth = min(400*nColumns, screen(3));
        fHeight = min(400*nRows, screen(4));
        wPos = (screen(3)-fWidth)/4;
        hPos = (screen(4)-fHeight)/4;
        f = figure('Units', 'pixels', 'Position', [wPos hPos fWidth fHeight], ...
            'Visible', 'off');
        ax = gobjects(1,xrd.NumFiles);
        for j=1:xrd.NumFiles
            ax(j) = subplot(nRows, nColumns, j);
            if ~ishold(ax(j))
                hold(ax(j), 'on');
            end
            plotFit(handles, ax(j), j);
        end
        linkaxes(ax,'xy');
        plotter.updateAxis(ax);
        set(findobj(f), 'Visible', 'on');
    catch exception
        delete(f);
        rethrow(exception)
    end
end
% ==============================================================================


    function plotCoefficients(handles)
    cla(handles.axes1)
    utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
    hTable = handles.table_results;
    row = find(cell2mat(hTable.Data(:,1)),1);
    rowvals = cell2mat(hTable.Data(row, 2:end));
    line = plot(handles.axes1, ...
        1:xrd.NumFiles, rowvals, '-d', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', hTable.RowName{row});
    
    set(handles.axes1, 'XTickMode', 'auto');
    xlim(handles.axes1,[0 xrd.NumFiles+1])
    ylim(handles.axes1,'auto')
    handles.axes1.XAxis.TickLabelsMode = 'auto';
    handles.axes1.XLabel.String = 'File Number';
    handles.axes1.YLabel.String = [];
    handles.gui.Legend = 'reset';
    end
% ==============================================================================

% plots the statistics of all the fits, when 'Fit Statistics' is selected
    function plotFitStats(handles)
    hTable = handles.table_results;
    fits = handles.profiles.getProfileResult;
    numfiles = length(fits);
    
    for ii=1:numfiles
        fitted = fits{ii};
        rsquared(ii) = fitted.FmodelGOF.rsquare;
        adjrsquared(ii) = fitted.FmodelGOF.adjrsquare;
        rmse(ii) = fitted.FmodelGOF.rmse;
        obs = fitted.Intensity';
        calc = fitted.Background' + fitted.FData';
        Rp(ii) = (sum(abs(obs-calc))./(sum(obs))) * 100; %calculates Rp
        w = (1./obs); %defines the weighing parameter for Rwp
        Rwp(ii) = (sqrt(sum(w.*(obs-calc).^2)./sum(w.*obs.^2)))*100 ; %Calculate Rwp
        DOF = fitted.FmodelGOF.dfe; % degrees of freedom from error
        Rexp(ii)=sqrt(DOF/sum(w.*obs.^2)); % Rexpected
        Rchi2(ii)=(Rwp/Rexp)/100; % reduced chi-squared, GOF
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
    ylabel(ax(1),'R^2','FontSize',14);

    plot(ax(2),1:numfiles, adjrsquared, '-or', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'AdjR^2')
    ylabel(ax(2),'Adjusted R^2','FontSize',14);

    plot(ax(3),1:numfiles, rmse, '-og', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'RMSE');
    ylabel(ax(3),'Root MSE','FontSize',14);
    
    plot(ax(4),1:numfiles, Rp, '-o','Color',[0.85 0.33 0], ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'Rp');
    ylabel(ax(4),'Rp','FontSize',14);
    
    plot(ax(5),1:numfiles, Rwp, '-om', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'RMSE')
    ylabel(ax(5),'Rwp','FontSize',14)
    
    plot(ax(6),1:numfiles, Rchi2, '-o', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'Reduced \chi^2')
    ylabel(ax(6),'Reduced \chi^2','FontSize',14)
    
    for ii=1:length(ax)
        xlabel(ax(ii),'File Number');
    end
    xlim(ax, [0 numfiles+1]);
    linkaxes(ax, 'x')
    end
% ==============================================================================

    function result = plotBackgroundFit(handles)
    %UNTITLED9 Summary of this function goes here
    %   Detailed explanation goes here
    line = plotter.plotBgFit(handles.axes1);
    result = line.YData;
    end


    function plotBackgroundPoints(handles) % plots points and BkgFit
    % The current file TODO: "getCurrentFile(handles.popup_filename)"
    plotter.plotBgPoints(handles.axes1);
    end
end



