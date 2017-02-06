classdef DataLinePlot < matlab.mixin.SetGet
    %DATALINEPLOT holds the plot properties for each line in the axes. It
    %is called by utils.plotutils.plotX. It only holds the properties for each
    %line of plot; it does NOT hold any data. 
    properties (SetAccess = immutable)        
        XData
        
        YData
        
        DataType % background, backgroundpoints, backgroundfit, rawdata, limits, 
                    % fit, sample, error, coeff, stats
    end
    
    properties
        LineWidth = 0.5;
        
        LineStyle = '-';
        
        Marker = 'o';
        
        MarkerSize = 5;
        
        MarkerFaceColor = [1 1 1]; % white
        
        MarkerEdgeColor = [0 0 0]; % black
        
    end
    
    methods
        function this = DataLinePlot(datatype)
        % 
        this.DataType = datatype;
        end
        
        function update(this, line)
        set(line, 'LineStyle', this.LineStyle, 'Marker', this.Marker, 'LineWidth', this.LineWidth, ...
            'MarkerSize', this.MarkerSize, 'MarkerFaceColor', this.MarkerFaceColor, ...
            'MarkerEdgeColor', this.MarkerEdgeColor);
        end
    end
    
    
end