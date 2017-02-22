classdef AxPlotter < matlab.mixin.SetGet
    %AXPLOTTER manages the different types of plot scales. Also plots individual data lines.
    properties 
        ax
        
        axerr
    end
    
    properties

    end
    
    properties (Dependent)
        Mode  % can be data, background, sample, fit, coeff, stats
        
        FileNames
        
        Title
        
        CurrentFile
        
        XScale % 'linear' or 'dspace'
        
        YScale % 'linear', 'log', or 'sqrt'
    end
    
    properties (Dependent, Hidden)
        profiles
        
        gui
    end
    
    properties (Hidden)
        
        Mode_ = 'data';
        
        XScale_ = 'linear';
        
        YScale_ = 'linear';
        
        XLim
        
        XData
        
        CurrentFileNumber_ = 1;
        
        hg_
    end
    
    properties (Hidden, Dependent)
        hg
    end
    
    methods
        function this = AxPlotter(handles)
        this.hg_ = handles;
        this.ax = handles.axes1;
        this.axerr = handles.axes2;
        set(handles.axes1,'ColorOrder',get(handles.axes1,'DefaultAxesColorOrder'), 'LineWidth', 1);
        set([handles.axes1.XLabel], 'Interpreter', 'tex');
        set([handles.axes1.YLabel], 'Interpreter', 'tex');
        end
        % ======================================================================
        
        function set.Mode(this, mode)
        if isempty(mode)
            return
        end
        switch mode
            case 'data'
                
            case 'background'
                
            case 'sample'
                
            case 'fit'
                
            case 'coeff'
                
            case 'stats'
        end
        this.Mode_ = mode;
        end
        
        function value = get.Mode(this)
        value = this.Mode_;
        end
        
        function name = get.Title(this)
        totalfiles = length(this.FileNames);
        name = [this.FileNames{this.CurrentFile} ' (' num2str(this.CurrentFile) ...
            ' of ' num2str(totalfiles) ')'];
        end
        % ======================================================================
        
        function set.CurrentFile(this, val)
        %   VAL = a structure with field names 'Axis' and 'FileNumber'
        %
        %   VAL = an integer 
        this.CurrentFileNumber_ = val;
        this.gui.CurrentFile = val;
        this.title;
        end
        
        function num = get.CurrentFile(this)
        num = this.CurrentFileNumber_;
        end
        
        function xdata = get.XData(this)
        twotheta = this.profiles.xrd.getTwoTheta;
        if strcmpi(this.XScale, 'linear')
            xdata = twotheta;
        else
            xdata = this.profiles.dspace(twotheta);
        end
        end
        
        function ydata = YData(this, intensity)
        if nargin < 2
            intensity = this.profiles.xrd.getData;
        end
        switch this.YScale
            case 'linear'
                ydata = intensity;
            case 'log'
                ydata = log(intensity);
            case 'sqrt'
                ydata = sqrt(intensity);
        end
        end
        
        function name = get.XScale(this)
        name = this.XScale_;
        end
        
        function set.XScale(this, type)
        this.XScale_ = type;
        this.transform(this.ax.Children);
        this.transformXData_(this.axerr.Children);
        this.updateXAxis(this.ax);
        end
        % ======================================================================
        
        function set.YScale(this, type)
        this.YScale_ = type;
        
        this.transform(this.ax.Children);
        this.updateYAxis(this.ax);
        end
        % ======================================================================
        
        function name = get.YScale(this)
        name = this.YScale_;
        end
        
        function transformXData_(this, line)
        if isempty(line), return, end
        xdata = getappdata(line, 'xdata');
        switch this.XScale
            case 'linear'
                line.XData = xdata;
            case 'dspace'
                line.XData = this.profiles.dspace(xdata);
        end
        end
        
        function transformYData_(this, line)
        if isempty(line), return, end
        ydata = getappdata(line, 'ydata');
        switch this.YScale
            case 'linear'
                line.YData = ydata;
            case 'log'
                line.YData = log(ydata);
            case 'sqrt'
                line.YData = sqrt(ydata);
        end
        end
        
        function transform(this, lines)
        %transform transforms the line object into the appropriate scale.
        if isempty(lines), return, end
        state = warning('query', 'MATLAB:handle_graphics:exceptions:SceneNode');
        warning('off', state.identifier);
        for i=1:length(lines)
            this.transformXData_(lines(i));
            this.transformYData_(lines(i));
        end
        warning(state.state, state.identifier);
        end
        
        function line = plotRawData(this, varargin)
        %PLOTRAWDATA plots the profile's raw data for the currently viewing file. The plotted line's
        %   'Visible' option is always initially set to 'off' so that any line conversions that
        %   might be performed will not be visible to the user.
        %
        %   PLOTRAWDATA(THIS) plots the raw data with the default line options. 
        %
        %   LINE = PLOTRAWDATA(THIS) returns the line object.
        %
        %   LINE = PLOTRAWDATA(THIS, AX) plots the raw data with default properties to the axis
        %   specified by AX.
        %
        %   LINE = PLOTRAWDATA(THIS, VARARGIN) plots the line with the options specified in
        %   VARARGIN to this.ax. However, if the properties 'DisplayName' and 'Tag' were specified
        %   in VARARGIN, it is not used because it will use the default property values specific
        %   only this line.
        %
        %   LINE = PLOTRAWDATA(THIS, AX, VARARGIN) plots the raw data to the axis specified by AX
        %   with properties specified by VARARGIN. 
        filenum = this.gui.CurrentFile;
        x = this.profiles.xrd.getTwoTheta;
        y = this.profiles.xrd.getData(filenum);
        if nargin > 1 && isa(varargin{1}, 'matlab.graphics.axis.Axes')
            axx = varargin{1};
            if length(varargin) > 1
                varargin = varargin(2:end);
            end
        else
            axx = this.ax;
        end
        line = plot(axx,x,y,'o', 'DisplayName', 'Raw Data', 'tag', 'raw', ...
            'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', 'auto', 'MarkerSize', 5, ...
            'visible', 'off');
        if length(varargin) > 1
            set(line, varargin{:});
        end
        setappdata(line, 'xdata', line.XData);
        setappdata(line, 'ydata', line.YData);
        this.transform(line);
        end
        
        function line = plotBgPoints(this, ax)
        xdata = this.profiles.xrd.getTwoTheta;
        ydata = this.profiles.xrd.getData(this.gui.CurrentFile);
        points = this.profiles.xrd.getBackgroundPoints;
        idx = utils.findIndex(xdata, points);
        line = plot(ax, points, ydata(idx), 'rd', 'MarkerSize', 5, ...
            'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', 'DisplayName', 'Background Points',...
            'Visible', 'off');
        setappdata(line, 'xdata', line.XData);
        setappdata(line, 'ydata', line.YData);
        this.transform(line);
        end
        
        function line = plotBgFit(this, ax)
        line = plot(ax, this.profiles.xrd.getTwoTheta, this.profiles.xrd.calculateBackground, ...
            '--','LineWidth', 1, 'DisplayName', 'Background', 'Tag', 'Background', 'Visible', 'off');
        setappdata(line,'xdata',line.XData);
        setappdata(line,'ydata',line.YData);
        this.transform(line);
        end
        
        function line = plotSamplePeak(this, ax, fcnID)
        line = gobjects;
        try
            xdata = this.profiles.xrd.getTwoTheta;
            fitsample = this.profiles.xrd.calculateFitInitial(this.gui.FitInitial.start);
            background = this.profiles.xrd.calculateBackground;
            line = plot(ax, xdata, fitsample(fcnID,:)+background, '--', 'LineWidth', 1, ...
                'DisplayName', ['(' num2str(fcnID) ') ' this.gui.FcnNames{fcnID}], ...
                'Visible', 'off');
            if this.profiles.xrd.hasCuKa
                cuKalpha2 = this.profiles.xrd.calculateCuKaPeak(fcnID);
                line(2) = plot(ax, xdata, cuKalpha2+background, ':','LineWidth',2,...
                    'DisplayName',['(' num2str(fcnID) ') Cu-K\alpha2'], ...
                    'Tag', ['cuka' num2str(fcnID)], 'Visible', 'off');
            end
            for i=1:length(line)
                setappdata(line(i),'xdata',line(i).XData);
                setappdata(line(i),'ydata',line(i).YData);
            end
        catch ex
            ex.getReport
        end
        this.transform(line);
        end
        
        function line = plotFittedPeak(this, ax, fitted, fcnID)
        %plotFittedPeak     Returns a line object that represents the fit for the function number
        %   specified by fcnID.
        fcns = fitted.FunctionNames;
        line = plot(ax, fitted.TwoTheta, fitted.FPeaks(fcnID,:)+fitted.Background, ...
            'LineWidth',1,'DisplayName',['(' num2str(fcnID) ') ' fcns{fcnID}], ...
            'Tag', ['f' num2str(fcnID)],'Visible', 'off');
        if fitted.CuKa
            line(2) = plot(ax,fitted.TwoTheta,fitted.FCuKa2Peaks(fcnID,:)+fitted.Background,...
                ':', 'LineWidth', 2, 'DisplayName', ['Cu-K\alpha2 (Peak ', num2str(fcnID), ')'], ...
                'Visible', 'off');
        end
        for i=1:length(line)
            setappdata(line(i),'xdata',line(i).XData);
            setappdata(line(i),'ydata',line(i).YData);
        end
        this.transform(line);
        end
        
        
        
        function line = plotOverallFit(this, ax, fitted)
        line = plot(ax, fitted.TwoTheta, fitted.FData+fitted.Background, ...
            'k','LineWidth',1,'DisplayName','Overall Fit','Color',[0 0 0], ...
            'Tag', 'OverallFit','Visible', 'off'); % Overall Fit
        setappdata(line,'xdata',line.XData);
        setappdata(line,'ydata',line.YData);
        this.transform(line);
        end
       
        function line = plotFitErr(this, ax, fitted)
        if nargin < 2
            ax = this.axerr;
        end
        cla(ax)
        line = plot(ax,fitted.TwoTheta, fitted.Intensity - (fitted.FData+fitted.Background), ...
            'r', 'LineWidth', .50, 'Tag', 'Error', 'visible','off'); % Error
        setappdata(line,'xdata',line.XData);
        setappdata(line,'ydata',line.YData);
        this.transformXData_(line);
        end
        
        function line = plotCoeffValues(this)
        end
        
        function plotFitStats(this)
        end
        
        function updateXAxis(this, axx)
        if isempty([axx.Children]), return, end
        xrange = [min(this.profiles.xrd.getTwoTheta) max(this.profiles.xrd.getTwoTheta)];
        set(axx, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');
        if ~ishold(axx), hold(axx, 'on'); end
        switch this.XScale
            case 'linear'
                set([axx.XLabel], 'String', '2\theta (\circ)');
                set(axx, 'XLim', xrange);
            case 'dspace'
                set([axx.XLabel], 'String', ['D-Space (' char(197) ')']);
                set(axx, 'XLim', sort(this.profiles.dspace(xrange)));
        end
        end
        
        function updateYAxis(this, axx)
        %updateYAxis modifies the y-axis limits based on the minimum and maximum values of the
        %   plotted lines.
        if isempty([axx.Children]), return, end
        switch this.YScale
            case 'linear'
                set([axx.YLabel], 'String', 'Intensity (a.u.)');
            case 'log'
                set([axx.YLabel], 'String', 'ln{I} (a.u.)');
            case 'sqrt'
                set([axx.YLabel], 'String', '\sqrt{I} (a.u.)');
        end
        ydata = get([axx.Children], 'YData');
        if iscell(ydata)
            ydata = [ydata{:}];
        end
        ydiff = max(ydata) - min(ydata);
        ymin = min(ydata)-0.05*ydiff;
        ymax = max(ydata)+0.2*ydiff;
        set(axx, 'YLim', [ymin ymax]);
        end
        
        function updateAxis(this, axx)
        %UPDATEXYLIM makes sure the plot is within range and displayed in the appropriate size.
        if nargin < 2
            axx = this.ax;
        end
        this.updateXAxis(axx);
        this.updateYAxis(axx);
        this.title;
        end
        
        function title(this, varargin)
        %title Names the title of the axes.
        %
        %   TITLE(AXX) changes the title of the axes specified by AXX to the currently viewing
        %   file's name.
        %
        %   TITLE(AXX, 'FILENAME') overrides the default naming of the axes and names the axes
        %   'FILENAME' instead.
        
        if nargin > 1 && isa(varargin{1}, 'matlab.graphics.axis.Axes')
            axx = varargin{1};
            if length(varargin) > 1
                varargin = varargin(2:end);
            else
                varargin = [];
            end
        else 
            axx = this.ax;
        end
        for i=1:length(axx)
            filenum = this.CurrentFile;
            filename = this.FileNames{filenum};
            title(axx, [filename ' (' num2str(filenum) ' of ' ...
                num2str(length(this.FileNames)) ')'], 'Interpreter', 'none', ...
                'FontSize', 14, 'FontName','default');
            if ~isempty(varargin)
                title(axx, varargin{:});
            end
        end
        end
            
        
        function answer = canPlotSample(this)
        % canPlotSample returns true if the Fit Bounds table has all cells filled.
        answer = false;
        fitInitialValues = this.gui.FitInitial;
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
        
        function answer = canPlotFit(this)
        % canPlotFit returns true only if the dataset has been fit and the Fit Bounds table
        %   wasn't modified afterwards.
        end
        
        function answer = canPlotBackground(this)
        % canPlotBackground returns true if background points have been selected.
        end
        
        function resizePlot(this, size)
        end
        
    end
    
    methods 
        function handles = get.hg(this)
        handles = guidata(this.hg_.figure1);
        end
        
        function gui = get.gui(this)
        gui = this.hg.gui;
        end
        
        function profiles = get.profiles(this)
        profiles = this.hg.profiles;
        end
        
        function filenames = get.FileNames(this)
        filenames = this.profiles.FileNames;
        end
    end
end