classdef GaussBk2BkExpConv < model.fit.FitFunctionInterface
    % Gaussian convolved with back-to-back exponential tails (TOF-friendly)
    %
    % Coeffs (ID-suffixed by FitFunctionInterface.getCoeffs):
    %   N  : scale
    %   x  : center
    %   f  : Gaussian FWHM (sigma = f/(2*sqrt(2*log(2))))
    %   aL : left tail decay rate  (>0)
    %   bR : right tail decay rate (>0)

    properties
        Name = 'Gauss-Bk2BkExpConv';
        CoeffNames = {'N','x','f','aL','bR'};
        ID
        Asym=0;        
    end

properties (Hidden)
    ActiveCoeffList = {}
end

    methods
        function this = GaussBk2BkExpConv(id, constraints)
            if nargin < 1, id = 1; end
            if nargin < 2, constraints = ''; end
            this@model.fit.FitFunctionInterface(id, constraints);

            % Keep the same constraint hooks pattern as your other classes
            if ~isempty(find(strcmpi(this.ConstrainedCoeffs, 'w'), 1))
                this = this.constrain('w');
            end
            if ~isempty(find(strcmpi(this.ConstrainedCoeffs, 'm'), 1))
                this = this.constrain('m');
            end
        end

        function str = getEqnStr(this, xval)
        import utils.contains
        coeff = this.getCoeffs;
    
        Nidx  = find(contains(coeff,'N'),  1);
        xidx  = find(contains(coeff,'x'),  1);
        fidx  = find(contains(coeff,'f'),  1);
    
        aLname = ['aL' num2str(this.ID)];
        bRname = ['bR' num2str(this.ID)];
        aLidx  = find(strcmpi(coeff, aLname), 1);
        bRidx  = find(strcmpi(coeff, bRname), 1);
    
        if ~isempty(aLidx), aLname = coeff{aLidx}; end
        if ~isempty(bRidx), bRname = coeff{bRidx}; end
    
        if nargin > 1
            coeff{xidx} = num2str(xval);
        end
    
        sigStr = ['(' coeff{fidx} '/(2*sqrt(2*log(2))))'];
    
        uStr = ['0.5*' aLname '*(' aLname '*' sigStr '^2+2*(xv-' coeff{xidx} '))'];
        YStr = ['(' aLname '*' sigStr '^2+(xv-' coeff{xidx} '))/(sqrt(2)*' sigStr ')'];
    
        vStr = ['0.5*' bRname '*(' bRname '*' sigStr '^2-2*(xv-' coeff{xidx} '))'];
        ZStr = ['(' bRname '*' sigStr '^2-(xv-' coeff{xidx} '))/(sqrt(2)*' sigStr ')'];
    
        str = [coeff{Nidx} '*0.5*(' aLname '*' bRname '/(' aLname '+' bRname '))' ...
            '*(exp(min((' uStr '),700))*erfc(' YStr ') + exp(min((' vStr '),700))*erfc(' ZStr '))']; % exp(min(u,700)) keeps exp from blowing up
        end

        function value = getCoeffs(this)
            % Use your base interface generator (adds ID suffixes, respects constraints)
            value = getCoeffs@model.fit.FitFunctionInterface(this);
        end

     function output = getDefaultInitialValues(this, data, peakpos)

        value = getDefaultInitialValues@model.fit.FitFunctionInterface(this, data, peakpos);
    
        output.N = value.N;
        output.x = value.x;
    
        x = data(1,:); 
        y = data(2,:);
        x = x(:); y = y(:);
    
        dx = median(diff(x));
        if ~isfinite(dx) || dx <= 0
            dx = (x(end)-x(1)) / max(10, numel(x)-1);
        end
    
        % center at local max
        [ypk, imax] = max(y);
        xc = x(imax);
        if ~isfinite(ypk) || ypk <= 0
            xc = peakpos;
            ypk = max(y);
        end
        % output.x = xc;
    
        % --- FWHM estimate (then make it a bit sharper) ---
        f0 = value.f;
        if isfinite(ypk) && ypk > 0
            yhalf = 0.5*ypk;
            iL = find(x < xc & y <= yhalf, 1, 'last');
            iR = find(x > xc & y <= yhalf, 1, 'first');
            if ~isempty(iL) && ~isempty(iR)
                f0 = x(iR) - x(iL);
            else
                f0 = abs(trapz(x,y)) / max(ypk, eps);
            end
        end
    
        f0 = 0.75*f0;          % <-- sharper start (15% narrower)
        f0 = max(f0, 1.5*dx);   % <-- allow narrower than before
        output.f = f0;
    
        % --- Tail rates: use higher fraction to make tails "sharper/intense" ---
        frac = 0.8;            % <-- was 0.05; higher -> larger aL/bR
        aL0 = 1; bR0 = 1;
    
        if isfinite(ypk) && ypk > 0
            ythr = frac*ypk;
    
            il = find(x < xc & y <= ythr, 1, 'last');
            ir = find(x > xc & y <= ythr, 1, 'first');
    
            if isempty(il), Lleft  = xc - x(1); else, Lleft  = xc - x(il); end
            if isempty(ir), Lright = x(end) - xc; else, Lright = x(ir) - xc; end
    
            % smaller minimum tail length -> larger rates
            Lleft  = max(Lleft,  f0/4);
            Lright = max(Lright, f0/4);
    
            aL0 = 1 / max(eps, Lleft);
            bR0 = 1 / max(eps, Lright);
        end
    
        % Clamp
        aL0 = min(max(aL0, 1e-6), 20/max(eps,dx));  % <-- allow larger max
        bR0 = min(max(bR0, 1e-6), 20/max(eps,dx));
    
        output.aL = aL0;
        output.bR = bR0;
    
        this.CoeffValues = output;
    end

        function output = getDefaultLowerBounds(this, data, peakpos)
            value = getDefaultLowerBounds@model.fit.FitFunctionInterface(this, data, peakpos);

            output.N  = value.N;
            output.x  = value.x;
            output.f  = value.f;

            % strictly positive tail rates
            output.aL = 0;
            output.bR = 0;
        end

        function output = getDefaultUpperBounds(this, data, peakpos)
            value = getDefaultUpperBounds@model.fit.FitFunctionInterface(this, data, peakpos);

            output.N  = value.N;
            output.x  = value.x;
            output.f  = value.f;
            output.aL = 20 / max(eps, output.f); 
            output.bR = 20 / max(eps, output.f);
        end
    end

    methods (Static)
        function result = isWConstrained()
            result = false;
        end

        function result = isMConstrained()
            result = false;
        end
    end

    methods (Access = protected)
        function output = calculate_(this, xdata, coeffvals)
        names = this.ActiveCoeffList;
        if isempty(names)
            % fallback if not set (shouldn't happen in normal flow)
            names = this.getCoeffs;
        end
        num = num2str(this.ID);
    
        function v = get1(base)
            name = [base num];                 % e.g. 'N3'
            idx = find(strcmpi(names, name), 1, 'first');
            if ~isempty(idx)
                v = coeffvals(idx);
                return
            end
            % constrained fallback
            if isstruct(this.CoeffValues) && isfield(this.CoeffValues, base)
                v = this.CoeffValues.(base);
                return
            end
            error('Missing %s in coeffvals and CoeffValues.%s not set.', name, base);
        end
    
        N  = get1('N');
        xv = get1('x');
        f  = get1('f');
        aL = get1('aL');
        bR = get1('bR');
        
        sigma = max(eps, f/(2*sqrt(2*log(2))));
        x = xdata(:);
        
        u = 0.5 .* aL .* (aL.*sigma.^2 + 2.*(x - xv));
        Y = (aL.*sigma.^2 + (x - xv)) ./ (sqrt(2).*sigma);
        
        v = 0.5 .* bR .* (bR.*sigma.^2 - 2.*(x - xv));
        Z = (bR.*sigma.^2 - (x - xv)) ./ (sqrt(2).*sigma);
        
        % clamp to avoid overflow
        u = min(u, 700);
        v = min(v, 700);
        
        pref = 0.5 .* N .* (aL.*bR./(aL + bR));
        output = pref .* ( exp(u).*erfc(Y) + exp(v).*erfc(Z) );
    
        if isrow(xdata), output = output.'; end
        end

    end
end