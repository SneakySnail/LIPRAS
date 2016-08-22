function names = num2fnstr(num)
names = '';

for i=1:length(num)
	if num(i) == 2
		names{i} = 'Gaussian';
	elseif num(i) == 3
		names{i} = 'Lorentzian';
	elseif num(i) == 4
		names{i} = 'PearsonVII';
	elseif num(i) == 5
		names{i} = 'PsuedoVoigt';
	elseif num(i) == 6
		names{i} = 'AsymmetricPVII';
	else
		names = '';
		return
	end
end
		