% Script for testing PackageFitDiffractionData

% data is an existing variable in the workspace containing the diffraction data from
%   one or more files. It was obtained by running newDataSet and saving 'data'
%   into the base workspace.
import utils.contains
%% Constructor
if ~exist('data', 'var') || isempty(data)
    [data, filename, path] = utils.fileutils.newDataSet();
end
xrd = PackageFitDiffractionData(data, filename);
xrd.DataPath = path;

for i=1:length(xrd.NumFiles)-1
    assert(isequal(xrd.getTwoTheta(i), xrd.getTwoTheta(i+1)));
    assert(length(xrd.getData(i)) == length(xrd.getData(i+1)));    
end

%% getFileNames
filenames = xrd.getFileNames();
assert(isequal(filenames, filename));
xrd.Min2T = 3.6;
%% setFunctions
fcns = {'Asymmetric Pearson VII', 'Pseudo-Voigt', 'Pearson VII', 'Gaussian', 'Lorentzian'};

asymFuncsTrue = cellfun(@(f)contains(lower(f), 'asym'), fcns);

assert(isequal(asymFuncsTrue, [true false false false false]));

for i=1:length(fcns)
    xrd.setFunctions(fcns{i}, i);
end

%%  getFunctionNames 
assert(isequal(xrd.getFunctionNames, fcns));

%% get.NumFuncs
assert(xrd.NumFuncs == length(fcns));

%% setBackgroundPoints
xrd.setBackgroundPoints(3.61);
assert(isequal(xrd.getBackgroundPoints, 3.61));

xrd.setBackgroundPoints([3.62 3.63]);
assert(isequal(xrd.getBackgroundPoints, [3.62 3.63]));

xrd.setBackgroundPoints([3.89 3.88], 'append');
assert(isequal(xrd.getBackgroundPoints, [3.62 3.63 3.88 3.89]));

xrd.setBackgroundPoints([3.89 3.88 3.88], 'append');
assert(isequal(xrd.getBackgroundPoints, [3.62 3.63 3.88 3.89]));

xrd.setBackgroundPoints([3.85 3.83], 'append');
assert(isequal(xrd.getBackgroundPoints, [3.62 3.63 3.83 3.85 3.88 3.89]));

xrd.setBackgroundPoints(3.845, 'delete');
assert(isequal(xrd.getBackgroundPoints, [3.62 3.63 3.83 3.88 3.89]));

xrd.setBackgroundPoints([3.633 3.88], 'delete');
assert(isequal(xrd.getBackgroundPoints, [3.62 3.83 3.89]));

xrd.setBackgroundPoints([3.63], 'append');
assert(isequal(xrd.getBackgroundPoints, [3.62 3.63 3.83 3.89]));

%% setBackgroundOrder
xrd.setBackgroundOrder(2);
assert(isequal(xrd.getBackgroundOrder, 2));


%% constrain
xrd.constrain('f');
fNotConstrained = find(~cellfun(@(a)isequal(a, 'f'), xrd.getConstraints), 1); 
assert(isempty(fNotConstrained));

xrd.constrain('f');
fNotConstrained = find(~cellfun(@(a)isempty(a), xrd.getConstraints), 1); 
assert(isempty(fNotConstrained));

xrd.constrain('w');
assert(isequal(utils.contains(xrd.getConstraints, 'w'), [0 1 0 0 0]));

xrd.constrain('f');
assert(isequal(utils.contains(xrd.getConstraints, 'f'), [1 1 1 1 1]));

xrd.constrain('m', 1);
assert(isequal(utils.contains(xrd.getConstraints, 'm'), [1 0 0 0 0]));

%% setPeakPosition
peakposition = [3.70 3.72 3.78 3.79 3.80];
xrd.setPeakPosition(peakposition);


%% getPeakPosition
assert(isequal(xrd.getPeakPosition, peakposition));


%% fitDataSet
xrd.fitDataSet;

%% saveProfileParametersFile
xrd.saveProfileParametersFile;

%% Test xrdml file
filename = 'C:\Users\klari\OneDrive\GitHub\LIPRAS\SampleData\XRDDataKlarissa\Gio sample-12-22-2016.xrdml';
xrdml = PackageFitDiffractionData(xmldata, filename);
xrdml.DataPath = path;
xrdml.Min2T = 40;
xrdml.Max2T = 60;
assert(xrdml.CuKa);
xrdml.setBackgroundPoints([40.7568   46.3449   52.3898   57.8021]);
xrdml.setFunctions({'Pseudo-Voigt', 'Pearson VII', 'Asymmetric Pearson VII'});
xrdml.PeakPositions =  [43.8496, 49.5782, 54.9554];
xrdml.generateDefaultFitBounds;



