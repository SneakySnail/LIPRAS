%
function plotX(handles, type)
if isfield(handles, 'cfit')
    profiledata = handles.cfit(handles.guidata.currentProfile);
else
    %TODO
    profiledata.isFitted = false;
end

if nargin <= 1
    if profiledata.isFitted
        type = 'fit';
    else
        type = 'data';
    end
end


switch lower(type)
    case 'backgroundpoints'
        plotData(handles);
        hold on;
        plotBackgroundPoints(handles);
        resizeAxes1ForErrorPlot(handles, 'data');
        
    case 'backgroundfit'
        plotData(handles);
        hold on
        plotBackgroundFit(handles);
        resizeAxes1ForErrorPlot(handles, 'data');
        
    case 'data'
        plotData(handles);
        handles = plot_sample_fit(handles);
        resizeAxes1ForErrorPlot(handles, 'data');
        
    case 'superimpose'
        plotSuperimposed(handles);
        resizeAxes1ForErrorPlot(handles, 'data');
        
    case 'fit'
        cla(handles.axes1)
        plotFit(handles);
        plotFitError(handles);
        resizeAxes1ForErrorPlot(handles, 'fit');
        
    case 'sample'
        plotData(handles);
        handles = plot_sample_fit(handles);
        resizeAxes1ForErrorPlot(handles, 'data');
        
    case 'allfits'
        plotAllFits(handles);
        
    case 'error'
        plotFitError(handles);
        resizeAxes1ForErrorPlot(handles, 'fit');
        
    case 'coeff' %TODO
        
        
    case 'stats' %TODO
        
        
    otherwise
        
end

% ==============================================================================


%
function plotFit(handles, ifile)
Stro = handles.xrd;
cp = handles.guidata.currentProfile;

if nargin <= 1
    ifile = handles.popup_filename.Value;
end

fcns = handles.guidata.PSfxn{cp};
constraints = handles.guidata.constraints{cp};
coeff = handles.guidata.coeff{cp};
coeffvals = handles.xrd.fit_parms{ifile};


cla
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
    'MarkerFaceColor', [.08 .17 .55],...
    'MarkerEdgeColor',[.08 .17 .55], ...
    'Tag', 'Data'); % Raw Data
data(2) = plot(x2th,background, '--', ...
    'DisplayName', 'Background', ...
    'Tag', 'Background'); % Background
data(3) = plot(x2th,fittedPattern,'k', ...
    'LineWidth',1.5, ...
    'DisplayName','Overall Fit',...
    'Color',[0 .5 0], ...
    'Tag', 'OverallFit'); % Overall Fit

% Color Order for plotting peaks underneath overall fit
co=[0.25 0.25 0.25; ...
    1 0 0; ...
    0 0 1; ...
    0.4940 .1840 0.5560; ...
    .4660 0.6740 0.1880; ...
    0.6350 0.0780 0.1840; ...
    0.75 0.75 0; ...
    0.75 0 0.75];
% From https://www.mathworks.com/help/matlab/graphics_transition/why-are-plot-lines-different-colors.html

for jj=1:size(Stro.PSfxn,2)
    if Stro.CuKa
        data(3+2*jj-1) = plot(x2th',peakfit(jj,:)+background',...
            'LineWidth',1, ...
            'DisplayName',['Cu-K\alpha1 (',num2str(jj),')']);
        data(3+2*jj)=plot(x2th',CuKaPeak(jj,:)+background', ...
            'LineWidth',1, ...
            'DisplayName',['Cu-K\alpha2 (',num2str(jj),')']);
    else
        data(3+jj) = plot(x2th',peakfit(jj,:)+background', ...
            'LineWidth',1, ...
            'DisplayName',['Peak ',num2str(jj)], ...
            'Color',co(jj,1:3), ...
            'Tag', ['f' num2str(jj)]);
    end
end

Stro.DisplayName = {data.DisplayName};
filenum=handles.popup_filename.Value;

xlabel(gca, '2\theta','FontSize',11);
ylabel(gca, 'Intensity','FontSize',11);

