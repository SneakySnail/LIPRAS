function g = makeFunction(Stro,Fxn,data,position)
% Function for each profile
% Fxn - cell array of function names per peak
% data - data to fit
% position - numeric array of peak positions
if length(Fxn) == length(position)
		numpeaks = length(position);
else
		errordlg('Number of functions does not match number of peak positions.')
		return
end

coeff = Stro.getCoeff(Fxn, Stro.Constrains);
strFxn = '';

for i=1:numpeaks
		strFxn = [strFxn, Stro.makeFunctionStr(Fxn{i}, i)];
		if i~= numpeaks; strFxn = [strFxn,'+']; end
end

g = fittype(strFxn, 'coefficients', coeff, 'independent','x');
end
