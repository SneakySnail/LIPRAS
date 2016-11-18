function [SP, LB, UB] = getDefaultStartingBounds(Stro, fcn, position)

SP = []; UB = []; LB = [];
data = Stro.getRawData(1, Stro.fitrange);
x = data(1,:);
y = data(2,:);

if nargin < 3
	position = Stro.PeakPositions;
	fcn = Stro.PSfxn;
elseif length(fcn) < length(position)
	position = position(1:length(fcn));
end

coeff = Stro.getCoeff(fcn, Stro.Constrains);

for i=1:length(coeff)
		cname = coeff{i};
		if length(cname) > 1 % If not a constrained coeff
				num=str2double(cname(2));
				pos=position(num);
		else % If it is a constrained coeff
				pos=position(1);
		end
		
		posX = Stro.Find2theta(x, pos);
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
