function plotX(handles, type)
set(findobj(handles.axes2), 'visible', 'off');
cla(handles.axes1)
cla(handles.axes2)

filenum=handles.popup_filename.Value;
cp = handles.guidata.currentProfile;

if nargin <= 1
    if ~handles.guidata.fitted{cp} % If there isn't a fit yet
        plotData(handles);
        if ~isempty(handles.guidata.fit_initial{cp})
            handles = plot_sample_fit(handles);
        end
    else
        plotFit(handles);
    end
    
else
    switch type
        case 'data' 
            plotData(handles);
            handles = plot_sample_fit(handles);
            
        case 'fit'
            plotFit(handles);
            
        case 'sample'
            plotData(handles);
            handles = plot_sample_fit(handles);
            
        otherwise
            plotX(handles);
    end
end

xlabel('2\theta','FontSize',11);
ylabel('Intensity','FontSize',11);
set(handles.axes1, 'XTickMode', 'auto', 'XTickLabelMode', 'auto')
title(handles.axes1, [handles.xrd.Filename{filenum} ' (' num2str(filenum) ' of ' ...
    num2str(length(handles.xrd.Filename)) ')']);

LIPRAS('uitoggletool5_OnCallback', handles.uitoggletool5, [], handles);


% TODO Move to FDGUIv2_1
function plotFit(handles)
resizeAxes1ForErrorPlot(handles, 'fit');
cla(handles.axes1)

Stro = handles.xrd;
cp = handles.guidata.currentProfile;
ifile = handles.popup_filename.Value;

fcns = handles.guidata.PSfxn{cp};
constraints = handles.guidata.constraints{cp};
coeff = handles.guidata.coeff{cp};
coeffvals = handles.xrd.fit_parms{ifile};


cla(handles.axes1)
x2th = Stro.fit_results{ifile}(1,:);
intensity = Stro.fit_results{ifile}(2,:)';
background = Stro.fit_results{ifile}(3,:)';
fittedPattern = background;

for i=1:length(Stro.PSfxn(:,1))
    fittedPattern = fittedPattern + Stro.fit_results{ifile}(3+i,:)';
end
[peakfit, CuKaPeak] = calculatePeakResults(handles, x2th, coeff, coeffvals, fcns, constraints);

hold on

data(1) = plot(x2th,intensity,'o', ...
    'LineWidth',1, ...
    'MarkerSize',4, ...
    'DisplayName','Raw Data', ...
    'MarkerFaceColor', [.08 .17 .55],'MarkerEdgeColor',[.08 .17 .55]); % Raw Data
data(2) = plot(x2th,background, '--', ...
    'DisplayName', 'Background'); % Background
data(3) = plot(x2th,fittedPattern,'k', ...
    'LineWidth',1.5, ...
    'DisplayName','Overall Fit','Color',[0 .5 0]); % Overall Fit

co=[0.25 0.25 0.25;1 0 0; 0 0 1;0.4940 .1840 0.5560;.4660 0.6740 0.1880;0.6350 0.0780 0.1840; 0.75 0.75 0; 0.75 0 0.75]; % Color Order for plotting peaks underneath overall fit
% From https://www.mathworks.com/help/matlab/graphics_transition/why-are-plot-lines-different-colors.html

for jj=1:size(Stro.PSfxn,2)
    if Stro.CuKa
        data(3+2*jj-1) = plot(x2th',peakfit(jj,:)+background','LineWidth',1,'DisplayName',['Cu-K\alpha1 (',num2str(jj),')']);
        data(3+2*jj)=plot(x2th',CuKaPeak(jj,:)+background','LineWidth',1,'DisplayName',['Cu-K\alpha2 (',num2str(jj),')']);
    else
        data(3+jj) = plot(x2th',peakfit(jj,:)+background','LineWidth',1,'DisplayName',['Peak ',num2str(jj)],'Color',co(jj,1:3));
    end
end

Stro.DisplayName = {data.DisplayName};

err = plot(handles.axes2, x2th, intensity - (fittedPattern), 'r','LineWidth',.50); % Error

axes(handles.axes1)

xlim([Stro.Min2T Stro.Max2T])
ylim([0.9*min([data.YData]), 1.1*max([data.YData])]);

% Plot an example fit using the starting values from table
function handles = plot_sample_fit(handles)
resizeAxes1ForErrorPlot(handles, 'data');
cp = handles.guidata.currentProfile;

% Make sure all the cells with starting values are not empty
try
    SP = handles.guidata.fit_initial{cp}{1};
    coeff=handles.table_fitinitial.RowName';
    assert(~isempty(coeff));
    assert(isempty(find(~strcmpi(coeff, handles.guidata.coeff{cp}), 1)));
    assert(~isempty(SP));
    
    temp = cellfun(@isempty, handles.table_fitinitial.Data(:, 1:3));
    assert(isempty(find(temp, 1)));
    assert(length(SP)==length(coeff));
    assert(~isempty(handles.xrd.bkgd2th));
catch
    return
end

filenum=get(handles.popup_filename,'Value');
fitrange=str2double(get(handles.edit_fitrange,'string'));
data=handles.xrd.getRangedData(filenum,fitrange);
bkgd2th = handles.xrd.getBkgdPoints();

% Get background fit
[P,S,U]=PackageFitDiffractionData.fitBkgd(data, bkgd2th, handles.xrd.PolyOrder);

% Subtract background fit from raw data
background=polyval(P,data(1,:),S,U);

% Use initial coefficient values to plot fit
peakPos=handles.guidata.PeakPositions{cp};
peakNames=handles.guidata.PSfxn{cp};
constraints=handles.guidata.constraints{cp};
coeff = handles.guidata.coeff{cp};

hold on
datafit=plot(data(1,:),background,':',...
    'LineWidth',1,...
    'Color',[0.2 0.2 0.2],...
    'DisplayName','Background');

x2th=data(1,:);

[peakArray, CuKaPeak] = calculatePeakResults(handles, x2th, coeff, SP, peakNames, constraints);

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



function [peakArray, CuKaPeak] = calculatePeakResults(handles, x2th, coeff, coeffvals, fcns, constraints)
coeffIndex=1;

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