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

    if strcmp(s,'NoStats')==0
    for p=1:length(vals)    
                rsquared(p)=handles.xrd.FmodelGOF{p}.rsquare;
                        adjrsquared(p)=handles.xrd.FmodelGOF{p}.adjrsquare;
                                rmse(p)=handles.xrd.FmodelGOF{p}.rmse;
    end
	axes(handles.axes1)
% 	cla
            if strcmp(s,'Rsquare')
   hold on             
                	close(figure(5))
                figure(5)
         for j=1:3       
     			ax(j) = subplot(floor(sqrt(size(handles.xrd.fit_results,2))),ceil(size(handles.xrd.fit_results,2)/floor(sqrt(size(handles.xrd.fit_results,2)))),j);
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
	xlim([1 numfiles])
       ylabel(ax(2),'Adjusted R^2','FontSize',14)
     xlabel(ax(2),'File Number')
    plot(ax(3),1:numfiles, rmse, '-og', ...
		'MarkerSize', 8, ...
		'MarkerFaceColor', [0 0 0], ...
		'DisplayName', 'RMSE')
	xlim([1 numfiles])
    ylabel('Root Mean Square Error','FontSize',14)
    xlabel('File Number')
            end
	set(handles.axes1, ...
		'XTick', 1:numfiles, ...
		'XTickLabel', 1:numfiles, ...
		'YLimMode', 'auto');
	handles.axes1.XLabel.String = 'File Number';
    linkaxes([ax(1),ax(2),ax(3)], 'x')
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
	
	if strcmpi(handles.uitoggletool5.State,'on')
			legend(hTable.RowName{r})
		end
    end