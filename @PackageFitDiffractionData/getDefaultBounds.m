function output = getDefaultBounds(Stro, boundname, varargin)
%GETDEFAULTBOUNDS returns the default values of the bounds specified by BOUNDNAME.
%
%   BOUNDNAME can be 'start', 'lower', or 'upper'
coefflist = Stro.getCoeffs;
result = struct('coeffs', {coefflist}, ...
    'start', -ones(1, length(coefflist)), ...
    'lower', -ones(1, length(coefflist)), ...
    'upper', -ones(1, length(coefflist)));

if isempty(Stro.FitFunctions) || ~isempty(find(cellfun(@isempty,Stro.FitFunctions),1))
    output = [];
    return
elseif isempty(Stro.PeakPositions) || ~isempty(find(Stro.PeakPositions==0,1))
    output = result;
    return
end


data = [Stro.getTwoTheta; Stro.getDataNoBackground()];
msg = '';
% Finds the first function to have a coefficient with the same name
for j=1:length(Stro.FitFunctions)
    try
        startvals = Stro.FitFunctions{j}.getDefaultInitialValues(data, Stro.PeakPositions(j));
        lowervals = Stro.FitFunctions{j}.getDefaultLowerBounds(data, Stro.PeakPositions(j));
        uppervals = Stro.FitFunctions{j}.getDefaultUpperBounds(data, Stro.PeakPositions(j));
        fcnCoeffNames = Stro.FitFunctions{j}.getCoeffs;
        
        for i=1:length(fcnCoeffNames)
            coeff = fcnCoeffNames{i};
            idx = find(strcmp(coefflist, coeff),1);
            result.start(idx) = startvals.(coeff(1));
            result.lower(idx) = lowervals.(coeff(1));
            result.upper(idx) = uppervals.(coeff(1));
        end
    catch ME
        if strcmp(ME.identifier, 'LIPRAS:FitFunction:NegativePeakArea')
            msg = ME.message;
        else
            rethrow(ME)
        end
    end
end
if ~isempty(msg)
    errordlg(msg, 'Bad Background Fit');
end

if nargin < 2
    output = result;
else
    switch lower(boundname)
        case 'start'
            output = result.start;
        case 'lower'
            output = result.lower;
        case 'upper'
            output = result.upper;
    end
end
end
