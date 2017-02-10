classdef AxPlotter < matlab.mixin.SetGet
    %AXPLOTTER manages the different types of plot scales.
    properties (SetAccess = immutable)
        ax
        
        FileNames
    end
    
    properties
        LinePrefs % struct with fields rawdata, background, backgroundpoints, backgroundfit, limits, 
                    % fit, sample, error, coeff, stats
    end
    
    properties (Dependent)
        Title
        
        CurrentFile

        XScale % 'linear' or 'dspace'
        
        YScale % 'linear', 'log', or 'sqrt'
        
    end
    properties (Hidden)
        XScale_ = 'linear';
        
        YScale_ = 'linear';
        
        XData
        
        YData
        
        CurrentFileNumber_ = 1;
    end
    
    methods
        function this = AxPlotter(ax, filenames)
        this.ax = ax;
        this.FileNames = filenames;
        end
        % ======================================================================
        
        function RawData(this, xdata, ydata, lineprefs, varargin)
        cla(this.ax)
        if length(varargin) > 2
            line = plot(this.ax, xdata, ydata, varargin{1:2:end}, varargin{3:2:end});
        else
            line = plot(this.ax, xdata, ydata, varargin{1:2:end}, varargin{2:2:end});
        end
        setappdata(line, 'xdata', xdata);
        setappdata(line, 'ydata', ydata);
        lineprefs.update(line);
        end
        
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


        
        function name = get.XScale(this)
        name = this.XScale_;
        end
        
        function set.XScale(this, type)
         this.XScale_ = type;
        
         this.convertXData;
         this.convertYData;
        end
        % ======================================================================
        
        function set.YScale(this, type)
        this.YScale_ = type;

        this.convertYData;
        this.convertXData;
        end
        % ======================================================================
        
        function name = get.YScale(this)
        name = this.YScale_;
        end
        
        function convertXData(this)
        state = warning('query', 'MATLAB:handle_graphics:exceptions:SceneNode');
        warning('off', state.identifier);
        % this.XScale = {'dspace', lambda};
        lines = this.ax.Children;
        type = this.XScale;
        if iscell(type) %
            lambda = type{2};
            type = type{1};
        elseif strcmpi(type, 'dspace') % if lambda value wasn't specified
            lambda = 0.10801;
        end
        if isempty(getappdata(lines(1), 'xdata'))
            delete(lines(1));
        end
        lines = this.ax.Children;
        switch type
            case 'dspace'
                set(this.ax.XLabel, 'Interpreter', 'latex', 'String', '\textsf{D-Space (}$${\AA}$$\textsf{)}');
                for i=1:length(lines)
                    x = getappdata(lines(i), 'xdata');
                    lines(i).XData = this.dspace(x, lambda);
                end
            otherwise % don't do anything to XData
                for i=1:length(lines)
                    lines(i).XData = getappdata(lines(i), 'xdata');
                end
                set(this.ax.XLabel, 'Interpreter', 'tex', 'String', '2\theta (\circ)');
        end
        
        set(this.ax, 'XLim', [min(lines(1).XData) max(lines(1).XData)]);
        drawnow
        warning(state.state, state.identifier);
        end
        
        function convertYData(this)
        lines = this.ax.Children;
        state = warning('query', 'MATLAB:handle_graphics:exceptions:SceneNode');
        warning('off', state.identifier);
        if isempty(getappdata(lines(1), 'xdata'))
            delete(lines(1));
        end
        lines = this.ax.Children;
        switch this.YScale
            case 'log'
                this.ax.YLabel.Interpreter = 'tex';
                set(this.ax.YLabel, 'String', 'Log_{10}(Intensity) (a.u.)');
                for i=1:length(lines)
                    y = getappdata(lines(i), 'ydata');
                    lines(i).YData = log(y);
                end
            case 'sqrt'
                this.ax.YLabel.Interpreter = 'latex';
                set(this.ax.YLabel, 'String', '\textsf{$$\sqrt{Intensity}$$ (a.u.)}');
                for i=1:length(lines)
                    y = getappdata(lines(i), 'ydata');
                    lines(i).YData = sqrt(y);
                end
            otherwise % linear
                set(this.ax.YLabel, 'String', 'Intensity (a.u.)');
                for i=1:length(lines)
                    lines(i).YData = getappdata(lines(i), 'ydata');
                end
        end
        this.ax.YLimMode = 'auto';
        drawnow
        warning(state.state, state.identifier);
        end
      
        
    end
    
    methods (Static)
        function xdata = dspace(xdata, lambda)
        xdata = lambda ./ (2*sind(xdata));
        end
        % ======================================================================
        
      
    end
end