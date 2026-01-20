% Properties needed: datatype, DisplayName, ColorOrder
function  plotX(app, mode, varargin)
% All lines that would require re-plotting in d-space are initially not visible. They become visible
% after calling plotter.XScale.
persistent previousPlot_
try
    plotter = app.gui.Plotter;
    filenum = app.gui.CurrentFile;
    filenames = app.gui.getFileNames;
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
    focusedObj = gcbo;
    enabledObjs = findobj(app.figure1,'Tag','listbox_results');
    set(enabledObjs, 'enable', 'inactive');
    
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
%             utils.plotutils.resizeAxes1ForErrorPlot(app, 'data');
        case 'fit'
            R1=num2str(round(app.profiles.FitResults{1}{filenum}.Rp,4));
            R2=num2str(round(app.profiles.FitResults{1}{filenum}.Rwp,4));
            R3=num2str(round(app.profiles.FitResults{1}{filenum}.Rchi2,4));
            Resi1=['Rp:' ' ' R1 ' %'];
            Resi2=['Rwp:' ' ' R2 ' %'];
            Resi3=['GOF:' ' ' R3];

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
    
    set(enabledObjs, 'Enable', 'on');
    currentFig = get(0,'CurrentFigure');
    if ~isempty(currentFig) && contains(currentFig.Name, 'LIPRAS') && ~isempty(focusedObj)
        if strcmpi(focusedObj.Type, 'uitable')
            uitable(focusedObj);
        elseif isfield(focusedObj,'Style') && strcmpi(focusedObj.Style, 'listbox') % no focusedObk.Style is created
            uicontrol(focusedObj); % why is this here?
        end
    end
    app.gui.Legend = 'reset';

catch ex
    ex.getReport
    set(enabledObjs, 'Enable', 'on');
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
        app.gui.Plotter.transform(dataLine);
%         drawnow;

    elseif nargin==4
                dataLine = plotter.plotObsData(axx, ...
                            'LineStyle', '-', ...
                            'LineWidth', 1, ...
                            'MarkerFaceColor', [1 1 1], ...
                            'Color', 'k', ...
                            'Visible', 'on');
%             line = plot(axx,xdata,ydata,'o',...
%             'DisplayName', 'Measured Data', ...
%             'tag', 'Obs', ...        setappda
%             'MarkerFaceColor', [1 1 1], ...
%             'MarkerEdgeColor', 'auto', ...
%             'MarkerSize', 5, ...
%             'visible', 'on');
        filenum=j;                
        dataLine = findobj(axx, 'tag', 'Obs');
        xdata = xrd.getTwoTheta(j);
        set(dataLine, 'XData', xdata, 'YData', ydata);
        setappdata(dataLine, 'xdata', xdata);
        setappdata(dataLine, 'ydata', ydata);
        app.gui.Plotter.transform(dataLine);
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
    plotter.plotOverallFit(ax,fitted);
    if app.profiles.xrd.BkgLS % background specific to BkgLS otherwise, peaks undershoot in plot window
    plotter.plotBgFit(ax,filenum,fitted.Background);
    else
    plotter.plotBgFit(ax,filenum);
    end
    for ii=1:xrd.NumFuncs
        plotter.plotFittedPeak(ax,fitted,ii);
    end
    if isequal(ax, app.UIAxes) % not supported for UIAxes
        linkaxes([app.UIAxes app.UIAxes2], 'x');
    end
    if nargin < 2
        plotter.updateXYLim(app.UIAxes);
    end
    if ~strcmp(previousPlot_, 'fit')
        app.gui.Legend = 'reset';
    end
    app.UIAxes2.Visible=1;
    end

    function plotFitError(app)
    fitted = app.profiles.getProfileResult{filenum};
    plotter.plotFitErr(app.UIAxes2, fitted);
    
    end

% Plot an example fit using the starting values from table.
    function app = plotSampleFit(app,mode)

    
     if ~strcmpi(plotter.Mode, mode)
        cla(app.UIAxes);
     end
  plotData(app,mode);
  plotBackgroundFit(app);
    
    if ~plotter.canPlotSample
        return
    end
    % Plot background fit
    plotter.plotBgFit(app.UIAxes);    
    for i=1:xrd.NumFuncs
        plotter.plotSamplePeak(app.UIAxes, i);
    end
%     utils.plotutils.resizeAxes1ForErrorPlot(app, 'data');

    plotter.updateXYLim(app.UIAxes,'sample'); % this always comes from sample
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
    plotter.updateXYLim(app.UIAxes);
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
    app.UIAxes.YLabel.String=app.FilesListBox.Items{app.FilesListBox.Value}; % Sets ylabel
    app.gui.Legend = 'reset';
    app.UIAxes2.Visible='off'; % added to remove subplot when coefficients is toggled, 1-6-2026
    app.UIAxes2.Children.Visible='off'; % added to remove subplot when coefficients is toggled, 1-6-2026
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
        Rchi2(ss)=fitted.Rchi2;
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
        % Rchi2(ss)=fitted.FmodelGOF.sse/DOF;
        Rchi2(ss)=fitted.Rchi2;
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
    line = plotter.plotBgFit(app.UIAxes); 
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
    plotter.plotBgPoints(app.UIAxes);
    end
end