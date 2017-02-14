% Properties needed: datatype, DisplayName, ColorOrder
function  plotX(handles, mode, varargin)
xrd = handles.profiles.xrd;
persistent previousPlot_
% persistent plotConversion_

if nargin < 2
    if isempty(previousPlot_)
        mode = 'data';
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

filenum = handles.gui.CurrentFile;
filenames = handles.gui.getFileNames;
plotter = handles.gui.Plotter;
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
%         handles = plot_sample_fit(handles);
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
    case 'backgroundfit'
        plotBackgroundFit(handles);
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
    case 'limits'
        updateLim(handles);
    case 'superimpose'
        plotSuperimposed(handles);
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
    case 'fit'
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'fit');
        plotFit(handles);
        plotFitError(handles);
        previousPlot_ = 'fit';
    case 'sample'
        plotData(handles);
        plot_sample_fit(handles);
        previousPlot_ = 'sample';
    case 'allfits'
        plotAllFits(handles);
    case 'error'
        plotFitError(handles);
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'fit');
    case 'coeff' %TODO
        plotCoefficients(handles);
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
        previousPlot_ = 'coeff';
    case 'stats' %TODO
        plotFitStats(handles);
end

plotter.XScale = plotter.XScale; % update the plot to display the current Xscale






% ==============================================================================

    function updateLim(handles, range)
    if nargin < 2
        range = [min(xrd.getTwoTheta) max(xrd.getTwoTheta)];
    end
    
    title(handles.axes1, [filenames{filenum} ' (' num2str(filenum) ' of ' ...
        num2str(length(filenames)) ')'], 'FontSize', 15, 'FontName','default');
    
%     handles.gui.Plotter.XScale = handles.gui.Plotter.XScale;
    end