set(gca, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');

title(gca, [handles.xrd.Filename{filenum} ' (' num2str(filenum) ' of ' ...
    num2str(length(handles.xrd.Filename)) ')']);

xlim(gca, [handles.xrd.Min2T handles.xrd.Max2T]);
ylim([0.9*min([data.YData]), 1.1*max([data.YData])]);
% ==============================================================================

%
function plotFitError(handles, ifile)
if nargin <= 1
    ifile = handles.popup_filename.Value;
end

Stro = handles.xrd;

x2th = Stro.fit_results{ifile}(1,:);
intensity = Stro.fit_results{ifile}(2,:)';
background = Stro.fit_results{ifile}(3,:)';
fittedPattern = background;

for i=1:length(Stro.PSfxn(:,1))
    fittedPattern = fittedPattern + Stro.fit_results{ifile}(3+i,:)';
end

err = plot(handles.axes2, ...
    x2th, intensity - (fittedPattern), ...
    'r', ...
    'LineWidth',.50, ...
    'Tag', 'Error'); % Error

xlim(gca, [handles.xrd.Min2T handles.xrd.Max2T])
% ==============================================================================



% Plot an example fit using the starting values from table.
function handles = plot_sample_fit(handles)
import ui.control.*
cp = handles.guidata.currentProfile;

% Make sure all the cells with starting values are not empty
try
    profile = handles.cfit(cp);
    SP = profile.FitInitial.start;
    coeff = profile.Coefficients;
    assert(~isempty(coeff));
    %     assert(isempty(find(~strcmpi(coeff, handles.guidata.coeff{cp}), 1)));
    assert(~isempty(SP));
    
    assert(~ProfileData.hasEmptyCell(handles.table_fitinitial));
    assert(length(SP)==length(coeff));
    assert(~isempty(handles.xrd.bkgd2th));
catch
    %     ME.stack(1)
    %     keyboard
    return
end

filenum=get(handles.popup_filename,'Value');
fitrange=str2double(get(handles.edit_fitrange,'string'));
data=handles.xrd.getRangedData(filenum,fitrange);
% bkgd2th = handles.xrd.getBkgdPoints();

% Get Background
wprof=handles.guidata.currentProfile;
bkgModel=handles.popup_bkgdmodel.Value;

if handles.popup_bkgdmodel.Value==1
    [bkgArray, S, U] = handles.xrd.fitBkgd(data, handles.points{wprof}, data(2,handles.pos{wprof}), bkgModel);
else
    % A bit silly, bkgx and bkgy need the end points, otherwise, the final
    % function wont evaluate the last points and it will lead to a value of
    % zero...
    bkgx=handles.points{wprof}';
    bkgy(1,:)=data(2,handles.pos{wprof});
    [bkgArray]=handles.xrd.fitBkgd(data,bkgx, bkgy,bkgModel);
end

% Use initial coefficient values to plot fit
peakPos=handles.guidata.PeakPositions{cp};
peakNames=handles.guidata.PSfxn{cp};
constraints=handles.guidata.constraints{cp};
coeff = handles.guidata.coeff{cp};

hold on
datafit=plot(data(1,:),bkgArray,':',...
    'LineWidth',1,...
    'Color',[0.2 0.2 0.2],...
    'DisplayName','Background');

x2th=data(1,:);

[peakArray, CuKaPeak] = calculatePeakResults(handles, x2th, coeff, SP, peakNames, constraints);

for i=1:handles.guidata.numPeaks
    datafit(end+1)=plot(x2th,peakArray(i,:)+bkgArray,'--','LineWidth',1,...
        'DisplayName',['Peak ', num2str(i),' (',peakNames{i},')']);
    if handles.xrd.CuKa
        datafit(end+1)=plot(x2th,CuKaPeak(i,:)+bkgArray,':','LineWidth',2,...
            'DisplayName',['Cu-K\alpha2 (Peak ', num2str(i), ')']);
    end
end

dispname={datafit.DisplayName};
handles.xrd.DisplayName=[handles.xrd.DisplayName, dispname];
xlim(gca, [handles.xrd.Min2T handles.xrd.Max2T])

filenum=handles.popup_filename.Value;

xlabel('2\theta','FontSize',11);
ylabel('Intensity','FontSize',11);

set(handles.axes1, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');

title(handles.axes1, [handles.xrd.Filename{filenum} ' (' num2str(filenum) ' of ' ...
    num2str(length(handles.xrd.Filename)) ')']);
% ==============================================================================

% Calculates the result of the fit and returns an array.
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
            peakArray(i,:) = N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.*log(2).* ...
                ((x2th-xv).^2./f.^2)));
            if handles.xrd.CuKa
                CuKaPeak(i,:)=(1/1.9)*N.*((2.*sqrt(log(2)))./(sqrt(pi).*f).*exp(-4.* ...
                    log(2).*((x2th-xvk).^2./f.^2)));
            end
        case 'Lorentzian'
            peakArray(i,:) = N.*1./pi* (0.5.*f./((x2th-xv).^2+(0.5.*f).^2));
            if handles.xrd.CuKa
                CuKaPeak(i,:) = (1/1.9)*N.*1./pi* (0.5.*f./((x2th-xvk).^2+(0.5.*f).^2));
            end
        case 'Pearson VII'
            peakArray(i,:) = N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* gamma(m) / ...
                gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x2th-xv).^2)/f.^2).^(-m);
            if handles.xrd.CuKa
                CuKaPeak(i,:)=(1/1.9)*N.*2.* ((2.^(1/m)-1).^0.5) / f / (pi.^0.5) .* ...
                    gamma(m) / gamma(m-0.5) .* (1+4.*(2.^(1/m)-1).*((x2th-xvk).^2)/f.^2).^(-m);
            end
        case 'Pseudo-Voigt'
            peakArray(i,:) = N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x2th-xv).^2./f.^2))) + ...
                ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x2th-xv).^2./f.^2)));
            if handles.xrd.CuKa
                CuKaPeak(i,:)=(1/1.9)*N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(x2th-xvk).^2./f.^2))) + ...
                    ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(x2th-xvk).^2./f.^2)));
            end
        case 'Asymmetric Pearson VII'
            peakArray(i,:) = PackageFitDiffractionData.AsymmCutoff(xv,1,x2th)'.* ...
                NL*PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x2th-xv).^2/f.^2).^(-mL) + ...
                PackageFitDiffractionData.AsymmCutoff(xv,2,x2th)'.*NR.*PackageFitDiffractionData.C4(mR)/ ...
                (f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).* ...
                (1+4.*(2.^(1/mR)-1).*(x2th-xv).^2/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
            
            if handles.xrd.CuKa
                CuKaPeak(i,:)=PackageFitDiffractionData.AsymmCutoff(xvk,1,x2th)'.*(1/1.9)*NL* ...
                    PackageFitDiffractionData.C4(mL)./f.*(1+4.*(2.^(1/mL)-1).*(x2th-xvk).^2/f.^2).^(-mL) + ...
                    PackageFitDiffractionData.AsymmCutoff(xvk,2,x2th)'.*(1/1.9)*NR.* ...
                    PackageFitDiffractionData.C4(mR)/(f.*NR/NL.*PackageFitDiffractionData.C4(mR)/ ...
                    PackageFitDiffractionData.C4(mL)).*(1+4.*(2.^(1/mR)-1).*(x2th-xvk).^2/(f.*NR/NL.* ...
                    PackageFitDiffractionData.C4(mR)/PackageFitDiffractionData.C4(mL)).^2).^(-mR);
            end
    end
    
end

% ==============================================================================

function plotData(handles)
% PLOTDATA Plots the raw data for a specified file number in axes1.
Stro = handles.xrd;
dataSet = handles.popup_filename.Value;
hold off

x = Stro.two_theta;
c=find(Stro.Min2T <= Stro.two_theta & Stro.Max2T >= Stro.two_theta);
intensity = Stro.data_fit(dataSet,:);

ymax=max(intensity(c));
ymin=min(intensity(c));

if isempty(Stro.bkgd2th)
    plot(x,intensity,'-o','LineWidth',0.5,'MarkerSize',5, 'MarkerFaceColor', [1 1 1]);
else
    plot(x,intensity,'-o','LineWidth',0.5,'MarkerSize',4, 'MarkerFaceColor', [0 0 0]);
end

Stro.DisplayName = Stro.Filename(dataSet);

ylim([0.9*ymin,1.1*ymax])
xlim(gca, [Stro.Min2T, Stro.Max2T])

filenum=handles.popup_filename.Value;

xlabel('2\theta','FontSize',11);
ylabel('Intensity','FontSize',11);

set(handles.axes1, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');

title(handles.axes1, [handles.xrd.Filename{filenum} ' (' num2str(filenum) ' of ' ...
    num2str(length(handles.xrd.Filename)) ')']);
% ==============================================================================

% Like plotData, except turns on hold to enable multiple
%    data to be plotted in handles.axes1.
function plotSuperimposed(handles)

Stro = handles.xrd;

dataSet = handles.popup_filename.Value;

x = Stro.two_theta;

c = find(Stro.Min2T <= Stro.two_theta & Stro.Max2T >= Stro.two_theta);

intensity = Stro.data_fit(dataSet, :);

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
    
end

filenum=handles.popup_filename.Value;

xlabel('2\theta','FontSize',11);
ylabel('Intensity','FontSize',11);

set(handles.axes1, 'XTickMode', 'auto', 'XTickLabelMode', 'auto');

title(handles.axes1, [handles.xrd.Filename{filenum} ' (' num2str(filenum) ' of ' ...
    num2str(length(handles.xrd.Filename)) ')']);
% ==============================================================================


% Makes a new figure and plots each fit for the entire dataset.
function plotAllFits(handles)
Stro = handles.xrd;

numFiles = size(Stro.fit_results,2);
figure(5);

for j=1:numFiles
    ax(j) = subplot(floor(sqrt(size(Stro.fit_results,2))),ceil(size(Stro.fit_results,2)/floor(sqrt(size(Stro.fit_results,2)))),j);
    hold on
    
    plotFit(handles, j);
    xlabel('2\theta','FontSize',11);
    ylabel('Intensity','FontSize',11);
    
    title(gca, [handles.xrd.Filename{j} ' (' num2str(j) ' of ' ...
        num2str(length(handles.xrd.Filename)) ')']);
end

linkaxes(ax,'xy');
xlim(gca, [handles.xrd.Min2T handles.xrd.Max2T])
% ==============================================================================


function plotCoefficient(handles, r)
% r = row number
hTable = handles.table_results;

vals = [hTable.Data{r, 2:end}];
numfiles = length(vals);
filenames = handles.xrd.Filename;


axes(handles.axes1)
cla
plot(1:numfiles, vals, '-d', ...
    'MarkerSize', 8, ...
    'MarkerFaceColor', [0 0 0], ...
    'DisplayName', hTable.RowName{r})
xlim([1 numfiles])

set(handles.axes1, ...
    'XTick', 1:numfiles, ...
    'XTickLabel', 1:numfiles, ...
    'YLimMode', 'auto');
handles.axes1.XLabel.String = 'File Number';

if strcmpi(handles.uitoggletool5.State,'on')
    legend(hTable.RowName{r})
end

xlim(gca, [handles.xrd.Min2T handles.xrd.Max2T])

% ==============================================================================

% plots the statistics of all the fits, when 'Fit Statistics' is selected
function plotFitStats(handles, r)

hTable = handles.table_results;

vals = [hTable.Data{r, 2:end}];
numfiles = length(vals);
filenames = handles.xrd.Filename;
assert(numfiles == length(filenames));

for p=1:length(vals)
    rsquared(p)=handles.xrd.FmodelGOF{p}.rsquare;
    adjrsquared(p)=handles.xrd.FmodelGOF{p}.adjrsquare;
    rmse(p)=handles.xrd.FmodelGOF{p}.rmse;
    obs=handles.xrd.fit_results{1,p}(2,:)';
    calc=handles.xrd.fit_results{1,p}(3,:)'+handles.xrd.fit_results{1,p}(4,:)';
    Rp(p)=(sum(abs(obs-calc))./(sum(obs)))*100; %calculates Rp
    w=(1./obs); %defines the weighing parameter for Rwp
    Rwp(p)=(sqrt(sum(w.*(obs-calc).^2)./sum(w.*obs.^2)))*100 ; %Calculate Rwp
    DOF=handles.xrd.FmodelGOF{p}.dfe; % degrees of freedom from error
    Rexp(p)=sqrt(DOF/sum(w.*obs.^2)); % Rexpected
    Rchi2(p)=(Rwp/Rexp)/100; % reduced chi-squared, GOF
    
end
axes(handles.axes1)

if strcmp(s,'Rsquare')
    close(figure(5))
    figure(5)
    hold on
    for j=1:6
        ax(j)=subplot(2,3,j);
    end
    plot(ax(1),1:numfiles, rsquared, '-ob', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'R^2')
    ylabel(ax(1),'R^2','FontSize',14)
    xlabel(ax(1),'File Number')
    plot(ax(2),1:numfiles, adjrsquared, '-or', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'AdjR^2')
    
    ylabel(ax(2),'Adjusted R^2','FontSize',14)
    xlabel(ax(2),'File Number')
    plot(ax(3),1:numfiles, rmse, '-og', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'RMSE')
    
    ylabel(ax(3),'Root MSE','FontSize',14)
    xlabel(ax(3),'File Number')
    
    plot(ax(4),1:numfiles, Rp, '-o','Color',[0.85 0.33 0], ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'Rp')
    
    ylabel(ax(4),'Rp','FontSize',14)
    xlabel(ax(4),'File Number')
    
    plot(ax(5),1:numfiles, Rwp, '-om', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'RMSE')
    
    ylabel(ax(5),'Rwp','FontSize',14)
    xlabel(ax(5),'File Number')
    
    plot(ax(6),1:numfiles, Rchi2, '-o', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', [0 0 0], ...
        'DisplayName', 'Reduced \chi^2')
    
    ylabel(ax(6),'Reduced \chi^2','FontSize',14)
    xlabel(ax(6),'File Number')
    
end
set(handles.axes1, ...
    'XTick', 1:numfiles, ...
    'XTickLabel', 1:numfiles, ...
    'YLimMode', 'auto');
handles.axes1.XLabel.String = 'File Number';
linkaxes([ax(1),ax(2),ax(3),ax(4),ax(5),ax(6)], 'x')


xlim([1 numfiles])
% ==============================================================================

function handles = plotBackgroundFit( handles )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here





function plotBackgroundPoints(handles) % plots points and BkgFit
% The current file TODO: "getCurrentFile(handles.popup_filename)"
iFile = handles.popup_filename.Value;
data = handles.xrd.getRangedData(iFile);
profiledata = handles.cfit(handles.guidata.currentProfile);

% Get Background
bkgModel=handles.popup_bkgdmodel.Value;

if handles.popup_bkgdmodel.Value==1
    [bkgArray, S, U]=handles.xrd.fitBkgd(data, profiledata.BackgroundPoints, data(2,profiledata.BackgroundPointsIdx), bkgModel);
    
else
    % A bit silly, bkgx and bkgy need the end points, otherwise, the final
    % function wont evaluate the last points and it will lead to a value of
    % zero...
    bkgx=profiledata.BackgroundPoints';
    bkgy(1,:)=data(2,profiledata.BackgroundPointsIdx);
    [bkgArray]=handles.xrd.fitBkgd(data,bkgx, bkgy, bkgModel);
end

points = profiledata.BackgroundPoints;
idx = profiledata.BackgroundPointsIdx;

% cla(handles.axes1)

hold off
plot(handles.axes1,data(1,:),data(2,:),'-o','LineWidth',0.5,'MarkerSize',4, 'MarkerFaceColor', [0 0 0])

hold on
plot(handles.axes1, points, data(2,idx), 'rd', 'markersize', 5, ...
    'markeredgecolor', 'r', 'markerfacecolor','r');
plot(handles.axes1,data(1,:),bkgArray,'--')



