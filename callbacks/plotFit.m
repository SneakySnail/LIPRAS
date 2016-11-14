% TODO Move to FDGUIv2_1
function plotFit(handles,dataSet)
Stro = handles.xrd;
	if nargin == 1
		dataSet = 1;
		dataSet0 = dataSet;
		dataSetf = dataSet;
	elseif strcmp(dataSet,'all')
		dataSet0 = 1;
		dataSetf = size(Stro.fit_results,2);
		figure(5)
	else
		dataSet0 = dataSet;
		dataSetf = dataSet;
	end
	
	
	for j=dataSet0:dataSetf
		if strcmp(dataSet,'all')
			ax(j) = subplot(floor(sqrt(size(Stro.fit_results,2))),ceil(size(Stro.fit_results,2)/floor(sqrt(size(Stro.fit_results,2)))),j);
			hold on
		end
		cla
		x = Stro.fit_results{j}(1,:)';
		intensity = Stro.fit_results{j}(2,:)';
		back = Stro.fit_results{j}(3,:)';
		fittedPattern = back;
		
		for i=1:length(Stro.PSfxn(:,1))
			fittedPattern = fittedPattern + Stro.fit_results{j}(3+i,:)';
		end
		hold on
		
		for i=1:size(Stro.PSfxn, 1)
			peakfit = [];
			fxn = Stro.PSfxn(1,:);
			val = Stro.fit_parms{j,i}(1,:);
			coeff = Stro.Fcoeff{1}';
			k=1;
			
			if Stro.Constrains(1); N=val(k); NL=val(k); NR=val(k); k=k+1; end
			if Stro.Constrains(2); f=val(k); k=k+1; end
			if Stro.Constrains(3); w=val(k); k=k+1; end
			if Stro.Constrains(4); m=val(k); mL=m; mR=m; k=k+1; end
			
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
						if Stro.CuKa
							CuKaPeak(ii,:)=(1/1.9)*N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x-xvk).^2./f.^2)));
						end
					case 'Lorentzian'
						peakfit(ii,:) = N.*1./pi* (0.5.*f./((x-xv).^2+(0.5.*f).^2));
						if Stro.CuKa
							CuKaPeak(ii,:) = (1/1.9)*N.*1./pi* (0.5.*f./((x-xvk).^2+(0.5.*f).^2));
						end
					case 'Pearson VII'
						peakfit(ii,:) = N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xv).^2)/f.^2).^(-m);
						if Stro.CuKa
							CuKaPeak(ii,:)=(1/1.9)*N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x-xvk).^2)/f.^2).^(-m);
						end
					case 'Psuedo Voigt'
						peakfit(ii,:) = N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xv).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xv).^2./f.^2)));
						if Stro.CuKa
							CuKaPeak(ii,:)=(1/1.9)*N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x-xvk).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x-xvk).^2./f.^2)));
						end
					case 'Asymmetric Pearson VII'
						peakfit(ii,:) = PackageFitDiffractionData.AsymmCutoff(xv,1,x).*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xv).^2/f.^2).^(-mL) + ...
							PackageFitDiffractionData.AsymmCutoff(xv,2,x).*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xv).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
						if Stro.CuKa
							CuKaPeak(ii,:)=PackageFitDiffractionData.AsymmCutoff(xvk,1,x).*(1/1.9)*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x-xvk).^2/f.^2).^(-mL) + ...
								PackageFitDiffractionData.AsymmCutoff(xvk,2,x).*(1/1.9)*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x-xvk).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
						end
				end
			end
			cla
			data(1) = plot(x,intensity,'o', ...
				'LineWidth',1, ...
				'MarkerSize',4, ...
				'DisplayName','Raw Data', ...
				'MarkerFaceColor', [.08 .17 .55],'MarkerEdgeColor',[.08 .17 .55]); % Raw Data
			data(2) = plot(x,back, '--', ...
				'DisplayName', 'Background'); % Background
			data(3) = plot(x,fittedPattern,'k', ...
				'LineWidth',1.5, ...
				'DisplayName','Overall Fit','Color',[0 .5 0]); % Overall Fit
			
            co=[0.25 0.25 0.25;1 0 0; 0 0 1;0.4940 .1840 0.5560;.4660 0.6740 0.1880;0.6350 0.0780 0.1840; 0.75 0.75 0; 0.75 0 0.75]; % Color Order for plotting peaks underneath overall fit
            % From https://www.mathworks.com/help/matlab/graphics_transition/why-are-plot-lines-different-colors.html
            
			for jj=1:size(Stro.PSfxn,2)
				if Stro.CuKa
					data(3+2*jj-1) = plot(x',peakfit(jj,:)+back','LineWidth',1,'DisplayName',['Cu-K\alpha1 (',num2str(jj),')']);
					data(3+2*jj)=plot(x',CuKaPeak(jj,:)+back','LineWidth',1,'DisplayName',['Cu-K\alpha2 (',num2str(jj),')']);
				else
					data(3+jj) = plot(x',peakfit(jj,:)+back','LineWidth',1,'DisplayName',['Peak ',num2str(jj)],'Color',co(jj,1:3));
				end
			end
			
			Stro.DisplayName = {data.DisplayName};
			
			if strcmp(dataSet,'all')
				err = plot(x, intensity - fittedPattern - max(intensity) / 10, 'r','LineWidth',1.0);
			else
				evalin('base','axes(h.axes2)')
				cla
				err = plot(x, intensity - (fittedPattern), 'r','LineWidth',.50); % Error
				xlim([Stro.Min2T Stro.Max2T])
				% 						evalin('base', 'linkaxes([handles.axes1 handles.axes2],''x'')')
				
				evalin('base','axes(h.axes1)')
				% 						ylim([0 1.1*max(fittedPattern)])
				% 						ylim([0.9*min([data.YData]), 1.1*max([data.YData])]);
			end
			
		end
		if strcmp(dataSet,'all')
			xlim([min(x) max(x)])
			% 					ylim([0 1.1*max(fittedPattern)])
		end
		
	end
	
	if strcmp(dataSet,'all')
		linkaxes(ax,'xy');
	end
	
	ylim([0.9*min([data.YData]), 1.1*max([data.YData])]);
	
end