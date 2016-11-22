function g = makeFunction(Stro,Fxn,data,position)
% Function for each profile
% Fxn - cell array of function names per peak
% data - data to fit
% position - numeric array of peak positions
if length(Fxn) == length(position)
		numpeaks = length(position);
else
		errordlg('Number of functions does not match number of peak positions.')
		return
end

coeff = Stro.getCoeff(Fxn, Stro.Constrains);
strFxn = '';

for i=1:numpeaks
		strFxn = [strFxn, makeFunctionStr(Fxn{i}, i)];
		if i~= numpeaks; strFxn = [strFxn,'+']; end
end

g = fittype(strFxn, 'coefficients', coeff, 'independent','x');





		function fstr = makeFunctionStr(fxn, peakNum)
			N = ['N' num2str(peakNum)];
			xv = ['x' num2str(peakNum)];
			f = ['f' num2str(peakNum)];
			m = ['m' num2str(peakNum)];
			w = ['w' num2str(peakNum)];
			NL = ['N',num2str(peakNum),'L'];
			mL = ['m',num2str(peakNum),'L'];
			NR = ['N',num2str(peakNum),'R'];
			mR = ['m',num2str(peakNum),'R'];
			
			if Stro.Constrains(1); N = 'N'; NL='N';NR='N';end
			if Stro.Constrains(2); f = 'f'; end
			if Stro.Constrains(4); m = 'm'; mL='m'; mR='m'; end
			if Stro.Constrains(3); w = 'w'; end
			
			switch fxn
				case 'Gaussian'
					fstr = [N,'*((2*sqrt(log(2)))/(sqrt(pi)*', f, ')*exp(-4*log(2)*((x-', xv, ')^2/', f, '^2)))'];
					if Stro.CuKa
						N=['((1/1.9)*',N,')'];
						xv=['PackageFitDiffractionData.Ka2fromKa1(',xv,')'];
						fstr = [fstr,'+',N,'*((2*sqrt(log(2)))/(sqrt(pi)*', f, ')*exp(-4*log(2)*((x-', xv, ')^2/', f, '^2)))'];
					end
				case 'Lorentzian'
					fstr = [N, '*1/pi* (0.5*', f, '/((x-', xv, ')^2+(0.5*', f, ')^2))'];
					if Stro.CuKa
						N=['((1/1.9)*',N,')'];
						xv=['PackageFitDiffractionData.Ka2fromKa1(',xv,')'];
						fstr = [fstr,'+',N, '*1/pi* (0.5*', f, '/((x-', xv, ')^2+(0.5*', f, ')^2))'];
					end
				case 'Pearson VII'
					fstr = [N, '*2*((2^(1/', m, ')-1)^0.5) /', f, '/(pi^0.5)*gamma(', m, ')/gamma(', m, ...
						'-0.5) * (1+4*(2^(1/', m, ')-1)*((x-', xv, ')^2)/', f, '^2)^(-', m, ')'];
					if Stro.CuKa
						N=['((1/1.9)*',N,')'];
						xv=['PackageFitDiffractionData.Ka2fromKa1(',xv,')'];
						fstr = [fstr,'+',N, '*2*((2^(1/', m, ')-1)^0.5) /', f, '/(pi^0.5)*gamma(', m, ')/gamma(', m, ...
							'-0.5) * (1+4*(2^(1/', m, ')-1)*((x-', xv, ')^2)/', f, '^2)^(-', m, ')'];
					end
				case 'Psuedo Voigt'
					fstr = [N,'*((',w,'*(2/pi)*(1/',f, ')*1/(1+(4*(x-',xv,')^2/', ...
						f,'^2))) + ((1-',w, ')*(2*sqrt(log(2))/(sqrt(pi)))*1/',f, ...
						'*exp(-log(2)*4*(x-',xv,')^2/',f,'^2)))'];
					if Stro.CuKa
						N=['((1/1.9)*',N,')'];
						xv=['PackageFitDiffractionData.Ka2fromKa1(',xv,')'];
						fstr = [fstr,'+',N,'*((',w,'*(2/pi)*(1/',f, ')*1/(1+(4*(x-',xv,')^2/', ...
							f,'^2))) + ((1-',w, ')*(2*sqrt(log(2))/(sqrt(pi)))*1/',f, ...
							'*exp(-log(2)*4*(x-',xv,')^2/',f,'^2)))'];
					end
				case 'Asymmetric Pearson VII'
					fstr = ['PackageFitDiffractionData.AsymmCutoff(',xv,',1,x)*',NL,'*PackageFitDiffractionData.C4(',mL,')/',f,'*(1+4*(2^(1/',mL,')-1)*(x-',...
						xv,')^2/',f,'^2)^(-',mL,')+PackageFitDiffractionData.AsymmCutoff(',xv,...
						',2,x)*',NR,'*PackageFitDiffractionData.C4(',mR,')/(',f,'*',NR,'/',NL,'*PackageFitDiffractionData.C4(',mR,')/PackageFitDiffractionData.C4(',mL,'))*(1+4*(2^(1/',mR,')-1)*(x-',...
						xv,')^2/(',f,'*',NR,'/',NL,'*PackageFitDiffractionData.C4(',mR,')/PackageFitDiffractionData.C4(',mL,'))^2)^(-',mR,')'];
					if Stro.CuKa
						NR=['((1/1.9)*',NR,')']; NL=['((1/1.9)*', NL,')'];
						xv=['PackageFitDiffractionData.Ka2fromKa1(',xv,')'];
						fstr = [fstr,'+','PackageFitDiffractionData.AsymmCutoff(',xv,',1,x)*',NL,'*PackageFitDiffractionData.C4(',mL,')/',f,'*(1+4*(2^(1/',mL,')-1)*(x-',...
							xv,')^2/',f,'^2)^(-',mL,')+PackageFitDiffractionData.AsymmCutoff(',xv,...
							',2,x)*',NR,'*PackageFitDiffractionData.C4(',mR,')/(',f,'*',NR,'/',NL,'*PackageFitDiffractionData.C4(',mR,')/PackageFitDiffractionData.C4(',mL,'))*(1+4*(2^(1/',mR,')-1)*(x-',...
							xv,')^2/(',f,'*',NR,'/',NL,'*PackageFitDiffractionData.C4(',mR,')/PackageFitDiffractionData.C4(',mL,'))^2)^(-',mR,')'];
					end
				otherwise
					error('Function was not found.')
			end
		end
end
