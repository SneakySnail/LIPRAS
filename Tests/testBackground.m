%% Constructor
if ~exist('data', 'var') || ~exist('filename', 'var')
    [data, filename] = newDataSet();
end

import utils.*
datain = [data.two_theta; data.data_fit(1,:)];

d = model.DiffractionData(datain, filename);
d.Min2T = 3.6;
d.Max2T = 3.9;

bg = model.Background(d);
[p, idx] = bg.getInitialPoints();
assert(isempty(p) && isempty(idx));

%% Test setInitialPoints

bg.InitialPoints(3.62);
assert(isequal(bg.getInitialPoints, 3.62));

bg = bg.setInitialPoints(3.63);
assert(isequal(bg.getInitialPoints, [3.62 3.63]));

bg = bg.setInitialPoints(3.89);
assert(isequal(bg.getInitialPoints, [3.62 3.63 3.89]));

bg = bg.setInitialPoints(3.88, 'append');
assert(isequal(bg.getInitialPoints, [3.62 3.63 3.88 3.89]));

bg = bg.setInitialPoints(3.87, 'new');
assert(isequal(bg.getInitialPoints, 3.87));

bg = bg.setInitialPoints([3.88 3.89 3.61]);
assert(isequal(bg.getInitialPoints, [3.61 3.87 3.88 3.89]));


%% Test

