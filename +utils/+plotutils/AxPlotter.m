classdef AxPlotter < matlab.mixin.SetGet
    %AXPLOTTER manages the different types of plot scales. Also plots individual data lines.
    properties (SetAccess = immutable)
        ax
        
        axerr
        
        FileNames
        
        profiles
    end
    
    properties
        plottype = 'data'; % can be rawdata, background, backgroundpoints, backgroundfit, limits,
        % fit, sample, error, coeff, stats
    end
    
    properties (Dependent)
        Title
        
        CurrentFile
        
        XScale % 'linear' or 'dspace'
        
        YScale % 'linear', 'log', or 'sqrt'
        
        
    end
    properties (Hidden)
        hg
        
        XScale_ = 'linear';
        
        YScale_ = 'linear';
        
        XData
        
        CurrentFileNumber_ = 1;
    end
    
    methods
        function this = AxPlotter(handles)
        this.hg = handles;
        this.ax = handles.axes1;
        this.axerr = handles.axes2;
        this.profiles = handles.profiles;
        this.FileNames = handles.profiles.FileNames;
        
        this.axerr.XAxis.LineWidth = 0.5;
        this.axerr.YAxis.LineWidth = 0.5;
        end
        % ======================================================================
        
        function name = get.Title(this)
        totalfiles = length(this.FileNames);
        name = [this.FileNames{this.CurrentFile} ' (' num2str(this.CurrentFile) ...
            ' of ' num2str(totalfiles) ')'];
        end
        % ======================================================================
        
        function set.CurrentFile(this, val)
        this.CurrentFileNumber_ = val;
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
        this.convertXData;
        this.convertYData;
        this.convertXErr;
        end
        % ======================================================================
        
        function set.YScale(this, type)
        this.YScale_ = type;
        
        this.convertXData;
        this.convertYData;
        end
        % ======================================================================
        
        function name = get.YScale(this)
        name = this.YScale_;
        end
        
        function convertXErr(this)
        line = this.axerr.Children;
        if isempty(line)
            return
        end
        type = this.XScale;
        switch type
            case 'dspace'
                x = getappdata(line,'xdata');
                line.XData = this.profiles.dspace(x);
            otherwise
                set(line,'XData',getappdata(line,'xdata'));
        end
        line.Visible = 'on';
        end
        
        function convertXData(this)
        state = warning('query', 'MATLAB:handle_graphics:exceptions:SceneNode');
        warning('off', state.identifier);
        lines = this.ax.Children;
        type = this.XScale;
        if isempty(lines)
            return
        elseif isempty(getappdata(lines(1), 'xdata'))
            delete(lines(1));
        end
        lines = this.ax.Children; % update the lines object array
        switch type
            case 'dspace'
                set(this.ax.XLabel, 'Interpreter', 'latex', 'String', '\textsf{D-Space (}$${\AA}$$\textsf{)}');
                for i=1:length(lines)
                    x = getappdata(lines(i), 'xdata');
                    lines(i).XData = this.profiles.dspace(x);
                end
            otherwise % don't do anything to XData
                for i=1:length(lines)
                    set(lines(i),'XData', getappdata(lines(i), 'xdata'));
                end
                set(this.ax.XLabel, 'Interpreter', 'tex', 'String', '2\theta (\circ)');
        end
        
        if ~isequal(this.ax.XLim, [min([lines.XData]) max([lines.XData])])
            set(this.ax, 'XLim', [min([lines.XData]) max([lines.XData])],'XTickMode','auto');
        end
        for i=1:length(lines)
            lines(i).Visible = 'on';
        end
        warning(state.state, state.identifier);
        end
        
        function convertYData(this)
        lines = this.ax.Children;
        state = warning('query', 'MATLAB:handle_graphics:exceptions:SceneNode');
        warning('off', state.identifier);
        if isempty(lines)
            return
        elseif isempty(getappdata(lines(1), 'ydata'))
            delete(lines(1));
        end
        lines = this.ax.Children; % update the lines object array
        switch this.YScale
            case 'log'
                this.ax.YLabel.Interpreter = 'latex';
                set(this.ax.YLabel, 'String', '\textsf{ln($$Intensity$$) (a.u.)}');
                for i=1:length(lines)
                    y = getappdata(lines(i), 'ydata');
                    lines(i).YData = log(y);
                end
                raw = findobj(this.ax,'tag','raw');
                if ~isempty(raw)
                    ylim(this.ax,[0.96*min([raw(1).YData]) 1.04*max([raw(1).YData])]);
                end
            case 'sqrt'
                this.ax.YLabel.Interpreter = 'latex';
                set(this.ax.YLabel, 'String', '\textsf{$$\sqrt{Intensity}$$ (a.u.)}');
                for i=1:length(lines)
                    y = getappdata(lines(i), 'ydata');
                    lines(i).YData = sqrt(y);
                end
                raw = findobj(this.ax,'tag','raw');
                if ~isempty(raw)
                    ylim(this.ax,[0.9*min([raw(1).YData]) 1.1*max([raw(1).YData])]);
                end
                
            otherwise % linear
                set(this.ax.YLabel, 'String', 'Intensity (a.u.)');
                for i=1:length(lines)
                    lines(i).YData = getappdata(lines(i), 'ydata');
                end
                raw = findobj(this.ax,'tag','raw');
                if ~isempty(raw)
                    ylim(this.ax,[0.8*min([raw(1).YData]) 1.1*max([raw(1).YData])]);
                end
        end
       
        warning(state.state, state.identifier);
        end
        
        function plotData(this)
        end
        
        function plotBackgroundPoints(this)
        end
        
        function plotBackgroundFit(this)
        end
        
        function plotSample(this, coeffvals)
        end
        
        function plotFit(this, ax, fileID)
        end
        
        function plotFitErr(this)
        end
        
        function plotCoeffValues(this)
        end
        
        function plotFitStats(this)
        end
        
        function updateXYLim(this)
        end
        
        function updateXYLabel(this)
        end
            
        function resizePlot(this, size)
        end
        
    end
end