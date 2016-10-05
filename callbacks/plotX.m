function plotX(filenum, handles)
	cla(handles.axes1)
	cla(handles.axes2)
	
	condition = struct('SUPER', 1, 'RAW', 2, 'FIT', 3);
	
	% If superimpose is checked
	if handles.checkbox_superimpose.Value
		state = condition.SUPER;
	elseif isempty(handles.xrd.Fmodel)
		state = condition.RAW;
	else
		state = condition.FIT;
	end
	
	switch state
		case condition.SUPER
			hold on
			% 			find(handles.
			
			plot_superimposed(filenum, handles.xrd);
			
		case condition.RAW
			set(handles.axes2,'Visible','off');
			set(handles.axes2.Children,'Visible','off');
			
			plot_raw(handles.xrd, filenum, handles);
			
			plot_sample(guidata(handles.figure1));
			
			
		case condition.FIT
			set(handles.axes2,'Visible','on');
			set(handles.axes2.Children,'Visible','on');
			
			plot_fit(get(handles.popup_filename,'Value'),guidata(handles.figure1));
			
			SP = handles.xrd.fit_initial{1,filenum};
			vals = handles.xrd.fit_parms{filenum}; % Update results column
			for i=1:length(vals)
				handles.table_coeffvals.Data{i,1} = SP(i);
			end
			
		otherwise
			
			
			
	end
	
	% 	if strcmpi(handles.uitoggletool5.State,'on')
	% 		legend(handles.xrd.DisplayName,'box','off')
	% 	end
	
	
	
	
	% Set x and y plot limits
	ind=find(handles.xrd.Min2T<= handles.xrd.two_theta & ...
		handles.xrd.Max2T>=handles.xrd.two_theta); % find the index within range
	y_raw = handles.xrd.data_fit(filenum, :);
	ymax=max(y_raw(ind));
	ymin=min(y_raw(ind));
	
	axes(handles.axes1)
	xlim([handles.xrd.Min2T, handles.xrd.Max2T])
	ylim([0.8*ymin,1.2*ymax])
	
	guidata(handles.figure1, handles)
	
	
	
	function plot_superimposed(filenum, xrd)
		ind=find(strcmp(xrd.DisplayName, xrd.Filename(filenum)));
		
		if isempty(ind) % If filenum is not plotted
			if isempty(xrd.DisplayName) % if no raw dataset yet already on plot
				xrd.DisplayName(1)=xrd.Filename(filenum);
			else
				xrd.DisplayName(end+1)=xrd.Filename(filenum);
			end
			plot(x,intensity,'-o','LineWidth',1,'MarkerSize',6);
			
		else
			% Delete from DisplayName and from current axis
			xrd.DisplayName(ind)=[];
			lines=get(gca,'Children');
			lind=find(strcmp(get(lines,'DisplayName'),xrd.Filename(filenum)));
			delete(lines(lind)); %#ok<FNDSB>
		end
		
		% Set color order index
		lines=get(gca,'Children');
		cArray=zeros(1,7);
		co=get(gca,'ColorOrder');
		lc=get(lines,'Color');
		
		if length(lines)==1
			ind=find(lc(1,1)==co(:,1),1);
			cArray(ind)=1;
		else
			for i=1:length(lines)
				ind=find(lc{i}(1)==co(:,1), 1);
				cArray(ind)=1;
			end
		end
		cArray=find(~cArray,1);
		try
			set(gca,'ColorOrderIndex',cArray);
		catch  % If all colors are used
			disp(cArray)
		end
		
		% Get the maximum value of each line
		% 	minX=PackageFitDiffractionData.Find2theta(lines(1).XData,xrd.Min2T);
		% 	maxX=PackageFitDiffractionData.Find2theta(lines(1).XData,xrd.Max2T);
		% 	y=[];
		%
		% 	for i=1:length(lines)
		% 		y=[y,lines(i).YData(minX:maxX)];
		% 	end
		% 	ymin=min(y);
		% 	ymax=max(y);
		
	end
	
	
	function plot_raw(xrd, filenum, handles)
		hold off
		y_raw = handles.xrd.data_fit(filenum, :);
		
		if isempty(xrd.bkgd2th)
			plot(xrd.two_theta,y_raw,'-o','LineWidth',1,'MarkerSize',6);
		else
			plot(xrd.two_theta,y_raw,'-ko','LineWidth',1,'MarkerSize',6);
		end
		
		xrd.DisplayName=xrd.Filename(filenum);
		
	end
	
	
	function plot_sample(handles)
		hold on
		
		% Make sure all the cells with starting values are not empty
		try
			val=[handles.table_coeffvals.Data{:,1}];
			coeff=handles.table_coeffvals.RowName;
			assert(~isempty(val));
			assert(~isempty(coeff));
			temp = cellfun(@isempty, handles.table_coeffvals.Data(:, 1:3));
			assert(isempty(find(temp, 1)));
			assert(length(val)==length(coeff));
		catch
			return
		end
		
		filenum=get(handles.popup_filename,'Value');
		fitrange=str2double(get(handles.edit_fitrange,'string'));
		data=handles.xrd.getRawData(filenum,fitrange);
		x=data(1,:);
		y=data(2,:);
		
		% Get background fit
		R=1;
		for i=1:length(handles.xrd.bkgd2th);
			bkgd2thX(i)=PackageFitDiffractionData.Find2theta(data(1,:),handles.xrd.bkgd2th(i));
		end
		
		for i=1:length(handles.xrd.bkgd2th)
			bkgdInt(i)=mean(data(2,(bkgd2thX(i)-R:bkgd2thX(i)+R)));
		end
		
		cla
		plot_raw(handles.xrd, get(handles.popup_filename,'Value'), handles);
		[P,S,U]=polyfit(handles.xrd.bkgd2th,bkgdInt,handles.xrd.PolyOrder);
		hold on
		datafit=plot(data(1,:),polyval(P,data(1,:),S,U),':',...
			'LineWidth',2,'Color',[0.5 0.5 0.5],'DisplayName','Background');
		
		% Subtract background fit from raw data
		dataNB = data;
		background=polyval(P,data(1,:),S,U);
		dataNB(2,:) = data(2,:) - background;
		
		% Use initial coefficient values to plot fit
		p = call.getSavedParam(handles);
		peakPos=p.peakPositions;
		peakNames=p.fcnNames;
		constraints=p.constraints;
		k=1;
		peakfit=[];
		
		cX=find(constraints);
		for i=1:length(cX)
			% Make sure coefficient name is not numbered
			assert(length(coeff{i})==1);
			if cX(i)==1
				N=val(i); NL=N; NR=N;
			elseif cX(i)==2
				f=val(i);
			elseif cX(i)==3
				w=val(i);
			elseif cX(i)==4
				m=val(i); mL=m; mR=m;
			end
		end
		
		start=length(cX)+1;
		for i=1:length(peakNames)
			peakX{i}=[]; % coeffX{1}=index into coefficient for peak 1
			
			for j=start:length(coeff)
				% Make sure coefficient name is numbered
				assert(length(coeff{j})>1);
				if coeff{j}(2)==num2str(i)
					if isempty(peakX{i})
						peakX{i}(1)=j;
					else
						peakX{i}(end+1)=j;
					end
				end
			end
		end
		
		for i=1:length(peakNames)
			fxn=peakNames{i};
			
			for j=1:length(peakX{i})
				k=peakX{i}(j);
				
				switch coeff{k}(1)
					case 'N'
						if strcmpi(fxn,'Asymmetric Pearson VII')
							assert(length(coeff{k})>2);
							if coeff{k}(3)=='L'
								NL=val(k);
							elseif coeff{k}(3)=='R'
								NR=val(k);
							end
						else
							N=val(k);
						end
						
					case 'x'
						xv=val(k);
						
					case 'f'
						f=val(k);
						
					case 'w'
						w=val(k);
						
					case 'm'
						if strcmpi(fxn,'Asymmetric Pearson VII')
							assert(length(coeff{k})>2);
							if coeff{k}(3)=='L'
								mL=val(k);
							elseif coeff{k}(3)=='R'
								mR=val(k);
							end
						else
							m=val(k);
						end
						
				end
			end
			
			switch fxn
				case 'Gaussian'
					peakfit(i,:) = N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-xv).^2./f.^2)));
					if handles.xrd.CuKa
						CuKaPeak(i,:)=(1/1.9)*N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-xvk).^2./f.^2)));
					end
				case 'Lorentzian'
					peakfit(i,:) = N.*1./pi* (0.5.*f./((x-xv).^2+(0.5.*f).^2));
					if handles.xrd.CuKa
						CuKaPeak(i,:) = (1/1.9)*N.*1./pi* (0.5.*f./((x-xvk).^2+(0.5.*f).^2));
					end
				case 'Pearson VII'
					peakfit(i,:) = N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xv).^2)/f.^2).^(-m);
					if handles.xrd.CuKa
						CuKaPeak(i,:)=(1/1.9)*N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xvk).^2)/f.^2).^(-m);
					end
				case 'Psuedo Voigt'
					peakfit(i,:) = N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xv).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xv).^2./f.^2)));
					if handles.xrd.CuKa
						CuKaPeak(i,:)=(1/1.9)*N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xvk).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xvk).^2./f.^2)));
					end
				case 'Asymmetric Pearson VII'
					peakfit(i,:) = PackageFitDiffractionData.AsymmCutoff(xv,1,x)'.*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xv).^2/f.^2).^(-mL) + ...
						PackageFitDiffractionData.AsymmCutoff(xv,2,x)'.*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xv).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
					if handles.xrd.CuKa
						CuKaPeak(i,:)=PackageFitDiffractionData.AsymmCutoff(xvk,1,x)'.*(1/1.9)*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xvk).^2/f.^2).^(-mL) + ...
							PackageFitDiffractionData.AsymmCutoff(xvk,2,x)'.*(1/1.9)*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xvk).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
					end
			end
			
			datafit(end+1)=plot(x,peakfit(i,:)+background,':','LineWidth',2,...
				'DisplayName',['Peak ', num2str(i),' (',fxn,')']);
			if handles.xrd.CuKa
				datafit(end+1)=plot(x,CuKaPeak(i,:)+background,':','LineWidth',2,...
					'DisplayName',['Cu-K\alpha2 (Peak ', num2str(i)]);
			end
		end
		
		dispname={datafit.DisplayName};
		handles.xrd.DisplayName=[handles.xrd.DisplayName,dispname];
		
		if strcmpi(handles.uitoggletool5.State,'on')
			legend(handles.xrd.DisplayName,'box','off')
		end
		
	end
	
	
	function plot_fit(dataSet, handles)
		xrd = handles.xrd;
		if strcmp(dataSet,'all')
			dataSet0 = 1;
			dataSetf = size(xrd.fit_results,2);
			figure(5)
		else
			dataSet0 = dataSet;
			dataSetf = dataSet;
		end
		
		for j=dataSet0:dataSetf
			if strcmp(dataSet,'all')
				ax(j) = subplot(floor(sqrt(size(xrd.fit_results,2))),ceil(size(xrd.fit_results,2)/floor(sqrt(size(xrd.fit_results,2)))),j);
				hold on
			end
			cla
			x = xrd.fit_results{j}(1,:)';
			intensity = xrd.fit_results{j}(2,:)';
			back = xrd.fit_results{j}(3,:)';
			fittedPattern = back;
			
			for i=1:length(xrd.PSfxn(:,1))
				fittedPattern = fittedPattern + xrd.fit_results{j}(3+i,:)';
			end
			hold on
			
			if strcmp(dataSet,'all')
				err = plot(x, intensity - fittedPattern - max(intensity) / 10, 'r','LineWidth',1.2);
				
			else
				% Plotting error
				axes(handles.axes2)
				err = plot(x, intensity - (fittedPattern), 'r','LineWidth',1.2); % Error
				xlim([xrd.Min2T xrd.Max2T])
				axes(handles.axes1)
			end
			
			for i=1:size(xrd.PSfxn, 1)
				peakfit = [];
				fxn = xrd.PSfxn(1,:);
				val = xrd.fit_parms{j,i}(1,:);
				coeff = xrd.Fcoeff{1}';
				k=1;
				
				if xrd.Constrains(1); N=val(k); NL=val(k); NR=val(k); k=k+1; end
				if xrd.Constrains(2); f=val(k); k=k+1; end
				if xrd.Constrains(3); w=val(k); k=k+1; end
				if xrd.Constrains(4); m=val(k); mL=m; mR=m; k=k+1; end
				
				for ii=1:length(fxn)
					if coeff{k}(1) == 'N';
						if strcmp(fxn{ii},'Asymmetric Pearson VII')
							NL=val(k);
							k=k+1;
							NR=val(k);
							if k<length(coeff); k=k+1; end
						else
							N=val(k);
							if k<length(coeff); k=k+1; end
						end
						
					end
					if coeff{k}(1) == 'x'
						xv=val(k);
						if k<length(coeff); k=k+1; end
					end
					if coeff{k}(1) == 'f'; f=val(k);
						if k<length(coeff); k=k+1; end
					end
					if coeff{k}(1) == 'w'; w=val(k);
						if k<length(coeff); k=k+1; end
					end
					if coeff{k}(1) == 'm';
						if strcmp(fxn{ii},'Asymmetric Pearson VII')
							mL=val(k);
							k=k+1;
							mR=val(k);
							if k<length(coeff); k=k+1; end
						else
							m=val(k);
							if k<length(coeff); k=k+1; end
						end
					end
					
					xvk=PackageFitDiffractionData.Ka2fromKa1(xv);
					switch fxn{ii}
						case 'Gaussian'
							peakfit(ii,:) = N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-xv).^2./f.^2)));
							if xrd.CuKa
								CuKaPeak(ii,:)=(1/1.9)*N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-xvk).^2./f.^2)));
							end
						case 'Lorentzian'
							peakfit(ii,:) = N.*1./pi* (0.5.*f./((x-xv).^2+(0.5.*f).^2));
							if xrd.CuKa
								CuKaPeak(ii,:) = (1/1.9)*N.*1./pi* (0.5.*f./((x-xvk).^2+(0.5.*f).^2));
							end
						case 'Pearson VII'
							peakfit(ii,:) = N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xv).^2)/f.^2).^(-m);
							if xrd.CuKa
								CuKaPeak(ii,:)=(1/1.9)*N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xvk).^2)/f.^2).^(-m);
							end
						case 'Psuedo Voigt'
							peakfit(ii,:) = N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xv).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xv).^2./f.^2)));
							if xrd.CuKa
								CuKaPeak(ii,:)=(1/1.9)*N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xvk).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xvk).^2./f.^2)));
							end
						case 'Asymmetric Pearson VII'
							peakfit(ii,:) = PackageFitDiffractionData.AsymmCutoff(xv,1,x).*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xv).^2/f.^2).^(-mL) + ...
								PackageFitDiffractionData.AsymmCutoff(xv,2,x).*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xv).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
							if xrd.CuKa
								CuKaPeak(ii,:)=PackageFitDiffractionData.AsymmCutoff(xvk,1,x).*(1/1.9)*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xvk).^2/f.^2).^(-mL) + ...
									PackageFitDiffractionData.AsymmCutoff(xvk,2,x).*(1/1.9)*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xvk).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
							end
					end
				end
				data(1) = plot(x,intensity,'kx','LineWidth',1,'MarkerSize',15,'DisplayName','Raw Data'); % Raw Data
				data(2)= plot(x,back,'DisplayName','Background'); % Background
				data(3) = plot(x,fittedPattern,'k','LineWidth',1.6,'DisplayName','Overall Fit'); % Overall Fit
				
				for jj=1:size(xrd.PSfxn,2)
					if xrd.CuKa
						data(3+2*jj-1) = plot(x',peakfit(jj,:)+back','LineWidth',1,'DisplayName',['Cu-K\alpha1 (',num2str(jj),')']);
						data(3+2*jj)=plot(x',CuKaPeak(jj,:)+back','LineWidth',1,'DisplayName',['Cu-K\alpha2 (',num2str(jj),')']);
					else
						data(3+jj) = plot(x',peakfit(jj,:)+back','LineWidth',1,'DisplayName',['Peak ',num2str(jj)]);
					end
				end
				
				xlim([xrd.Min2T xrd.Max2T])
				ylim([0.9*min([data.YData]), 1.1*max([data.YData])]);
				xrd.DisplayName = {data.DisplayName};
				
			end
			if strcmp(dataSet,'all')
				xlim([min(x) max(x)])
				ylim([0 1.1*max(fittedPattern)])
			end
		end
		
		if strcmp(dataSet,'all')
			linkaxes(ax,'xy');
		else
			linkprop([handles.axes1 handles.axes2], 'XLim');
		end
		
		guidata(handles.figure1, handles)
		
	end
	
end
