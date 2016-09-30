
% Plot an example fit using the starting values from table
function handles = plotSampleFit(handles)

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
handles.xrd.plotData(get(handles.popup_filename,'Value'));
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
