function names = num2fnstr(num)
names = '';

for i=1:length(num)
	if num(i) == 2
		names{i} = 'Gaussian';
	elseif num(i) == 3
		names{i} = 'Lorentzian';
	elseif num(i) == 4
		names{i} = 'Pearson VII';
	elseif num(i) == 5
		names{i} = 'Psuedo Voigt';
	elseif num(i) == 6
		names{i} = 'Asymmetric Pearson VII';
	else
		names = '';
		return
	end
end
		