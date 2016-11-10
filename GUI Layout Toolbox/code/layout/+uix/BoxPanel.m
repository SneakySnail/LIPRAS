classdef BoxPanel < uix.Panel & uix.mixin.Panel
    %uix.BoxPanel  Box panel
    %
    %  p = uix.BoxPanel(p1,v1,p2,v2,...) constructs a box panel and sets
    %  parameter p1 to value v1, etc.
    %
    %  A box panel is a decorated container with a title box, border, and
    %  buttons to dock and undock, minimize, get help, and close.  A box
    %  panel shows one of its contents and hides the others.
    %
    %  See also: uix.Panel, uipanel, uix.CardPanel
    
    %  Copyright 2009-2015 The MathWorks, Inc.
    %  $Revision: 1255 $ $Date: 2016-01-29 13:59:51 +0000 (Fri, 29 Jan 2016) $
    
    properties( Dependent )
        TitleColor % title background color [RGB]
        Minimized % minimized [true|false]
        MinimizeFcn % minimize callback
        Docked % docked [true|false]
        DockFcn % dock callback
        HelpFcn % help callback
        CloseRequestFcn % close request callback
    end
    
    properties( Dependent, SetAccess = private )
        TitleHeight % title panel height [pixels]
    end
    
    properties( Access = private )
        TitleBox % title bar box
        TitleText % title text label
        EmptyTitle = '' % title when empty, [] otherwise
        TitleAccess = 'public' % 'private' when getting or setting Title, 'public' otherwise
        TitleHeight_ = -1 % cache of title text height (-1 denotes stale cache)
        MinimizeButton % title button
        DockButton % title button
        HelpButton % title button
        CloseButton % title button
        Docked_ = true % backing for Docked
        Minimized_ = false % backing for Minimized
    end
    
    properties( Constant, Access = private )
        NullTitle = char.empty( [2 0] ) % an obscure empty string, the actual panel Title
        BlankTitle = ' ' % a non-empty blank string, the empty uicontrol String
    end
    
    methods
        
        function obj = BoxPanel( varargin )
            %uix.BoxPanel  Box panel constructor
            %
            %  p = uix.BoxPanel() constructs a box panel.
            %
            %  p = uix.BoxPanel(p1,v1,p2,v2,...) sets parameter p1 to value
            %  v1, etc.
            
            % Define default colors
            foregroundColor = [1 1 1];
            backgroundColor = [0.05 0.25 0.5];
            
            % Set default colors
            obj.ForegroundColor = foregroundColor;
            
            % Create panels and decorations
            titleBox = uix.HBox( 'Internal', true, 'Parent', obj, ...
                'Units', 'pixels', 'BackgroundColor', backgroundColor );
            titleText = uix.Text( 'Parent', titleBox, ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'String', obj.BlankTitle, 'HorizontalAlignment', 'left' );
            
            % Create buttons
            minimizeButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'Enable', 'on' );
            dockButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'Enable', 'on' );
            helpButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'String', '?', ...
                'TooltipString', 'Get help on this panel', 'Enable', 'on' );
            closeButton = uix.Text( ...
                'ForegroundColor', foregroundColor, ...
                'BackgroundColor', backgroundColor, ...
                'FontWeight', 'bold', 'String', char( 215 ), ...
                'TooltipString', 'Close this panel', 'Enable', 'on' );
            
            % Store properties
            obj.Title = obj.NullTitle;
            obj.TitleBox = titleBox;
            obj.TitleText = titleText;
            obj.MinimizeButton = minimizeButton;
            obj.DockButton = dockButton;
            obj.HelpButton = helpButton;
            obj.CloseButton = closeButton;
            
            % Create listeners
            addlistener( obj, 'BorderWidth', 'PostSet', ...
                @obj.onBorderWidthChanged );
            addlistener( obj, 'BorderType', 'PostSet', ...
                @obj.onBorderTypeChanged );
            addlistener( obj, 'FontAngle', 'PostSet', ...
                @obj.onFontAngleChanged );
            addlistener( obj, 'FontName', 'PostSet', ...
                @obj.onFontNameChanged );
            addlistener( obj, 'FontSize', 'PostSet', ...
                @obj.onFontSizeChanged );
            addlistener( obj, 'FontUnits', 'PostSet', ...
                @obj.onFontUnitsChanged );
            addlistener( obj, 'FontWeight', 'PostSet', ...
                @obj.onFontWeightChanged );
            addlistener( obj, 'ForegroundColor', 'PostSet', ...
                @obj.onForegroundColorChanged );
            addlistener( obj, 'Title', 'PreGet', ...
                @obj.onTitleReturning );
            addlistener( obj, 'Title', 'PostGet', ...
                @obj.onTitleReturned );
            addlistener( obj, 'Title', 'PostSet', ...
                @obj.onTitleChanged );
            
            % Draw buttons
            obj.redrawButtons()
            
            % Set properties
            if nargin > 0
                uix.pvchk( varargin )
                set( obj, varargin{:} )
            end
            
        end % constructor
        
    end % structors
    
    methods
        
        function value = get.TitleColor( obj )
            
            value = obj.TitleBox.BackgroundColor;
            
        end % get.TitleColor
        
        function set.TitleColor( obj, value )
            
            % Set
            obj.TitleBox.BackgroundColor = value;
            obj.TitleText.BackgroundColor = value;
            obj.MinimizeButton.BackgroundColor = value;
            obj.DockButton.BackgroundColor = value;
            obj.HelpButton.BackgroundColor = value;
            obj.CloseButton.BackgroundColor = value;
            
        end % set.TitleColor
        
        function value = get.CloseRequestFcn( obj )
            
            value = obj.CloseButton.Callback;
            
        end % get.CloseRequestFcn
        
        function set.CloseRequestFcn( obj, value )
            
            % Set
            obj.CloseButton.Callback = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.CloseRequestFcn
        
        function value = get.DockFcn( obj )
            
            value = obj.DockButton.Callback;
            
        end % get.DockFcn
        
        function set.DockFcn( obj, value )
            
            % Set
            obj.DockButton.Callback = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.DockFcn
        
        function value = get.HelpFcn( obj )
            
            value = obj.HelpButton.Callback;
            
        end % get.HelpFcn
        
        function set.HelpFcn( obj, value )
            
            % Set
            obj.HelpButton.Callback = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.HelpFcn
        
        function value = get.MinimizeFcn( obj )
            
            value = obj.MinimizeButton.Callback;
            
        end % get.MinimizeFcn
        
        function set.MinimizeFcn( obj, value )
            
            % Set
            obj.MinimizeButton.Callback = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.MinimizeFcn
        
        function value = get.Docked( obj )
            
            value = obj.Docked_;
            
        end % get.Docked
        
        function set.Docked( obj, value )
            
            % Check
            assert( islogical( value ) && isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Docked'' must be true or false.' )
            
            % Set
            obj.Docked_ = value;
            
            % Mark as dirty
            obj.redrawButtons()
            
        end % set.Docked
        
        function value = get.Minimized( obj )
            
            value = obj.Minimized_;
            
        end % get.Minimized
        
        function set.Minimized( obj, value )
            
            % Check
            assert( islogical( value ) && isequal( size( value ), [1 1] ), ...
                'uix:InvalidPropertyValue', ...
                'Property ''Minimized'' must be true or false.' )
            
            % Set
            obj.Minimized_ = value;
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % set.Minimized
        
        function value = get.TitleHeight( obj )
            
            value = obj.TitleBox.Position(4);
            
        end % get.TitleHeight
        
    end % accessors
    
    methods( Access = private )
        
        function onBorderWidthChanged( obj, ~, ~ )
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onBorderWidthChanged
        
        function onBorderTypeChanged( obj, ~, ~ )
            
            % Mark as dirty
            obj.Dirty = true;
            
        end % onBorderTypeChanged
        
        function onFontAngleChanged( obj, ~, ~ )
            
            obj.TitleText.FontAngle = obj.FontAngle;
            
        end % onFontAngleChanged
        
        function onFontNameChanged( obj, ~, ~ )
            
            % Set
            obj.TitleText.FontName = obj.FontName;
            
            % Mark as dirty
            obj.TitleHeight_ = -1;
            obj.Dirty = true;
            
        end % onFontNameChanged
        
        function onFontSizeChanged( obj, ~, ~ )
            
            % Set
            fontSize = obj.FontSize;
            obj.TitleText.FontSize = fontSize;
            obj.HelpButton.FontSize = fontSize;
            obj.CloseButton.FontSize = fontSize;
            obj.DockButton.FontSize = fontSize;
            obj.MinimizeButton.FontSize = fontSize;
            
            % Mark as dirty
            obj.TitleHeight_ = -1;
            obj.Dirty = true;
            
        end % onFontSizeChanged
        
        function onFontUnitsChanged( obj, ~, ~ )
            
            fontUnits = obj.FontUnits;
            obj.TitleText.FontUnits = fontUnits;
            obj.HelpButton.FontUnits = fontUnits;
            obj.CloseButton.FontUnits = fontUnits;
            obj.DockButton.FontUnits = fontUnits;
            obj.MinimizeButton.FontUnits = fontUnits;
            
        end % onFontUnitsChanged
        
        function onFontWeightChanged( obj, ~, ~ )
            
            obj.TitleText.FontWeight = obj.FontWeight;
            
        end % onFontWeightChanged
        
        function onForegroundColorChanged( obj, ~, ~ )
            
            foregroundColor = obj.ForegroundColor;
            obj.TitleText.ForegroundColor = foregroundColor;
            obj.MinimizeButton.ForegroundColor = foregroundColor;
            obj.DockButton.ForegroundColor = foregroundColor;
            obj.HelpButton.ForegroundColor = foregroundColor;
            obj.CloseButton.ForegroundColor = foregroundColor;
            
        end % onForegroundColorChanged
        
        function onTitleReturning( obj, ~, ~ )
            
            if strcmp( obj.TitleAccess, 'public' )
                
                obj.TitleAccess = 'private'; % start
                if ischar( obj.EmptyTitle )
                    obj.Title = obj.EmptyTitle;
                else
                    obj.Title = obj.TitleText.String;
                end
                
            end
            
        end % onTitleReturning
        
        function onTitleReturned( obj, ~, ~ )
            
            obj.Title = obj.NullTitle; % unset Title
            obj.TitleAccess = 'public'; % finish
            
        end % onTitleReturned
        
        function onTitleChanged( obj, ~, ~ )
            
            if strcmp( obj.TitleAccess, 'public' )
                
                % Set
                obj.TitleAccess = 'private'; % start
                title = obj.Title;
                if isempty( title )
                    obj.EmptyTitle = title; % store
                    obj.TitleText.String = obj.BlankTitle; % set String to blank
                else
                    obj.EmptyTitle = []; % not empty
                    obj.TitleText.String = title; % set String to title
                end
                obj.Title = obj.NullTitle; % unset Title
                obj.TitleAccess = 'public'; % finish
                
                % Mark as dirty
                obj.TitleHeight_ = -1;
                obj.Dirty = true;
                
            end
            
        end % onTitleChanged
        
    end % property event handlers
    
    methods( Access = protected )
        
        function redraw( obj )
            %redraw  Redraw
            %
            %  p.redraw() redraws the panel.
            %
            %  See also: redrawButtons
            
            % Compute bounds
            bounds = hgconvertunits( ancestor( obj, 'figure' ), ...
                [0 0 1 1], 'normalized', 'pixels', obj );
            
            % Position decorations
            tX = 1;
            tW = max( bounds(3), 1 );
            tH = obj.TitleHeight_; % title height
            if tH == -1 % cache stale, refresh
                tH = ceil( obj.TitleText.Extent(4) );
                obj.TitleHeight_ = tH; % store
            end
            tY = 1 + bounds(4) - tH;
            obj.TitleBox.Position = [tX tY tW tH];
            obj.redrawButtons()
            
            % Position contents
            p = obj.Padding_;
            cX = 1 + p;
            cW = max( bounds(3) - 2 * p, 1 );
            cH = max( bounds(4) - tH - 2 * p, 1 );
            cY = tY - p - cH;
            contentsPosition = [cX cY cW cH];
            obj.redrawContents( contentsPosition )
            
        end % redraw
        
        function redrawContents( obj, position )
            %redrawContents  Redraw contents
            
            % Call superclass method
            redrawContents@uix.mixin.Panel( obj, position )
            
            % If minimized, hide selected contents too
            if obj.Selection_ ~= 0 && obj.Minimized_
                child = obj.Contents_(obj.Selection_);
                child.Visible = 'off';
                if isa( child, 'matlab.graphics.axis.Axes' )
                    child.ContentsVisible = 'off';
                end
                % As a remedy for g1100294, move off-screen too
                if isa( child, 'matlab.graphics.axis.Axes' ) ...
                        && strcmp(child.ActivePositionProperty, 'outerposition' )
                    child.OuterPosition(1) = -child.OuterPosition(3)-20;
                else
                    child.Position(1) = -child.Position(3)-20;
                end
            end
            
        end % redrawContents
        
    end % template methods
    
    methods( Access = private )
        
        function redrawButtons( obj )
            %redrawButtons  Redraw buttons
            %
            %  p.redrawButtons() redraws the titlebar buttons.
            %
            %  Buttons use unicode arrow symbols:
            %  https://en.wikipedia.org/wiki/Arrow_%28symbol%29#Arrows_in_Unicode
            
            % Retrieve button box and buttons
            box = obj.TitleBox;
            minimizeButton = obj.MinimizeButton;
            dockButton = obj.DockButton;
            helpButton = obj.HelpButton;
            closeButton = obj.CloseButton;
            
            % Detach all buttons
            minimizeButton.Parent = [];
            dockButton.Parent = [];
            helpButton.Parent = [];
            closeButton.Parent = [];
            
            % Attach active buttons
            minimize = ~isempty( obj.MinimizeFcn );
            if minimize
                minimizeButton.Parent = box;
                box.Widths(end) = minimizeButton.Extent(3);
            end
            dock = ~isempty( obj.DockFcn );
            if dock
                dockButton.Parent = box;
                box.Widths(end) = dockButton.Extent(3);
            end
            help = ~isempty( obj.HelpFcn );
            if help
                helpButton.Parent = box;
                box.Widths(end) = helpButton.Extent(3);
            end
            close = ~isempty( obj.CloseRequestFcn );
            if close
                closeButton.Parent = box;
                box.Widths(end) = closeButton.Extent(3);
            end
            
            % Update icons
            if obj.Minimized_
                minimizeButton.String = char( 9662 );
                minimizeButton.TooltipString = 'Expand this panel';
            else
                minimizeButton.String = char( 9652 );
                minimizeButton.TooltipString = 'Collapse this panel';
            end
            if obj.Docked_
                dockButton.String = char( 8599 );
                dockButton.TooltipString = 'Undock this panel';
            else
                dockButton.String = char( 8600 );
                dockButton.TooltipString = 'Dock this panel';
            end
            
        end % redrawButtons
        
    end % helper methods
    
end % classdef