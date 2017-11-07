classdef Background 
    %UNTITLED26 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Model
       
        InitialPoints
        
        Order = 3;
    end
    
    properties (Dependent, SetAccess = private)
        InitialPointsIdx
        
    end
    
    properties (Hidden)
        % DiffractionData object
        xrd
        
        
    end
    
    properties (Constant, Hidden)
        ModelNames = {'Polynomial', 'Spline'};
    end
    
    methods
        function this = Background(xrd, points)
        %BACKGROUND Constructs the background model
        %
        %xrd - 2x? array or raw data
        %
        %MODEL - Currently only a string name of 'Polynomial' or 'Spline'
        import model.*
        import utils.*
        
        if nargin > 1
            this.InitialPoints = sort(points);
        end
        
        this.xrd = xrd;
        this.Model = this.ModelNames{1};
        end
        
        function this = update2T(this, range)
        this.xrd.Min2T = range(1);
        this.xrd.Max2T = range(2);
        end
        
        function this = set.InitialPoints(this, points)
        this.InitialPoints = unique(points);
        end
        
        function bkgdArray = calculateFit(this, file)
        % Calculates the resulting background fit.        
        twotheta = this.xrd.getTwoTheta();
        bkgdArray = [];
        
        if ~isempty(this.xrd.BkgCoeff)&& this.xrd.BkgLS % for when viewing Bkg after refining it
            P=this.xrd.BkgCoeff;
            if length(this.xrd.BkgCoeff)~=this.Order+1 % for when
                order = this.Order;
                x = this.InitialPoints;
                intensity = this.xrd.getData(file);
                y = intensity(this.InitialPointsIdx);
                [P, s, mu] = polyfit(x, y, order);
            else
            mu=[mean(twotheta) std(twotheta)]; % centering and scaling         
            end
try % this for when previewing... mu from polyval not same as mu from line 75
            bkgdArray = polyval(P,twotheta,[],mu);
catch
                mu=[mean(twotheta) std(twotheta)]; % centering and scaling         
                bkgdArray = polyval(P,twotheta,[],mu);
end
        else
            
        if length(this.InitialPoints) < this.Order
            return
        end
        if strcmpi(this.Model, this.ModelNames{1})
            [P, S, U] = this.getPolyFit(file);
            bkgdArray = polyval(P, twotheta, S, U);
        elseif strcmpi(this.Model, this.ModelNames{2})
            P = this.getSplineFit(file);
            bkgdArray = fnval(P, twotheta);
        end
        
        end
        end
        
        function value = get.InitialPointsIdx(this)
        twotheta = this.xrd.getTwoTheta();
        value = utils.findIndex(twotheta, this.InitialPoints);
        end
        
    end
    
    methods (Hidden)
         function [points, idx] = getInitialPoints(this)
        % Returns the 2theta points and their indices
        if isempty(this.InitialPoints)
            points = [];
            idx = [];
        
        else
            points = this.InitialPoints;
            idx = this.InitialPointsIdx;
        end
        
         end
        
        function [p, s, u] = getPolyFit(this, file)
            
        intensity = this.xrd.getData(file);
        x = this.InitialPoints;
        y = intensity(this.InitialPointsIdx);
        order = this.Order;
        [p, s, u] = polyfit(x, y, order);
        end
        
        
        function result = getSplineFit(this, file)
        %GETSPLINEFIT fits a spline function to the dataset using initial points set by the user.
        twotheta = this.xrd.getTwoTheta();
        intensity = this.xrd.getData(file);
        
        idx = this.InitialPointsIdx;
        
        
        x = [twotheta(1), this.InitialPoints, twotheta(end)];
        y = [intensity(2), intensity(idx), intensity(end)];
        order = this.Order;
        
        result = spapi(order,x,y);
        
        end
        
        
        
    end
    
    
    methods (Static)
        
        
        
    end
    
    methods (Hidden)
       function [P, S, U] = getFit(this)
        % Returns a fit object for the background.
        if strcmpi(this.Model, this.ModelNames{1})
            [P, S, U] = this.getPolyFit();
            
        elseif strcmpi(this.Model, this.ModelNames{2})
            P = this.getSplineFit();
            S = []; % empty in case nargout > 1
            U = [];
        end
        
        end
         
    end
    
    
end

