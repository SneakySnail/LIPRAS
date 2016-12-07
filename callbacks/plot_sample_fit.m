% Plot an example fit using the starting values from table
function handles = plot_sample_fit(handles)
dbstack
keyboard

cp = handles.guidata.currentProfile;

% Make sure all the cells with starting values are not empty
try
    SP = handles.guidata.fit_initial{cp}{1};
    coeff=handles.table_fitinitial.RowName;
    assert(~isempty(coeff));
    assert(isempty(find(~strcmpi(coeff, handles.guidata.coeff{cp}'), 1)));
    assert(~isempty(SP));
    
    temp = cellfun(@isempty, handles.table_fitinitial.Data(:, 1:3));
    assert(isempty(find(temp, 1)));
    assert(length(SP)==length(coeff));
    assert(~isempty(handles.xrd.bkgd2th));
catch
    
end

filenum=get(handles.popup_filename,'Value');
fitrange=str2double(get(handles.edit_fitrange,'string'));
data = handles.xrd.getRangedData(filenum,fitrange);
bkgd2th = handles.xrd.getBkgdPoints();

% Get background fit
[P,S,U]=PackageFitDiffractionData.fitBkgd(data, bkgd2th, handles.xrd.PolyOrder);

% Subtract background fit from raw data
background=polyval(P,data(1,:),S,U);

% Use initial coefficient values to plot fit
peakPos=handles.guidata.PeakPositions{cp};
peakNames=handles.guidata.PSfxn{cp};
constraints=handles.guidata.constraints{cp};

hold on
datafit=plot(data(1,:),background,':',...
    'LineWidth',1,...
    'Color',[0.2 0.2 0.2],...
    'DisplayName','Background');

x2th=data(1,:);

[peakArray, CuKaPeak] = calculatePeakResults(handles, x2th, SP);

for i=1:handles.guidata.numPeaks
    datafit(end+1)=plot(x2th,peakArray(i,:)+background,'--','LineWidth',1,...
        'DisplayName',['Peak ', num2str(i),' (',peakNames{i},')']);
    if handles.xrd.CuKa
        datafit(end+1)=plot(x2th,CuKaPeak(i,:)+background,':','LineWidth',2,...
            'DisplayName',['Cu-K\alpha2 (Peak ', num2str(i), ')']);
    end
end

dispname={datafit.DisplayName};
handles.xrd.DisplayName=[handles.xrd.DisplayName, dispname];

LIPRAS('uitoggletool5_OnCallback', handles.uitoggletool5, [], handles);


function [peakArray, CuKaPeak] = calculatePeakResults(handles, x2th, coeffvals)
coeffIndex=1;
cp = handles.guidata.currentProfile;
fcns = handles.guidata.PSfxn{cp};
coeff = handles.guidata.coeff{cp};
constraints = handles.guidata.constraints{cp};


peakArray = [];
CuKaPeak = [];

if find(constraints(:,1),1)
    N0=coeffvals(coeffIndex);
    coeffIndex=coeffIndex+1;
end
if find(constraints(:,2),1)
    xv0=coeffvals(coeffIndex);
    coeffIndex=coeffIndex+1;
end
if find(constraints(:,3),1)
    f0=coeffvals(coeffIndex);
    coeffIndex=coeffIndex+1;
end
if find(constraints(:,4),1)
    w0=coeffvals(coeffIndex);
    coeffIndex=coeffIndex+1;
end
if find(constraints(:,5),1)
    m0=coeffvals(coeffIndex);
    coeffIndex=coeffIndex+1;
end

for i=1:handles.guidata.numPeaks
    con = constraints(i,:);
    
    while coeffIndex <= length(coeff) && ...
            str2num(coeff{coeffIndex}(2)) == i
        switch coeff{coeffIndex}(1)
            case 'N'
                if strcmpi(fcns{i}, 'Asymmetric Pearson VII')
                    assert(length(coeff{coeffIndex})>2);
                    if coeff{coeffIndex}(3)=='L'
                        NL=coeffvals(coeffIndex);
                    elseif coeff{coeffIndex}(3)=='R'
                        NR=coeffvals(coeffIndex);
                    end
                else
                    N=coeffvals(coeffIndex);
                end
                
            case 'x'
                xv=coeffvals(coeffIndex);
                
            case 'f'
                f=coeffvals(coeffIndex);
                
            case 'w'
                w=coeffvals(coeffIndex);
                
            case 'm'
                if strcmpi(fcns{i},'Asymmetric Pearson VII')
                    assert(length(coeff{coeffIndex})>2);
                    if coeff{coeffIndex}(3)=='L'
                        mL=coeffvals(coeffIndex);
                    elseif coeff{coeffIndex}(3)=='R'
                        mR=coeffvals(coeffIndex);
                    end
                else
                    m=coeffvals(coeffIndex);
                end
        end
        coeffIndex = coeffIndex+1;
    end
    
    if con(1); N=N0; NL=N; NR=N; end
    if con(2); xv=xv0; end
    if con(3); f=f0; end
    if con(4); w=w0; end
    if con(5); m=m0; mL=m; mR=m; end
    
    xvk=PackageFitDiffractionData.Ka2fromKa1(xv);
    switch fcns{i}
        case 'Gaussian'
            peakArray(i,:) = N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x2th-xv).^2./f.^2)));
            if handles.xrd.CuKa
                CuKaPeak(i,:)=(1/1.9)*N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).*((x2th-xvk).^2./f.^2)));
            end
        case 'Lorentzian'
            peakArray(i,:) = N.*1./pi* (0.5.*f./((x2th-xv).^2+(0.5.*f).^2));
            if handles.xrd.CuKa
                CuKaPeak(i,:) = (1/1.9)*N.*1./pi* (0.5.*f./((x2th-xvk).^2+(0.5.*f).^2));
            end
        case 'Pearson VII'
            peakArray(i,:) = N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x2th-xv).^2)/f.^2).^(-m);
            if handles.xrd.CuKa
                CuKaPeak(i,:)=(1/1.9)*N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x2th-xvk).^2)/f.^2).^(-m);
            end
        case 'Psuedo Voigt'
            peakArray(i,:) = N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x2th-xv).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x2th-xv).^2./f.^2)));
            if handles.xrd.CuKa
                CuKaPeak(i,:)=(1/1.9)*N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x2th-xvk).^2./f.^2))) + ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x2th-xvk).^2./f.^2)));
            end
        case 'Asymmetric Pearson VII'
            peakArray(i,:) = PackageFitDiffractionData.AsymmCutoff(xv,1,x2th)'.*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x2th-xv).^2/f.^2).^(-mL) + ...
                PackageFitDiffractionData.AsymmCutoff(xv,2,x2th)'.*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x2th-xv).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
            if handles.xrd.CuKa
                CuKaPeak(i,:)=PackageFitDiffractionData.AsymmCutoff(xvk,1,x2th)'.*(1/1.9)*NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x2th-xvk).^2/f.^2).^(-mL) + ...
                    PackageFitDiffractionData.AsymmCutoff(xvk,2,x2th)'.*(1/1.9)*NR.*PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x2th-xvk).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
            end
    end
    
end