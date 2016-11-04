function [points,indX]=resetBackground(Stro, numpoints, polyorder)
	Stro.bkgd2th = [];
	Stro.PolyOrder = polyorder;
	[points,indX]=Stro.getBackground(numpoints);
end
