% Script to test Gaussian fit function object
function testFitFunctions

%% Section 1: Initialization
try
    g = model.fit.Gaussian(1, 'f');
    assert(isequal(g.Name, 'Gaussian'));
    assert(isequal(g.CoeffNames, {'N' 'x' 'f'}));
    assert(g.ID == 1);
    assert(isequal(g.ConstrainedCoeffs, {'f'}));
    
    
    g = model.fit.Gaussian;
    assert(isequal(g.Name, 'Gaussian'));
    assert(isequal(g.CoeffNames, {'N' 'x' 'f'}));
    assert(g.ID == 1);
    assert(isempty(g.ConstrainedCoeffs));
    
    
    l = model.fit.Lorentzian;
    assert(isequal(l.Name, 'Lorentzian'));
    assert(isequal(l.CoeffNames, {'N' 'x' 'f'}));
    assert(l.ID == 1);
    assert(isempty(l.ConstrainedCoeffs));
    
    p7 = model.fit.PearsonVII;
    assert(isequal(p7.Name, 'Pearson VII'));
    assert(isequal(p7.CoeffNames, {'N' 'x' 'f' 'm'}));
    assert(p7.ID == 1);
    assert(isempty(p7.ConstrainedCoeffs));
    
    pv = model.fit.PseudoVoigt;
    assert(isequal(pv.Name, 'Pseudo-Voigt'));
    assert(isequal(pv.CoeffNames, {'N' 'x' 'f' 'w'}));
    assert(pv.ID == 1);
    assert(isempty(pv.ConstrainedCoeffs));
    
    disp('1: pass')
    
catch ME
    ME.getReport
    keyboard
end

%% Section 2: Test this.ConstrainedCoeffs and constrain()
try
    % Gaussian
    g.constrain('N');
    assert(isequal(g.ConstrainedCoeffs, {'N'}));
    g.constrain('w');
    assert(isequal(g.ConstrainedCoeffs, {'N'}));
    g.constrain('f');
    assert(isequal(g.ConstrainedCoeffs, {'N' 'f'}));
    g.constrain('x');
    assert(isequal(g.ConstrainedCoeffs, {'N' 'x' 'f'}));
    g.constrain('N');
    assert(isequal(g.ConstrainedCoeffs, {'x' 'f'}));
    g.constrain('f');
    assert(isequal(g.ConstrainedCoeffs, {'x'}));
    g.constrain('m');
    assert(isequal(g.ConstrainedCoeffs, {'x'}));
    g.constrain('x');
    assert(isempty(g.ConstrainedCoeffs));
    
    
    
    % Lorentzian
    assert(isempty(l.ConstrainedCoeffs));
    l.constrain('N');
    assert(isequal(l.ConstrainedCoeffs, {'N'}));
    l.constrain('w');
    assert(isequal(l.ConstrainedCoeffs, {'N'}));
    l.constrain('f');
    assert(isequal(l.ConstrainedCoeffs, {'N' 'f'}));
    l.constrain('x');
    assert(isequal(l.ConstrainedCoeffs, {'N' 'x' 'f'}));
    l.constrain('N');
    assert(isequal(l.ConstrainedCoeffs, {'x' 'f'}));
    l.constrain('f');
    assert(isequal(l.ConstrainedCoeffs, {'x'}));
    l.constrain('m');
    assert(isequal(l.ConstrainedCoeffs, {'x'}));
    l.constrain('x');
    assert(isempty(l.ConstrainedCoeffs));
    
    % Pearson VII
    assert(isempty(p7.ConstrainedCoeffs));
    p7.constrain('N');
    assert(isequal(p7.ConstrainedCoeffs, {'N'}));
    p7.constrain('w');
    assert(isequal(p7.ConstrainedCoeffs, {'N'}));
    p7.constrain('f');
    assert(isequal(p7.ConstrainedCoeffs, {'N' 'f'}));
    p7.constrain('x');
    assert(isequal(p7.ConstrainedCoeffs, {'N' 'x' 'f'}));
    p7.constrain('N');
    assert(isequal(p7.ConstrainedCoeffs, {'x' 'f'}));
    p7.constrain('f');
    assert(isequal(p7.ConstrainedCoeffs, {'x'}));
    p7.constrain('m');
    assert(isequal(p7.ConstrainedCoeffs, {'x' 'm'}));
    p7.constrain('m');
    assert(isequal(p7.ConstrainedCoeffs, {'x'}));
    p7.constrain('x');
    assert(isempty(p7.ConstrainedCoeffs));
    
    % Pseudo-Voigt
    assert(isempty(pv.ConstrainedCoeffs));
    pv.constrain('N');
    assert(isequal(pv.ConstrainedCoeffs, {'N'}));
    pv.constrain('w');
    assert(isequal(pv.ConstrainedCoeffs, {'N' 'w'}));
    pv.constrain('f');
    assert(isequal(pv.ConstrainedCoeffs, {'N' 'f' 'w'}));
    pv.constrain('x');
    assert(isequal(pv.ConstrainedCoeffs, {'N' 'x' 'f' 'w'}));
    pv.constrain('m');
    assert(isequal(pv.ConstrainedCoeffs, {'N' 'x' 'f' 'w'}));
    pv.constrain('w');
    assert(isequal(pv.ConstrainedCoeffs, {'N' 'x' 'f'}));
    pv.constrain('x');
    assert(isequal(pv.ConstrainedCoeffs, {'N' 'f'}));
    pv.constrain('f');
    assert(isequal(pv.ConstrainedCoeffs, {'N'}));
    pv.constrain('f');
    assert(isequal(pv.ConstrainedCoeffs, {'N' 'f'}));
    pv.constrain('f');
    assert(isequal(pv.ConstrainedCoeffs, {'N'}));
    pv.constrain('N');
    assert(isempty(pv.ConstrainedCoeffs));
    
    
    
    
    disp('2: pass')
    
