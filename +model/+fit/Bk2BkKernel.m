function k = Bk2BkKernel(xv, aL, bR)
% Back to back exponential kernel on the xv grid
% Returns an ifftshifted kernel scaled by dx so ConvFFT does not need xv

x = xv(:);

aL = max(1e-12, aL);
bR = max(1e-12, bR);

if numel(x) < 2 || any(~isfinite(x))
    k = nan(size(xv));
    return
end

dx = median(diff(x));
if ~isfinite(dx) || dx <= 0
    k = nan(size(xv));
    return
end

n = numel(x);
t = ((0:n-1) - floor(n/2)).' * dx;

k0 = zeros(n,1);
c = (aL*bR/(aL + bR));

idxL = t < 0;
idxR = ~idxL;

k0(idxL) = c .* exp( aL .* t(idxL) );
k0(idxR) = c .* exp(-bR .* t(idxR) );

% shift so zero lag is at index 1 for FFT
k0 = ifftshift(k0);

% scale by dx so FFT product approximates integral
k0 = k0 .* dx;

k = k0;
if isrow(xv), k = k.'; end
end