% ==============================================================================

    function plotData(handles)
    import utils.plotutils.*
    % PLOTDATA Plots the raw data for a specified file number in axes1.
    x = xrd.getTwoTheta;
    y = xrd.getData(filenum);
    cla(handles.axes1)
    line = plot(handles.axes1, x,y, '-o', 'LineWidth', 1, ...
            'MarkerSize', 5, 'MarkerFaceColor', [1 1 1], ...
            'MarkerEdgeColor', [0 0 0], 'displayname', 'Raw Data', 'tag', 'raw',...
            'visible', 'off');
    setappdata(line, 'xdata', line.XData);
    setappdata(line, 'ydata', line.YData);
    handles.gui.DisplayName = handles.gui.getFileNames(filenum);
        
    set(handles.axes1, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');
    utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
    hold(handles.axes1, 'on');
    updateLim(handles);
    handles.gui.Legend = 'reset';
    end
% ==============================================================================


    function plotFit(handles, ax, fileID)
    % Plots the current fit in handles.axes1
    import utils.plotutils.*
    
    if nargin < 2
        ax = handles.axes1;
        fileID = filenum;
        cla(ax);
    end
    
    fitted = handles.profiles.getProfileResult{fileID};
    cla
    % Raw Data
    data(1) = plot(ax, ...
        fitted.TwoTheta, fitted.Intensity, 'o', ...
        'MarkerSize',3.5, ...
        'DisplayName','Raw Data', ...
        'Tag', 'raw',...
        'MarkerFaceColor', [.08 .17 .55], ...%[.08 .17 .55],...
        'MarkerEdgeColor',[0 0 0], ...
        'Visible', 'off'); 
    set(ax, 'XLim', [fitted.TwoTheta(1) fitted.TwoTheta(end)]);
    hold(ax, 'on');
    if isequal(ax, handles.axes1)
        set(handles.axes2, 'XLim', [fitted.TwoTheta(1) fitted.TwoTheta(end)]);
        linkaxes([handles.axes2 handles.axes1], 'x');
        hold(handles.axes2, 'on');
    end
    % Background
    data(2) = plot(ax, ...
        fitted.TwoTheta, fitted.Background, '--', ...
        'DisplayName', 'Background', ...
        'Tag', 'Background', ...
        'Visible', 'off');
    data(3) = plot(ax, ...
        fitted.TwoTheta, fitted.FData+fitted.Background, 'k', ...
        'LineWidth',1, ...
        'DisplayName','Overall Fit',...
        'Color',[0 0 0], ...
        'Tag', 'OverallFit', ...
        'Visible', 'off'); % Overall Fit
    
    fcns = fitted.FunctionNames;
    for i=1:xrd.NumFuncs
        data(3+i) = plot(ax, ...
            fitted.TwoTheta, fitted.FPeaks(i,:) + fitted.Background, ...
            'LineWidth',1, ...
            'DisplayName',['(' num2str(i) ') ' fcns{i}], ...
            'Tag', ['f' num2str(i)], ...
            'Visible', 'off');
%         if xrd.CuKa
%             data(3+2*i-1) = plot(x2th',peakfit(i,:)+background',...
%                 'LineWidth',1, ...
%                 'DisplayName',['Cu-K\alpha1 (',num2str(i),')']);
%             data(3+2*i)=plot(x2th',CuKaPeak(i,:)+background', ...
%                 'LineWidth',1, ...
%                 'DisplayName',['Cu-K\alpha2 (',num2str(i),')']);
%         else
%         end
    end
    
    for i=1:length(data)
        setappdata(data(i), 'xdata', data(i).XData);
        setappdata(data(i), 'ydata', data(i).YData);
    end
       
    handles.gui.Legend = 'reset';
    end
% ==============================================================================

%
    function plotFitError(handles)
    import utils.plotutils.*
    
    fitted = handles.profiles.getProfileResult{filenum};
    
    cla(handles.axes2);
    err = plot(handles.axes2, ...
        fitted.TwoTheta, fitted.Intensity - (fitted.FData+fitted.Background), ...
        'r', ...
        'LineWidth', .50, ...
        'Tag', 'Error', 'visible','off'); % Error
    setappdata(err, 'xdata', err.XData);
    setappdata(err, 'ydata', err.YData);
    end
% ==============================================================================

% Plot an example fit using the starting values from table.
    function handles = plot_sample_fit(handles)
    import ui.control.*
    import utils.plotutils.*
    initialValues = handles.gui.FitInitial;
    if isempty(initialValues) || isempty(initialValues.start) || ...
            ~isempty(find(utils.contains(handles.gui.FcnNames, []),1))
        return
    end
    try
        twotheta = xrd.getTwoTheta;
        % Plot background fit
        background = plotBackgroundFit(handles);
        % Use initial coefficient values to plot fit
        fitsample = xrd.calculateFitInitial(handles.gui.FitInitial.start);
        datafit = zeros(1,length(xrd.NumFuncs));
        fcns = handles.profiles.xrd.getFunctions;
        cukaPeakLine = zeros(1,length(fcns));
        for i=1:xrd.NumFuncs
            datafit(i) = plot(handles.axes1, twotheta, fitsample(i,:) + background, ...
                '--',...
                'LineWidth',1,...
                'DisplayName', ['Peak ' num2str(i) ' (' handles.gui.FcnNames{i} ')'], ...
                'Visible', 'off');
            if xrd.CuKa
                cukaPeak = xrd.calculateCuKaPeak(i);
                cukaPeakLine(i) = plot(handles.axes1, twotheta,cukaPeak+background,':','LineWidth',2,...
                    'DisplayName',['Cu-K\alpha2 (Peak ', num2str(i), ')'], ...
                    'Visible', 'off');
                setappdata(cukaPeakLine(i), 'xdata', twotheta);
                setappdata(cukaPeakLine(i), 'ydata', cukaPeak+background);
            end
            
            setappdata(datafit(i), 'xdata', twotheta);
            setappdata(datafit(i), 'ydata', fitsample(i,:) + background);
        end
        utils.plotutils.resizeAxes1ForErrorPlot(handles, 'data');
        updateLim(handles, [twotheta(1) twotheta(end)])
        handles.gui.Legend = 'reset';
    catch
    end
    end
% ==============================================================================

% Like plotData, except turns on hold to enable multiple
%    data to be plotted in handles.axes1.
    function plotSuperimposed(handles)
    import utils.plotutils.*
    hold(handles.axes1, 'on');
    handles.checkbox_superimpose.Value = 1;
     
    line = findobj(handles.axes1.Children, 'DisplayName', filenames{filenum});
    if isempty(line)
        % plot it
        x = xrd.getTwoTheta;
        y = xrd.getData(filenum);
        line = plot(handles.axes1,x,y,'-o','DisplayName',filenames{filenum},'LineWidth',0.5,...
            'MarkerSize',5,'Visible','off');
        setappdata(line,'xdata',x);
        setappdata(line,'ydata',y);
    else
        % delete it
        if length(handles.axes1.Children) > 1
            delete(line);
        end
    end
    handles.gui.Legend = 'reset';
    end
% ==============================================================================

% Makes a new figure and plots each fit for the entire dataset.
    function plotAllFits(handles)
    import utils.plotutils.*

    screen = get(0, 'ScreenSize');
    f = figure('Units', 'pixels', 'Position', [150 50 min(900,screen(3)) min(700,screen(4))]);
    m = floor(sqrt(xrd.NumFiles));
    n = ceil(xrd.NumFiles/m);
    for j=1:xrd.NumFiles
        ax(j) = subplot(m, n, j);
        hold(ax(j), 'on');
        plotFit(handles, ax(j), j);
        xlabel(ax(j), '2\theta','FontSize',11);
        ylabel(ax(j), 'Intensity','FontSize',11);
        filename = [xrd.getFileNames{j} ' (' num2str(j) ' of ' ...
                    num2str(xrd.NumFiles) ')'];
        title(ax(j), filename);
        a = ax(j);
    end
    linkaxes(ax,'xy');
    xlim(ax, [xrd.Min2T xrd.Max2T]);
    ylim(ax, 'auto');
    end
% ==============================================================================


    function plotCoefficients(handles)
    cla(handles.axes1)
    hTable = handles.table_results;
    row = find(cell2mat(hTable.Data(:,1)),1);
    rowvals = cell2mat(hTable.Data(row, 2:end));
    line = plot(handles.axes1, ...
        1:xrd.NumFiles, rowvals, '-d', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', hTable.RowName{row});
    
    xlim(handles.axes1,[0 xrd.NumFiles+1])
    ylim(handles.axes1,'auto')
    set(handles.axes1, ...
        'XTick', 1:xrd.NumFiles, ...
        'XTickLabel', 1:xrd.NumFiles);
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
    
    for i=1:numfiles
        fitted = fits{i};
        rsquared(i) = fitted.FmodelGOF.rsquare;
        adjrsquared(i) = fitted.FmodelGOF.adjrsquare;
        rmse(i) = fitted.FmodelGOF.rmse;
        obs = fitted.Intensity';
        calc = fitted.Background' + fitted.FData';
        Rp(i) = (sum(abs(obs-calc))./(sum(obs))) * 100; %calculates Rp
        w = (1./obs); %defines the weighing parameter for Rwp
        Rwp(i) = (sqrt(sum(w.*(obs-calc).^2)./sum(w.*obs.^2)))*100 ; %Calculate Rwp
        DOF = fitted.FmodelGOF.dfe; % degrees of freedom from error
        Rexp(i)=sqrt(DOF/sum(w.*obs.^2)); % Rexpected
        Rchi2(i)=(Rwp/Rexp)/100; % reduced chi-squared, GOF
    end
%     
%     close(figure(5))
    scrsz = get(groot,'ScreenSize');
    figure('Position',[scrsz(3)/4 scrsz(4)/4 scrsz(3)/2 scrsz(4)/2]);
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
    
    for i=1:length(ax)
        xlabel(ax(i),'File Number');
    end
    xlim(ax, [1 numfiles]);
    linkaxes(ax, 'x')
    end
% ==============================================================================

    function result = plotBackgroundFit(handles)
    %UNTITLED9 Summary of this function goes here
    %   Detailed explanation goes here
    xdata = xrd.getTwoTheta;
    % Get Background
    bkgdArray = xrd.calculateBackground();
    line = plot(handles.axes1, xdata, bkgdArray,'--', ...
        'LineWidth',1,...
        'DisplayName','Background Fit', ...
        'Visible', 'off');
    setappdata(line, 'xdata', xdata);
    setappdata(line, 'ydata', bkgdArray);
    result = bkgdArray;
    end


    function plotBackgroundPoints(handles) % plots points and BkgFit
    % The current file TODO: "getCurrentFile(handles.popup_filename)"
    xdata = xrd.getTwoTheta;
    ydata = xrd.getData(handles.gui.CurrentFile);
    
    points = xrd.getBackgroundPoints;
    idx = utils.findIndex(xdata, points);
    
    % plot(handles.axes1,data(1,:),data(2,:),'-o','LineWidth',0.5,'MarkerSize',4, 'MarkerFaceColor', [0 0 0])
    line = plot(handles.axes1, points, ydata(idx), 'rd', 'markersize', 5, ...
        'markeredgecolor', 'r', 'markerfacecolor','r', 'DisplayName', 'Background Points', ...
        'Visible', 'off');
    setappdata(line, 'xdata', line.XData);
    setappdata(line,'ydata', line.YData);
    end
end



