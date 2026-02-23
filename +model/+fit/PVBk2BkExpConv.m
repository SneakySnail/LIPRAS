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
            % There isn't a simple closed-form string here (numeric convolution).
            % Return a compact identifier string for display.
            coeff = this.getCoeffs;
            Nidx = find(contains(coeff,'N'),1);
            xidx = find(contains(coeff,'x'),1);
            fidx = find(contains(coeff,'f'),1);
            widx = find(contains(coeff,'w'),1);

            if nargin > 1
                coeff{xidx} = num2str(xval);
            end

            aLname = ['aL' num2str(this.ID)];
            bRname = ['bR' num2str(this.ID)];

            str = [coeff{Nidx} '*ConvFFT(PVoigtCore(' coeff{xidx} ',' coeff{fidx} ',' coeff{widx} '),Bk2Bk(' aLname ',' bRname '))'];
        end

        function value = getCoeffs(this)
            value = getCoeffs@model.fit.FitFunctionInterface(this);
        end

        function output = getDefaultInitialValues(this, data, peakpos)
            value = getDefaultInitialValues@model.fit.FitFunctionInterface(this, data, peakpos);

            output.N = value.N;
            output.x = value.x;
            output.f = value.f;
            output.w = value.w;

            % Tail guesses (same heuristic as Gaussian)
            try
                x = data.X(:);
                y = data.Y(:);
                [~, imax] = max(y);
                xc = x(imax);
                ypk = y(imax);
                ythr = max(ypk*0.05, min(y(y>0)));

                il = find(x < xc & y <= ythr, 1, 'last');
                if isempty(il), Lleft = max(eps, xc - min(x)); else, Lleft = max(eps, xc - x(il)); end

                ir = find(x > xc & y <= ythr, 1, 'first');
                if isempty(ir), Lright = max(eps, max(x) - xc); else, Lright = max(eps, x(ir) - xc); end

                output.aL = 1 / Lleft;
                output.bR = 1 / Lright;
            catch
                output.aL = 1;
                output.bR = 1;
            end
        end

        function output = getDefaultLowerBounds(this, data, peakpos)
            value = getDefaultLowerBounds@model.fit.FitFunctionInterface(this, data, peakpos);

            output.N = value.N;
            output.x = value.x;
            output.f = value.f;
            output.w = value.w;

            output.aL = 1e-6;
            output.bR = 1e-6;
        end

        function output = getDefaultUpperBounds(this, data, peakpos)
            value = getDefaultUpperBounds@model.fit.FitFunctionInterface(this, data, peakpos);

            output.N = value.N;
            output.x = value.x;
            output.f = value.f;
            output.w = value.w;

            output.aL = Inf;
            output.bR = Inf;
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
            xv = get1('x');
            f  = get1('f');
            w  = get1('w');
            aL = get1('aL');
            bR = get1('bR');

            aL = max(1e-12, aL);
            bR = max(1e-12, bR);

            % Ensure column vectors
            x = xdata(:);
            dx = median(diff(x));

            % If x is not ~uniform, resample to a uniform grid for convolution
            if any(~isfinite(x)) || numel(x) < 8 || dx <= 0
                output = nan(size(xdata));
                return
            end
            if max(abs(diff(x) - dx)) > 1e-6*max(1,abs(dx))
                xU = linspace(x(1), x(end), numel(x)).';
                % Build core on uniform grid and convolve there
                coreU = local_pvoigt_core(xU, xv, f, w);
                yU = local_bk2bk_conv_fft(xU, coreU, aL, bR);
                output = N .* interp1(xU, yU, x, 'linear', 'extrap');
            else
                core = local_pvoigt_core(x, xv, f, w);
                y = local_bk2bk_conv_fft(x, core, aL, bR);
                output = N .* y;
            end

            if isrow(xdata), output = output.'; end
        end
    end
end

% ---------- local helpers (file-scope) ----------
function core = local_pvoigt_core(x, xv, f, w)
    % Area-normalized Lorentzian + area-normalized Gaussian, common FWHM f
    % (matches your PseudoVoigt.calculate_ formula with Asym==0 and without N)
    lor = (2/pi) .* (1./f) .* 1./(1 + (4.*(x-xv).^2./f.^2));
    gau = (2*sqrt(log(2))/sqrt(pi)) .* (1./f) .* exp(-log(2).*4.*(x-xv).^2./f.^2);
    core = w.*lor + (1-w).*gau;
end

function y = local_bk2bk_conv_fft(x, core, aL, bR)
    % Numeric convolution y = (core * k)(x) with back-to-back exponential kernel k
    % Uses FFT; assumes x is uniform.
    n = numel(x);
    dx = x(2) - x(1);

    % centered lag grid
    t = ((0:n-1) - floor(n/2)).' * dx;

    k = zeros(n,1);
    k(t<0)  = (aL*bR/(aL+bR)) .* exp( aL.*t(t<0) );
    k(t>=0) = (aL*bR/(aL+bR)) .* exp(-bR.*t(t>=0));

    % shift so that zero-lag is at index 1 for FFT
    k = ifftshift(k);

    % FFT convolution (same length), scale by dx to approximate integral
    Y = ifft( fft(core) .* fft(k) );
    y = real(Y) .* dx;
end