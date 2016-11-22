function [P, S, U] = fitBkgd(data, bkgd2th, polyorder)
% BACKGROUND FITTING
R = 1; %in points each direction for the background averaging, must be integer
for i=1:length(bkgd2th)
		bkgd2thX(i)=PackageFitDiffractionData.Find2theta(data(1,:),bkgd2th(i));
end;

for i=1:length(bkgd2th)
	if bkgd2thX(i) <= 1
		bkgd2thX(i) = 2;
	elseif bkgd2thX(i) >= length(data)
		bkgd2thX(i) = length(data) - 1;
	end
	bkgdInt(i)=mean(data(2,(bkgd2thX(i)-R:bkgd2thX(i)+R))); 
end
% Added by Klarissa to  get rid of centering and scaling warning
[P, S, U] = polyfit(bkgd2th,bkgdInt, polyorder);

end