catch ME
    ME.getReport
    keyboard
    
end

%% Section 3: Testing getCoeffs
try
    % Gaussian
    assert(isequal(g.getCoeffs, {'N1' 'x1' 'f1'}));
    g.constrain('N');
    assert(isequal(g.getCoeffs, {'N' 'x1' 'f1'}));
    g.constrain('x');
    assert(isequal(g.getCoeffs, {'N' 'x' 'f1'}));
    g.constrain('x');
    assert(isequal(g.getCoeffs, {'N' 'x1' 'f1'}));
    g.constrain('f');
    assert(isequal(g.getCoeffs, {'N' 'f' 'x1'}));
    g.constrain('w');
    assert(isequal(g.getCoeffs, {'N' 'f' 'x1'}));
    g.constrain('N');
    assert(isequal(g.getCoeffs, {'f' 'N1' 'x1'}));
    g.constrain('m');
    assert(isequal(g.getCoeffs, {'f' 'N1' 'x1'}));
    g.constrain('f');
    assert(isequal(g.getCoeffs, {'N1' 'x1' 'f1'}));
    
    % Lorentzian
    assert(isequal(l.getCoeffs, {'N1' 'x1' 'f1'}));
    l.constrain('N');
    assert(isequal(l.getCoeffs, {'N' 'x1' 'f1'}));
    l.constrain('w');
    assert(isequal(l.getCoeffs, {'N' 'x1' 'f1'}));
    l.constrain('x');
    assert(isequal(l.getCoeffs, {'N' 'x' 'f1'}));
    l.constrain('x');
    assert(isequal(l.getCoeffs, {'N' 'x1' 'f1'}));
    l.constrain('f');
    assert(isequal(l.getCoeffs, {'N' 'f' 'x1'}));
    l.constrain('m');
    assert(isequal(l.getCoeffs, {'N' 'f' 'x1'}));
    l.constrain('N');
    assert(isequal(l.getCoeffs, {'f' 'N1' 'x1'}));
    l.constrain('f');
    assert(isequal(l.getCoeffs, {'N1' 'x1' 'f1'}));
    
    % Pearson VII
    assert(isequal(p7.getCoeffs, {'N1' 'x1' 'f1' 'm1'}));
    p7.constrain('N');
    assert(isequal(p7.getCoeffs, {'N' 'x1' 'f1' 'm1'}));
    p7.constrain('x');
    assert(isequal(p7.getCoeffs, {'N' 'x' 'f1' 'm1'}));
    p7.constrain('w');
    assert(isequal(p7.getCoeffs, {'N' 'x' 'f1' 'm1'}));
    p7.constrain('x');
    assert(isequal(p7.getCoeffs, {'N' 'x1' 'f1' 'm1'}));
    p7.constrain('f');
    assert(isequal(p7.getCoeffs, {'N' 'f' 'x1' 'm1'}));
    p7.constrain('x');
    assert(isequal(p7.getCoeffs, {'N' 'x' 'f' 'm1'}));
    p7.constrain('N');
    assert(isequal(p7.getCoeffs, {'x' 'f' 'N1' 'm1'}));
    p7.constrain('f');
    assert(isequal(p7.getCoeffs, {'x' 'N1' 'f1' 'm1'}));
    p7.constrain('x');
    assert(isequal(p7.getCoeffs, {'N1' 'x1' 'f1' 'm1'}));
    
    % Pseudo-Voigt
    assert(isequal(pv.getCoeffs, {'N1' 'x1' 'f1' 'w1'}));
    pv.constrain('N');
    assert(isequal(pv.getCoeffs, {'N' 'x1' 'f1' 'w1'}));
    pv.constrain('x');
    assert(isequal(pv.getCoeffs, {'N' 'x' 'f1' 'w1'}));
    pv.constrain('x');
    assert(isequal(pv.getCoeffs, {'N' 'x1' 'f1' 'w1'}));
    pv.constrain('m');
    assert(isequal(pv.getCoeffs, {'N' 'x1' 'f1' 'w1'}));
    pv.constrain('w');
    assert(isequal(pv.getCoeffs, {'N' 'w' 'x1' 'f1'}));
    pv.constrain('w');
    assert(isequal(pv.getCoeffs, {'N' 'x1' 'f1' 'w1'}));
    pv.constrain('N');
    assert(isequal(pv.getCoeffs, {'N1' 'x1' 'f1' 'w1'}));
    pv.constrain('f');
    assert(isequal(pv.getCoeffs, {'f' 'N1' 'x1' 'w1'}));
    pv.constrain('f');
    assert(isequal(pv.getCoeffs, {'N1' 'x1' 'f1' 'w1'}));
    
    
    
    
    disp('3: pass')
