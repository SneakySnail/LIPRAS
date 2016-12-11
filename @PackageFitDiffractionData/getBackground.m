function [points,indX]=getBackground(Stro, numpoints)
if isempty(Stro.bkgd2th)
		Stro.Status='Choosing number of background points...';
        
		
		if nargin < 2
				prompt = {'Number of background points:'};
				dlg_title = 'Select number of background points';
				num_lines = 1;
				def = {'10'};
				numpoints = newid(prompt,dlg_title,num_lines,def,'on');
				numpoints = str2double(numpoints{1});
		end
		
		hold on
		points = []; indX = [];
		for i=1:numpoints
				Stro.Status=['Choosing ',num2str(numpoints),' background points... Point ',num2str(i),'.'];
    [x,~, key]=ginput(1);
                 if key==27
                        return
                    elseif key ~= 1
                   k=654564465645645; % I'll be impressed if someone hits this key, dont think it exists
                        while k~=1
                    k = waitforbuttonpress; % press any key to continue
                        end
                [x,~, key]=ginput(1);             
                else
                points(i,1)=x;            
                end
                if key==27
                    return
                end               
				points(i,1)=x;
                pos = PackageFitDiffractionData.Find2theta(Stro.two_theta,x);
				plot(x, Stro.data_fit(1,pos), 'r*') % 'ko'
		end
		Stro.Status=[num2str(numpoints),' background points were selected.'];
		
		cla
% 		Stro.plotData(1)
else
		points(:,1) = Stro.bkgd2th;
end

for i=1:length(points(:,1))
		if Stro.two_theta(PackageFitDiffractionData.Find2theta(Stro.two_theta,points(i,1))) > Stro.Max2T
				indX(i) = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Max2T)-4;
				points(i,1) = Stro.two_theta(indX);
		elseif Stro.two_theta(PackageFitDiffractionData.Find2theta(Stro.two_theta,points(i,1))) < Stro.Min2T
				indX(i) = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Min2T)+4;
				points(i,1) = Stro.two_theta(indX(i));
		else
				indX(i) = PackageFitDiffractionData.Find2theta(Stro.two_theta,points(i,1));
				points(i,1) = Stro.two_theta(indX(i));
		end
end

Stro.bkgd2th = points(:,1)';
Stro.bkgd2th = sort( Stro.bkgd2th );
points=Stro.bkgd2th;

end
