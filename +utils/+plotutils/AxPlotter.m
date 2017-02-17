classdef AxPlotter < matlab.mixin.SetGet
    %AXPLOTTER manages the different types of plot scales. Also plots individual data lines.
    properties (SetAccess = immutable)
        ax
        
        axerr
        
        FileNames
        
        profiles
        
        gui
    end
    
    properties

    end
    
    properties (Dependent)
        Mode  % can be data, background, sample, fit, coeff, stats
        
        Title
        
        CurrentFile
        
        XScale % 'linear' or 'dspace'
        
        YScale % 'linear', 'log', or 'sqrt'
        
        
    end
    properties (Hidden)
        
        Mode_ = 'data';
        
        XScale_ = 'linear';
        
        YScale_ = 'linear';
        
        XData
        
        CurrentFileNumber_ = 1;
        
        hg_
    end
    
    properties (Hidden, Dependent)
        hg
    end
    
    methods
        function this = AxPlotter(handles, gui)
        this.hg_ = handles;
        this.ax = handles.axes1;
        this.axerr = handles.axes2;
        this.profiles = handles.profiles;
        this.gui = gui;
        this.FileNames = handles.profiles.FileNames;
        end
        % ======================================================================
        
        function set.Mode(this, mode)
        switch mode
            case 'data'
                
            case 'background'
                
            case 'sample'
                
            case 'fit'
                
            case 'coeff'
                
            case 'stats'
                
        end
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
                for i=1:length(lines)
                    x = getappdata(lines(i), 'xdata');
                    lines(i).XData = this.profiles.dspace(x);
                end
            otherwise % don't do anything to XData
                for i=1:length(lines)
                    set(lines(i),'XData', getappdata(lines(i), 'xdata'));
                end
        end
        
        if isempty(lines)
            set(this.ax,'XLimMode','auto');
        elseif ~isequal(this.ax.XLim, [min([lines.XData]) max([lines.XData])])
            set(this.ax, 'XLim', [min([lines.XData]) max([lines.XData])],'XTickMode','auto');
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
                for i=1:length(lines)
                    y = getappdata(lines(i), 'ydata');
                    lines(i).YData = log(y);
                end
            case 'sqrt'
                for i=1:length(lines)
                    y = getappdata(lines(i), 'ydata');
                    lines(i).YData = sqrt(y);
                end
            otherwise % linear
                for i=1:length(lines)
                    lines(i).YData = getappdata(lines(i), 'ydata');
                end
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
        line = plot(axx,x,y,varargin{:});
        set(line, 'displayname', 'Raw Data', 'tag', 'raw','visible', 'off');
        setappdata(line, 'xdata', line.XData);
        setappdata(line, 'ydata', line.YData);
        this.gui.Legend = 'reset';
        this.updateAxis(axx);
        set(axx.Children, 'visible', 'on');
        end
        
        function line = plotBgPoints(this)
        end
        
        function line = plotBgFit(this)
        end
        
        function line = plotSample(this, coeffvals)
        end
        
        function line = plotFit(this, ax, fileID)
        end
        
        function line = plotFitErr(this)
        end
        
        function line = plotCoeffValues(this)
        end
        
        function plotFitStats(this)
        end
        
        function updateAxis(this, axx)
        %UPDATEXYLIM makes sure the plot is within range and displayed in the appropriate size.
        if nargin < 2
            axx = this.ax;
        end
        range = [min(this.profiles.xrd.getTwoTheta) max(this.profiles.xrd.getTwoTheta)];
        set(axx, 'XTickMode', 'auto', 'XTickLabelMode', 'auto', 'XLim', range);
        axx.XLabel.Interpreter = 'tex';
        switch this.XScale
            case 'linear'
                set(axx.XLabel, 'String', '2\theta (\circ)');
            case 'dspace'
                set(axx.XLabel, 'String', ['D-Space (' char(197) ')']);
        end
        
        axx.YLabel.Interpreter = 'latex';
        raw = findobj(axx,'tag','raw');
        switch this.YScale
            case 'linear'
                axx.YLabel.Interpreter = 'tex';
                set(axx.YLabel, 'String', 'Intensity (a.u.)');
                if ~isempty(raw)
                    ylim(axx,[0.8*min([raw(1).YData]) 1.1*max([raw(1).YData])]);
                end
            case 'log'
                set(axx.YLabel, 'String', '$$ln(I)$$ (a.u.)');
                if ~isempty(raw)
                    ylim(axx,[0.96*min([raw(1).YData]) 1.04*max([raw(1).YData])]);
                end
            case 'sqrt'
                set(axx.YLabel, 'String', 'textsf{$$\sqrt(I)$$ (a.u.)}');
                if ~isempty(raw)
                    ylim(axx,[0.9*min([raw(1).YData]) 1.1*max([raw(1).YData])]);
                end
        end
        
        this.XScale = this.XScale;
        end
        
        function title(this, varargin)
        
        if nargin > 1 && isa(varargin{1}, 'matlab.graphics.axis.Axes')
            axx = varargin{1};
        else 
            axx = this.ax;
        end
        title(axx, [this.FileNames{this.CurrentFile} ' (' num2str(this.CurrentFile) ' of ' ...
            num2str(length(this.FileNames)) ')'], 'Interpreter', 'none');
        if length(varargin) > 1
            title(axx, varargin);
        else
            title(axx, 'FontSize', 15, 'FontName','default');
        end
        end
            
        function resizePlot(this, size)
        end
        
    end
    
    methods 
        function handles = get.hg(this)
        handles = guidata(this.hg_);
        end
    end
end