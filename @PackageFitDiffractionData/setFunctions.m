function funcObj = setFunctions(Stro, fcnName, fcnID)
%SETFUNCTIONS Creates the FitFunction objects of type Gaussian, Lorentzian,
%   Pearson VII, and Pseudo-Voigt, or any of their corresponding
%   asymmetric functions. The function type is specified by the string
%   fcnNames.
%
%   SETFUNCTIONS(STRO, FCNNAME) creates a cell array of FitFunction
%   objects specified in FCNNAME and saves it into the property
%   FITFUNCTIONS.
%
%   SETFUNCTIONS(STRO, FCNNAME, FCNID)
%
%   FCNNAME = SETFUNCTIONS(STRO, FCNNAME, FCNID)
%
%   FCNNAMES = A string cel array specifying the name of the fit functions
%   to use.
%

%   Logical array of size shape specifying if the function is supposed to
%   be asymmetric
%
%   FCNNAME options:
%       Gaussian              -
%       Lorentzian            -
%       Pearson VII           -
%       Asymmetric Pearson VII-
%       Pseudo-Voigt          -

if nargin > 2
    % Assuming FCNNAME is a string with a valid function name
    if ~isempty(fcnName)
        funcObj = setFitFunction_(Stro, fcnName, fcnID);
        Stro.FitFunctions{fcnID} = funcObj;
    else
        funcObj = [];
        Stro.FitFunctions{fcnID} = funcObj;
    end
    
elseif isempty(fcnName)
    Stro.FitFunctions = [];
    return
    
else
    if ischar(fcnName)
        fcnName = {fcnName};
    end
    newfcns = cell(1, length(fcnName));
    if isempty(Stro.FitFunctions)
        Stro.FitFunctions = newfcns;
    end
    
    oldfcns = Stro.FitFunctions;
    for i=1:length(fcnName)
        if i > length(oldfcns)
            break  
        elseif ~isempty(oldfcns{i}) && isequal(oldfcns{i}.Name,fcnName{i})
            newfcns{i} = Stro.FitFunctions{i};
        else
            newfcns{i} = Stro.setFunctions(fcnName{i}, i);
        end
    end
    Stro.FitFunctions = newfcns;
    funcObj = newfcns;
end

if Stro.CuKa
    Stro.CuKa2Peak = cell(1,Stro.NumFuncs);
    for i=1:Stro.NumFuncs
        fcn = Stro.FitFunctions{i};
        if ~isempty(fcn)
            fcn.CuKa = true;
            Stro.CuKa2Peak{i} = model.fit.CuKalpha2(fcn, Stro.KAlpha1, Stro.KAlpha2);
        end
    end
end

function fcnObj = setFitFunction_(Stro, fcnName, fcnID)
%SETFUNCTION Creates the FitFunction objects of type Gaussian, Lorentzian,
%   Pearson VII, and Pseudo-Voigt, or any of their corresponding
%   asymmetric functions. The function type is specified by the string
%   fcnNames.
%
%FCNNAMES - A string cel array specifying the name of the fit functions
%   to use.
%
import utils.contains
% Logical array of size shape specifying if the function is supposed to
%   be asymmetric
if isempty(fcnName)
    return
end

if ~isempty(Stro.FitFunctions) && ...
        ~isempty(Stro.FitFunctions{fcnID}) && ...
        isequal(Stro.FitFunctions{fcnID}.Name, fcnName)
    fcnObj = Stro.FitFunctions{fcnID};
    return
end

allowedFcns = {'Gaussian' 'Lorentzian' 'Pearson VII' 'Pseudo-Voigt' 'Gauss-Bk2BkExpConv' 'PV-Bk2BkExpConv'};
allowedFcns_ = {'Gaussian' 'Lorentzian' 'PearsonVII' 'PseudoVoigt' 'GaussBk2BkExpConv' 'PVBk2BkExpConv'};

isAsym = Stro.isFuncAsymmetric(fcnName);

% if the function name is asymmetrical, get function name without
%    'Asymmetrical' prefix
if isAsym
    [~, fcnName] = strtok(fcnName);
    fcnName = fcnName(2:end); % skip leading whitespace
end

% Get the index of function name into list of allowed functions
idx = find(contains(allowedFcns, fcnName), 1);

if isempty(idx)
    msgID = ['LIPRAS:' class(Stro) ':setFunction:InvalidArgument'];
    msg = ['The argument ''fcnNames'' must be contain the any of the functions: ', ...
        ' ''Gaussian'', ''Lorentzian'', ''Pearson VII'', or ''Pseudo Voigt'''];
    e = MException(msgID, msg);
    throw(e)
end

someFunc = allowedFcns_{idx};

if isAsym
    fcnObj = model.fit.Asymmetric(fcnID, '', someFunc);
else
    fcnObj = model.fit.(someFunc)(fcnID);
end

if ~isempty(Stro.PeakPositions) && Stro.PeakPositions(fcnID) ~= 0
    fcnObj.PeakPosition = Stro.PeakPositions(fcnID);
else
    fcnObj.PeakPosition = [];
end