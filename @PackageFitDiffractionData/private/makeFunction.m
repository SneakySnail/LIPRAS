function [g,SP,LB,UB] = makeFunction(Stro,Fxn,data,position)
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

SP = []; UB = []; LB = [];
coeff = Stro.getCoeff(Fxn,Stro.Constrains);
strFxn = '';
x = data(1,:);
y = data(2,:);

for i=1:length(coeff)
		cname = coeff{i};
		if length(cname)>1
				num=str2double(cname(2));
				pos=position(num);
		else
				pos=position(1);
		end
		posX = Stro.Find2theta(x,pos);
		xl = Stro.Find2theta(x, pos-0.05);
		xr = Stro.Find2theta(x,pos+0.05);
		ni = trapz(x(xl:xr),y(xl:xr));
		fi = ni/y(posX);
		
		if cname(1) == 'N'
				SP = [SP, ni];
				UB = [UB, 5*ni];
				LB = [LB, 0];
				
				
		elseif cname(1) == 'x'
				SP = [SP, pos];
				UB = [UB, pos+.02];
				LB = [LB, pos-.02];
				
				
		elseif cname(1) == 'f'
				SP = [SP, fi];
				UB = [UB, fi*2];
				LB = [LB, 0];
		elseif cname(1) == 'w'
				SP = [SP, .5];
				UB = [UB, 1];
				LB = [LB, 0];
				
		elseif cname(1) == 'm'
				SP = [SP, 2];
				UB = [UB, 20];
				LB = [LB, .1];
		end
end

for i=1:numpeaks
		strFxn = [strFxn, Stro.makeFunctionStr(Fxn{i}, i)];
		if i~= numpeaks; strFxn = [strFxn,'+']; end
end

g = fittype(strFxn, 'coefficients', coeff, 'independent','x');
end
