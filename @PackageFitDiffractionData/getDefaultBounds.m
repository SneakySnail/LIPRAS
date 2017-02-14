function output = getDefaultBounds(Stro, boundname, varargin)
%GETDEFAULTBOUNDS returns the default values of the bounds specified by BOUNDNAME.
%
%   BOUNDNAME can be 'start', 'lower', or 'upper'
output = [];
if isempty(Stro.FitFunctions) || ~isempty(find(cellfun(@isempty,Stro.FitFunctions),1))
    return
elseif isempty(Stro.PeakPositions) || ~isempty(find(Stro.PeakPositions==0,1))
    return
end

coefflist = Stro.getCoeffs;
result = zeros(1, length(coefflist));

% Finds the first function to have a coefficient with the same name
for j=1:length(Stro.FitFunctions)
    data = [Stro.getTwoTheta; Stro.getDataNoBackground()];
    switch lower(boundname)
        case 'start'
            vals = Stro.FitFunctions{j}.getDefaultInitialValues(data, Stro.PeakPositions(j));
        case 'lower'
            vals = Stro.FitFunctions{j}.getDefaultLowerBounds(data, Stro.PeakPositions(j));
        case 'upper'
            vals = Stro.FitFunctions{j}.getDefaultUpperBounds(data, Stro.PeakPositions(j));
    end
   fcnCoeffNames = Stro.FitFunctions{j}.getCoeffs;
    for i=1:length(fcnCoeffNames)
        coeff = fcnCoeffNames{i};
        idx = find(strcmp(coefflist, coeff),1);
        result(idx) = vals.(coeff(1));
    end    
end
output = result;
end
