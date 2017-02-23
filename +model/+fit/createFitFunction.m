function fcnobj = createFitFunction(name, fcnID)
fcnobj = [];
if nargin < 2
    fcnID = 1;
end
switch name
    case 'Gaussian'
        fcnobj = model.fit.Gaussian(fcnID);
    case 'Lorentzian'
        fcnobj = model.fit.Lorentzian(fcnID);
    case 'Pearson VII'
        fcnobj = model.fit.PearsonVII(fcnID);
    case 'Pseudo-Voigt'
        fcnobj = model.fit.PseudoVoigt(fcnID);
    case 'Asymmetric Pearson VII'
        fcnobj = model.fit.Asymmetric(fcnID, [], 'PearsonVII');
end