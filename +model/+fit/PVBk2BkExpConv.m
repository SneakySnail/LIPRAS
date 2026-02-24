classdef PVBk2BkExpConv < model.fit.FitFunctionInterface
    % Pseudo-Voigt convolved with back-to-back exponential tails (TOF-friendly)
    %
    % Coeffs (ID-suffixed by FitFunctionInterface.getCoeffs):
    %   N  : scale
    %   x  : center
    %   f  : FWHM for both Gaussian and Lorentzian components
    %   w  : Lorentzian fraction (0..1)
    %   aL : left tail decay rate  (>0)
    %   bR : right tail decay rate (>0)
    %
    % Notes:
    % - Core pseudo-Voigt is area-normalized; N scales the peak.
    % - Tail convolution is done numerically using FFT (assumes roughly uniform x spacing).

    properties
        Name = 'PV-Bk2BkExpConv';
        CoeffNames = {'N','x','f','w','aL','bR'};
        ID
        Asym=0;        

    end

    methods
        function this = PVBk2BkExpConv(id, constraints)
            if nargin < 1, id = 1; end
            if nargin < 2, constraints = ''; end
            this@model.fit.FitFunctionInterface(id, constraints);

            if ~isempty(find(strcmpi(this.ConstrainedCoeffs, 'm'), 1))
                this = this.constrain('m');
            end
        end

        function str = getEqnStr(this, xval)
            import utils.contains
            coeff = this.getCoeffs;
        
            Nidx = find(contains(coeff,'N'),1);
            xidx = find(contains(coeff,'x'),1);
            fidx = find(contains(coeff,'f'),1);
            widx = find(contains(coeff,'w'),1);
        
            % ID suffixed tail coeffs
            aLtok = ['aL' num2str(this.ID)];
            bRtok = ['bR' num2str(this.ID)];
        
            aLidx = find(strcmpi(coeff, aLtok), 1);
            bRidx = find(strcmpi(coeff, bRtok), 1);
        
            aLname = aLtok;
            bRname = bRtok;
            if ~isempty(aLidx), aLname = coeff{aLidx}; end
            if ~isempty(bRidx), bRname = coeff{bRidx}; end
        
            % Center expression (x0): default is the parameter name, or substitute a value/string
            x0 = coeff{xidx};
            if nargin > 1 && ~isempty(xval)
                if isnumeric(xval)
                    x0 = num2str(xval);
                else
                    x0 = char(string(xval));
                end
            end
        
            % Use fully-qualified names so fittype can resolve them
            coreStr = ['model.fit.PVoigtCore(xv,' x0 ',' coeff{fidx} ',' coeff{widx} ')'];
            kerStr  = ['model.fit.Bk2BkKernel(xv,' aLname ',' bRname ')'];
            str     = [coeff{Nidx} '*model.fit.ConvFFT(' coreStr ',' kerStr ')'];
        end


        function value = getCoeffs(this)
            value = getCoeffs@model.fit.FitFunctionInterface(this);
        end

        function output = getDefaultInitialValues(this, data, peakpos)
        value = getDefaultInitialValues@model.fit.FitFunctionInterface(this, data, peakpos);

        output.w = value.w;    
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
        frac = 1;            % <-- was 0.05; higher -> larger aL/bR
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

            output.N = value.N;
            output.x = value.x;
            output.f = value.f;
            output.w = value.w;

            output.aL = 0;
            output.bR = 0;
        end

        function output = getDefaultUpperBounds(this, data, peakpos)
            value = getDefaultUpperBounds@model.fit.FitFunctionInterface(this, data, peakpos);

            output.N = value.N;
            output.x = value.x;
            output.f = value.f;
            output.w = value.w;

            output.aL = 20 / max(eps, output.f); 
            output.bR = 20 / max(eps, output.f);
        end
    end

    methods (Static)
        function result = isMConstrained()
            result = false;
        end
    end

    methods (Access = protected)
        function output = calculate_(this, xdata, coeffvals)
            coeffs = this.getCoeffs;
            num = num2str(this.ID);
        
            get1 = @(base) coeffvals( find(strcmpi(coeffs, [base num]), 1, 'first') );
        
            N  = get1('N');
            x0 = get1('x');
            f  = get1('f');
            w  = get1('w');
            aL = max(1e-12, get1('aL'));
            bR = max(1e-12, get1('bR'));
        
            x = xdata(:);
            dx = median(diff(x));
        
            if any(~isfinite(x)) || numel(x) < 8 || ~isfinite(dx) || dx <= 0
                output = nan(size(xdata));
                return
            end
        
            nonUniform = max(abs(diff(x) - dx)) > 1e-6*max(1,abs(dx));
        
            if nonUniform
                xU = linspace(x(1), x(end), numel(x)).';
                coreU = model.fit.PVoigtCore(xU, x0, f, w);
                kU    = model.fit.Bk2BkKernel(xU, aL, bR);
                yU    = model.fit.ConvFFT(coreU, kU);          % padded linear conv, same length
                out   = N .* interp1(xU, yU, x, 'linear', 'extrap');
            else
                core = model.fit.PVoigtCore(x, x0, f, w);
                k    = model.fit.Bk2BkKernel(x, aL, bR);
                y    = model.fit.ConvFFT(core, k);
                out  = N .* y;
            end
        
            output = out;
            if isrow(xdata), output = output.'; end
        end
    end
end