classdef Background 
    %UNTITLED26 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Model
       
        InitialPoints
        
        Order = 1;
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
        twotheta = this.xrd.getTwoTheta(file);
        bkgdArray = [];
        
        if ~isempty(this.xrd.BkgCoeff)&& this.xrd.BkgLS % for when viewing Bkg after refining it
            P=fliplr(this.xrd.BkgCoeff);
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
            if this.xrd.CF
            bkgdArray = fnval(P, twotheta);
            else
            bkgdArray = bspline_eval(this,P,twotheta)'; % When not CF installed
            end
        end
        
        end
        end
        
        function value = get.InitialPointsIdx(this)
        twotheta = this.xrd.getTwoTheta(this.xrd.CurrentPro);
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
        this.xrd.CurrentPro=file;    
        intensity = this.xrd.getData(file);
        x = this.InitialPoints;
        y = intensity(this.InitialPointsIdx);
        order = this.Order;
        [p, s, u] = polyfit(x, y, order);
        end
        
        
        function result = getSplineFit(this, file)
        %GETSPLINEFIT fits a spline function to the dataset using initial points set by the user.
        twotheta = this.xrd.getTwoTheta(file);
        intensity = this.xrd.getData(file);
        
        idx = this.InitialPointsIdx;
        
        
        x = [twotheta(1), this.InitialPoints, twotheta(end)];
        y = [intensity(2), intensity(idx), intensity(end)];
        order = this.Order;
        
        if this.xrd.CF
        result = spapi(order,x,y);
        else
        result = bspline_interpolant(this,x,y,order);   % order = 4 or 5
        end
        
        end



        function S = bspline_interpolant(this,x, y, k)
        %BSPLINE_INTERPOLANT  Interpolating B-spline of order k (degree k-1).
        %   S = bspline_interpolant(x,y,k) returns a struct S with fields:
        %     S.order, S.knots, S.coefs
        %
        %   Evaluate later with: yq = bspline_eval(S, xq)
        
            x = x(:); y = y(:);
            n = numel(x);
        
            if numel(y) ~= n
                error('x and y must have the same length.');
            end
            if any(~isfinite(x)) || any(~isfinite(y))
                error('x and y must be finite.');
            end
            if any(diff(x) <= 0)
                error('x must be strictly increasing.');
            end
            if k < 2 || k > n
                error('Order k must satisfy 2 <= k <= numel(x).');
            end
        
            % ---- Open/clamped knot vector (averaged internal knots) ----
            t = zeros(n + k, 1);
            t(1:k) = x(1);
            t(end-k+1:end) = x(end);
        
            % Averaged internal knots (standard for global interpolation)
            for i = 1:(n - k)
                t(k + i) = mean(x(i+1 : i+k-1));
            end
        
            % ---- Build basis matrix A(i,j) = N_{j,k}(x_i) ----
            A = zeros(n, n);
            for i = 1:n
                A(i,:) = bspline_basis_all(this, x(i), t, k, n);
            end
        
            % Solve for B-spline coefficients (control-point ordinates)
            c = A \ y;
        
            S.order = k;
            S.knots = t;
            S.coefs = c;
        end
        
        
        function N = bspline_basis_all(this,xq, t, k, n)
        % Returns row vector N(1:n): all B-spline basis values of order k at xq.
        
            % Order-1 bases
            N = zeros(1, n);
            for j = 1:n
                inSpan = (t(j) <= xq && xq < t(j+1));
                if xq == t(end) && (t(j) <= xq && xq <= t(j+1))
                    inSpan = true;
                end
                if inSpan, N(j) = 1; end
            end
        
            % Cox–de Boor recursion up to order k
            for d = 2:k
                Nnew = zeros(1, n);
                for j = 1:n
                    % left term
                    denom1 = t(j+d-1) - t(j);
                    term1 = 0;
                    if denom1 > 0
                        term1 = (xq - t(j)) / denom1 * N(j);
                    end
        
                    % right term
                    term2 = 0;
                    if j+1 <= n
                        denom2 = t(j+d) - t(j+1);
                        if denom2 > 0
                            term2 = (t(j+d) - xq) / denom2 * N(j+1);
                        end
                    end
        
                    Nnew(j) = term1 + term2;
                end
                N = Nnew;
            end
        end



        function yq = bspline_eval(this, S, xq)
%BSPLINE_EVAL  Evaluate interpolating B-spline made by bspline_interpolant.

    t = S.knots;
    c = S.coefs;
    k = S.order;
    n = numel(c);

    xq = xq(:);
    yq = zeros(size(xq));

    % valid param range for open knot vector:
    xmin = t(k);
    xmax = t(n+1);

    for m = 1:numel(xq)
        x = min(max(xq(m), xmin), xmax);

        % Find knot span i such that t(i) <= x < t(i+1)
        i = find(t <= x, 1, 'last');
        i = min(max(i, k), n);  % clamp span index

        % de Boor points
        d = c(i-k+1 : i);

        % de Boor recursion
        for r = 1:(k-1)
            for j = k:-1:(r+1)
                idx = i - k + j;  % knot index
                denom = t(idx + k - r) - t(idx);
                if denom == 0
                    alpha = 0;
                else
                    alpha = (x - t(idx)) / denom;
                end
                d(j) = (1 - alpha)*d(j-1) + alpha*d(j);
            end
        end

        yq(m) = d(k);
    end

    % preserve input shape (row/col)
    if isrow(xq), yq = yq.'; end
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

