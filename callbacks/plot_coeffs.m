function plot_coeffs(r, s, handles)
% r = row number
if nargin <3
    s='NoStats';
end
hTable = handles.table_results;
set(findobj(handles.axes2), 'visible', 'off');

vals = [hTable.Data{r, 2:end}];
numfiles = length(vals);
filenames = handles.xrd.Filename;
assert(numfiles == length(filenames));

if strcmp(s,'NoStats')==0 % plots the statistics of all the fits, when 'Fit Statistics' is selected
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
    
    hold off
else
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
    
    if strcmpi(handles.toolbar_legend.State,'on')
        legend(hTable.RowName{r})
    end
end

resizeAxes1ForErrorPlot(handles, 'data');