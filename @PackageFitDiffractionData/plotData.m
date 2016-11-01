% TODO Move to FDGUIv2_1
function plotData(Stro,dataSet,colorID)
	if nargin<3
		colorID='none';
	end
	if nargin == 1
		dataSet = 1;
	end
	
	x = Stro.two_theta;
	
	c=find(Stro.Min2T<=Stro.two_theta & Stro.Max2T>=Stro.two_theta);
	intensity = Stro.data_fit(dataSet,:);
	
	ymax=max(intensity(c));
	ymin=min(intensity(c));
	
	if strcmpi(colorID,'superimpose')
		hold on
		ind=find(strcmp(Stro.DisplayName,Stro.Filename(dataSet)));
		
		if isempty(ind)
			% If not already plotted
			if isempty(Stro.DisplayName)
				Stro.DisplayName(1)=Stro.Filename(dataSet);
			else
				Stro.DisplayName(end+1)=Stro.Filename(dataSet);
			end
			plot(x,intensity,'-o','LineWidth',1,'MarkerSize',6);
		else
			% Delete from DisplayName and from current axis
			Stro.DisplayName(ind)=[];
			lines=get(gca,'Children');
			lind=find(strcmp(get(lines,'DisplayName'),Stro.Filename(dataSet)));
			delete(lines(lind)); %#ok<FNDSB>
		end
		% Set color order index
		lines=get(gca,'Children');
		cArray=zeros(1,7);
		co=get(gca,'ColorOrder');
		lc=get(lines,'Color');
		if length(lines)==1
			ind=find(lc(1,1)==co(:,1));
			cArray(ind)=1;
		else
			for i=1:length(lines)
				ind=find(lc{i}(1)==co(:,1));
				cArray(ind)=1;
			end
		end
		cArray=find(~cArray,1);
		try
			set(gca,'ColorOrderIndex',cArray);
		catch  % If all colors are used
			cArray
		end
		
		% Get the maximum value of each line
		
		minX=PackageFitDiffractionData.Find2theta(lines(1).XData,Stro.Min2T);
		maxX=PackageFitDiffractionData.Find2theta(lines(1).XData,Stro.Max2T);
		y=[];
		
		for i=1:length(lines)
			y=[y,lines(i).YData(minX:maxX)];
		end
		ymin=min(y);
		ymax=max(y);
		
	else
		hold off
		if isempty(Stro.bkgd2th)
			plot(x,intensity,'-o','LineWidth',1,'MarkerSize',5, 'MarkerFaceColor', [1 1 1]);
		else
			plot(x,intensity,'-o','LineWidth',1,'MarkerSize',4, 'MarkerFaceColor', [0 0 0]);
		end
		Stro.DisplayName=Stro.Filename(dataSet);
	end
	
	ylim([0.9*ymin,1.1*ymax])
	xlim([Stro.Min2T, Stro.Max2T])
end