catch me
    me.getReport
    
    keyboard
end

%% Section 4: Asymmetric functions - constructor
try
    ag = model.fit.Asymmetric(1, '', 'Gaussian');
    assert(isequal(ag.Name, 'Asymmetric Gaussian'));
    assert(isequal(ag.Left.Name, 'Left Asymmetric Gaussian'));
    assert(isequal(ag.Right.Name, 'Right Asymmetric Gaussian'));
    expected = sort({'NL' 'NR' 'x' 'f'});
    assert(isequal(ag.CoeffNames, expected));
    assert(ag.ID == 1);
    assert(isempty(ag.ConstrainedCoeffs));
    
    al = model.fit.Asymmetric(1, '', 'Lorentzian');
    assert(isequal(al.Name, 'Asymmetric Lorentzian'));
    assert(isequal(al.Left.Name, 'Left Asymmetric Lorentzian'));
    assert(isequal(al.Right.Name, 'Right Asymmetric Lorentzian'));
    expected = sort({'NL' 'NR' 'x' 'f'});
    assert(isequal(al.CoeffNames, expected));
    assert(al.ID == 1);
    assert(isempty(al.ConstrainedCoeffs));
    
    ap7 = model.fit.Asymmetric(1, '', 'PearsonVII');
    assert(isequal(ap7.Name, 'Asymmetric Pearson VII'));
    assert(isequal(ap7.Left.Name, 'Left Asymmetric Pearson VII'));
    assert(isequal(ap7.Right.Name, 'Right Asymmetric Pearson VII'));
    expected = sort({'NL' 'NR' 'x' 'f' 'mL' 'mR'});
    assert(isequal(ap7.CoeffNames, expected));
    assert(ap7.ID == 1);
    assert(isempty(ap7.ConstrainedCoeffs));
    
    apv = model.fit.Asymmetric(1, '', 'PseudoVoigt');
    assert(isequal(apv.Name, 'Asymmetric Pseudo-Voigt'));
    assert(isequal(apv.Left.Name, 'Left Asymmetric Pseudo-Voigt'));
    assert(isequal(apv.Right.Name, 'Right Asymmetric Pseudo-Voigt'));
    expected = sort({'NL' 'NR' 'x' 'f' 'wL' 'wR'});
    assert(isequal(apv.CoeffNames, expected));
    assert(apv.ID == 1);
    assert(isempty(apv.ConstrainedCoeffs));
    
    disp('4: pass')
