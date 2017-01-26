%% 1. construct
profiles = model.ProfileListManager.getInstance;

%%

if ~profiles.hasData
    filenames = {which('350.chi') which('351.chi')};
    data = utils.fileutils.newDataSet(filenames);
    xrd = PackageFitDiffractionData(data.two_theta, data.data_fit, filenames);
    profiles.newXRD(xrd);
end

%% 

assert(profiles.hasData);
assert(profiles.getCurrentProfileNumber == 1);
assert(profiles.getNumProfiles == 1);
assert(profiles.getNumFiles == length(profiles.getFileNames));
assert(isequal(profiles.xrd, profiles.getCurrentProfile));

%% PROFILE 1
xrd = profiles.xrd;
profiles.xrd.Min2T = 3.6;
profiles.xrd.Max2T = 3.9;
fcns = {'Asymmetric Pearson VII', 'Pseudo-Voigt'};
for i=1:length(fcns)
    profiles.xrd.setFunctions(fcns{i}, i);
end
assert(isequal(profiles.xrd.getFunctionNames, fcns));
assert(profiles.xrd.NumFuncs == length(fcns));

%% Background
bkgdpoints = [3.61 3.62 3.84 3.85];
profiles.xrd.setBackgroundPoints(bkgdpoints);
assert(isequal(xrd.getBackgroundPoints, bkgdpoints));

bkgdorder = 4;
profiles.xrd.setBackgroundOrder(bkgdorder);
assert(isequal(xrd.getBackgroundOrder, bkgdorder));

bkgdpoints = sort([bkgdpoints 3.89 3.88]);
profiles.xrd.setBackgroundPoints([3.89 3.88], 'append');
assert(isequal(xrd.getBackgroundPoints, bkgdpoints));

%% Constraints
import utils.*
xrd.constrain('f');
fConstrained = find(contains(xrd.getConstraints, 'f'), 1); 
assert(~isempty(fConstrained));

xrd.constrain('f');
fConstrained = find(contains(xrd.getConstraints, 'f'), 1); 
assert(~isempty(fConstrained));

xrd.constrain('w');
wConstrained = find(contains(xrd.getConstraints, 'w'), 1);
assert(~isempty(wConstrained));

xrd.unconstrain('N');
NConstrained = find(contains(xrd.getConstraints, 'N'), 1); 
assert(isempty(NConstrained));

xrd.constrain('N');
NConstrained = find(contains(xrd.getConstraints, 'N'), 1); 
assert(~isempty(NConstrained));

%% Peak position
peakposition = [3.72 3.77];
xrd.PeakPositions = peakposition;
assert(isequal(xrd.PeakPositions, peakposition));

%% Fit Initial
xrd.FitInitial.start = xrd.getDefaultStartingBounds;
xrd.FitInitial.lower = xrd.getDefaultLowerBounds;
xrd.FitInitial.upper = xrd.getDefaultUpperBounds;

assert(isequal(xrd.FitInitial.start, xrd.getDefaultStartingBounds));
assert(isequal(xrd.FitInitial.lower, xrd.getDefaultLowerBounds));
assert(isequal(xrd.FitInitial.upper, xrd.getDefaultUpperBounds));

%% Fit Dataset
xrd.fitDataSet;

%% Fit output
profiles.saveProfileParametersFile();


