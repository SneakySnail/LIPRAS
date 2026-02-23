function core = PVoigtCore(xv, x0, f, w)
% Area normalized pseudo Voigt core with common FWHM f
% core = w*Lorentz + (1-w)*Gauss

x = xv(:);

f = max(eps, f);
w = min(max(w, 0), 1);

lor = (2/pi) .* (1./f) .* 1 ./ (1 + (4.*(x - x0).^2 ./ f.^2));
gau = (2*sqrt(log(2))/sqrt(pi)) .* (1./f) .* exp(-log(2).*4.*(x - x0).^2 ./ f.^2);

core = w.*lor + (1-w).*gau;

if isrow(xv), core = core.'; end
end