function y = ConvFFT(a, b)
% Linear convolution using FFT with zero padding, returns same length as a
% Expects b to already be ifftshifted if it represents a zero lag kernel

aa = a(:);
bb = b(:);

n = numel(aa);
if numel(bb) ~= n
    error('ConvFFT expects inputs with the same length')
end

if n < 2 || any(~isfinite(aa)) || any(~isfinite(bb))
    y = nan(size(a));
    return
end

nfft = 2^nextpow2(2*n);

A = fft(aa, nfft);
B = fft(bb, nfft);

yy = ifft(A .* B, nfft);
yy = real(yy(1:n));

y = yy;
if isrow(a), y = y.'; end
end