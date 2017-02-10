function fcnobj = createFitFunction(name, fcnID)
fcnobj = [];
if nargin < 2
    fcnID = 1;
end
switch name
    case 'Gaussian'
        fcnobj = model.fitcomponents.Gaussian(fcnID);
    case 'Lorentzian'
        fcnobj = model.fitcomponents.Lorentzian(fcnID);
    case 'Pearson VII'
        fcnobj = model.fitcomponents.PearsonVII(fcnID);
    case 'Pseudo-Voigt'
        fcnobj = model.fitcomponents.PseudoVoigt(fcnID);
    case 'Asymmetric Pearson VII'
        fcnobj = model.fitcomponents.Asymmetric(fcnID, [], 'PearsonVII');
end