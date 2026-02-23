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
        
    doNotCollapse = {'aL','bR'};        % keep these as-is
    collapseLR    = {'N','x','f','w','m'}; % collapse NL/NR -> N, xL/xR -> x, etc.
    
    for i = 1:length(fcnCoeffNames)
        coeff = fcnCoeffNames{i};
        idx = find(strcmpi(coefflist, coeff), 1);
        if isempty(idx), continue; end
    
        base = regexprep(coeff, '\d+$', '');   % 'NL','bR','aL', etc.
    
        % Collapse legacy left/right tags (NL->N), but never collapse tails (aL,bR)
        if ~any(strcmpi(base, doNotCollapse))
            if numel(base)==2 && any(base(end)==['L','R']) && any(strcmpi(base(1), collapseLR))
                base = base(1);
            end
        end
    
        % --- case-insensitive struct field fetch ---
        result.start(idx) = getFieldCI(startvals, base);
        result.lower(idx) = getFieldCI(lowervals, base);
        result.upper(idx) = getFieldCI(uppervals, base);
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

function v = getFieldCI(s, name)
    if isfield(s, name)
        v = s.(name);
        return
    end
    fn = fieldnames(s);
    k = find(strcmpi(fn, name), 1);
    if isempty(k)
        error('Missing field "%s" in defaults struct. Available: %s', name, strjoin(fn.', ', '));
    end
    v = s.(fn{k});
end

end
