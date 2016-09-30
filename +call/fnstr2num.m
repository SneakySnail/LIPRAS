function num = fnstr2num(fcnNames)
num = [];

for i = 1:length(fcnNames)
	name = fcnNames{i};
	name(ismember(name, ' ')) = []; % Delete spaces from name
	
	if strcmpi(name, 'Gaussian')
		num = [num, 2];
	elseif strcmpi(name, 'Lorentzian')
		num = [num, 3];
	elseif strcmpi(name, 'Pearson VII')
		num = [num, 4];
	elseif strcmpi(name, 'Psuedo Voigt')
		num = [num, 5];
	elseif strcmpi(name, 'Asymmetric Pearson VII')
		num = [num, 6];
	else
		num = [num, 1];
	end
end