catch me
    me.getReport
    
    keyboard
end

%% Section 5: constraining Asymmetric functions
try
    % Gaussian
    ag.constrain('N');
    assert(isequal(ag.ConstrainedCoeffs, {'N'}));
    assert(isequal(ag.getCoeffs, sort({'N' 'f1' 'x1'})));
    
    ag.constrain('w');
    assert(isequal(ag.ConstrainedCoeffs, {'N'}));
    assert(isequal(ag.getCoeffs, sort({'N' 'f1' 'x1'})));
    
    ag.constrain('f');
    assert(isequal(ag.ConstrainedCoeffs, {'N' 'f'}));
    assert(isequal(ag.getCoeffs, sort({'N' 'f' 'x1'})));
    
    ag.constrain('x');
    assert(isequal(ag.ConstrainedCoeffs, {'N' 'x' 'f'}));
    assert(isequal(ag.getCoeffs, sort({'N' 'f' 'x'})));
    
    ag.constrain('N');
    assert(isequal(ag.ConstrainedCoeffs, {'x' 'f'}));
    assert(isequal(ag.getCoeffs, sort({'NL1' 'NR1' 'f' 'x'})));
    
    ag.constrain('f');
    assert(isequal(ag.ConstrainedCoeffs, {'x'}));
    assert(isequal(ag.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x'})));
    
    ag.constrain('m');
    assert(isequal(ag.ConstrainedCoeffs, {'x'}));
    assert(isequal(ag.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x'})));
    
    ag.constrain('x');
    assert(isempty(ag.ConstrainedCoeffs));
    assert(isequal(ag.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x1'})));
    
 
    
    
    
    % Lorentzian
    assert(isempty(al.ConstrainedCoeffs));
    assert(isequal(al.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x1'})));
    
    al.constrain('N');
    assert(isequal(al.ConstrainedCoeffs, {'N'}));
    assert(isequal(al.getCoeffs, sort({'N' 'f1' 'x1'})));
    
    al.constrain('w');
    assert(isequal(al.ConstrainedCoeffs, {'N'}));
    assert(isequal(al.getCoeffs, sort({'N' 'f1' 'x1'})));
    
    al.constrain('f');
    assert(isequal(al.ConstrainedCoeffs, {'N' 'f'}));
    assert(isequal(al.getCoeffs, sort({'N' 'f' 'x1'})));
    
    al.constrain('x');
    assert(isequal(al.ConstrainedCoeffs, {'N' 'x' 'f'}));
    assert(isequal(al.getCoeffs, sort({'N' 'f' 'x'})));
    
    al.constrain('N');
    assert(isequal(al.ConstrainedCoeffs, {'x' 'f'}));
    assert(isequal(al.getCoeffs, sort({'NL1' 'NR1' 'f' 'x'})));
    
    al.constrain('f');
    assert(isequal(al.ConstrainedCoeffs, {'x'}));
    assert(isequal(al.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x'})));
    
    al.constrain('m');
    assert(isequal(al.ConstrainedCoeffs, {'x'}));
    assert(isequal(al.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x'})));
    
    al.constrain('x');
    assert(isempty(al.ConstrainedCoeffs));
    assert(isequal(al.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x1'})));
    
    % Pearson VII
    assert(isempty(ap7.ConstrainedCoeffs));
    assert(isequal(ap7.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x1' 'mL1' 'mR1'})));
    
    ap7.constrain('N');
    assert(isequal(ap7.ConstrainedCoeffs, {'N'}));
    assert(isequal(ap7.getCoeffs, sort({'N' 'f1' 'x1' 'mL1' 'mR1'})));
    
    ap7.constrain('w');
    assert(isequal(ap7.ConstrainedCoeffs, {'N'}));
    assert(isequal(ap7.getCoeffs, sort({'N' 'f1' 'x1' 'mL1' 'mR1'})));
    
    ap7.constrain('f');
    assert(isequal(ap7.ConstrainedCoeffs, {'N' 'f'}));
    assert(isequal(ap7.getCoeffs, sort({'N' 'f' 'x1' 'mL1' 'mR1'})));
    
    ap7.constrain('x');
    assert(isequal(ap7.ConstrainedCoeffs, {'N' 'x' 'f'}));
    assert(isequal(ap7.getCoeffs, sort({'N' 'f' 'x' 'mL1' 'mR1'})));
    
    ap7.constrain('N');
    assert(isequal(ap7.ConstrainedCoeffs, {'x' 'f'}));
    assert(isequal(ap7.getCoeffs, sort({'NL1' 'NR1' 'f' 'x' 'mL1' 'mR1'})));
    
    ap7.constrain('f');
    assert(isequal(ap7.ConstrainedCoeffs, {'x'}));
    assert(isequal(ap7.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x' 'mL1' 'mR1'})));
    
    ap7.constrain('m');
    assert(isequal(ap7.ConstrainedCoeffs, {'x' 'm'}));
    assert(isequal(ap7.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x' 'm'})));
    
    ap7.constrain('m');
    assert(isequal(ap7.ConstrainedCoeffs, {'x'}));
    assert(isequal(ap7.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x' 'mL1' 'mR1'})));
    
    ap7.constrain('x');
    assert(isempty(ap7.ConstrainedCoeffs));
    assert(isequal(ap7.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x1' 'mL1' 'mR1'})));
    
    % Pseudo-Voigt
    assert(isempty(apv.ConstrainedCoeffs));
    assert(isequal(apv.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x1' 'wL1' 'wR1'})));
    
    apv.constrain('N');
    assert(isequal(apv.ConstrainedCoeffs, {'N'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f1' 'x1' 'wL1' 'wR1'})));
    
    apv.constrain('w');
    assert(isequal(apv.ConstrainedCoeffs, {'N' 'w'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f1' 'x1' 'w'})));
    
    apv.constrain('f');
    assert(isequal(apv.ConstrainedCoeffs, {'N' 'f' 'w'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f' 'x1' 'w'})));
    
    apv.constrain('x');
    assert(isequal(apv.ConstrainedCoeffs, {'N' 'x' 'f' 'w'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f' 'x' 'w'})));
    
    apv.constrain('m');
    assert(isequal(apv.ConstrainedCoeffs, {'N' 'x' 'f' 'w'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f' 'x' 'w'})));
    
    apv.constrain('w');
    assert(isequal(apv.ConstrainedCoeffs, {'N' 'x' 'f'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f' 'x' 'wL1' 'wR1'})));
    
    apv.constrain('x');
    assert(isequal(apv.ConstrainedCoeffs, {'N' 'f'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f' 'x1' 'wL1' 'wR1'})));
    
    apv.constrain('f');
    assert(isequal(apv.ConstrainedCoeffs, {'N'}));
    assert(isequal(apv.getCoeffs, sort({'N' 'f1' 'x1' 'wL1' 'wR1'})));
 
    
    apv.constrain('N');
    assert(isempty(apv.ConstrainedCoeffs));
    assert(isequal(apv.getCoeffs, sort({'NL1' 'NR1' 'f1' 'x1' 'wL1' 'wR1'})));
    
    disp('5: pass')
catch me
    me.getReport
    keyboard
end


%% getDefaultInitialValues
try
    
    
catch
    
    
end
