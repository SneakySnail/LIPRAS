function menu_savefig_Callback(hObject, eventdata, handles)
profile = find(handles.uipanel3==handles.profiles,1);
fitOutputPath =strcat(handles.xrd.DataPath,'FitOutputs/Fit_Figure/');
if ~exist(fitOutputPath,'dir')
mkdir(fitOutputPath);
end

tot=handles.text_numprofile.String(end);

for s=1:length(handles.xrd.Filename)
    f_new=figure('visible','off');
    a1=copyobj(handles.axes1,f_new);
    a2=copyobj(handles.axes2,f_new);
    ff=strsplit(handles.xrd.Filename{s},'.');
    filename=['Profile ',num2str(profile),' of ',tot,' - ',ff{1}];
    set(gcf,'name',filename,'numbertitle','off');
    set(a1.Title,'String',filename);
    set(gcf,'Visible','off','CreateFcn','set(gcf,''Visible'',''on'')')
    savefig(gcf,[fitOutputPath,filename,'-plotFit.fig'])
    delete(gcf)
end

plotFit(handles, 'all');
saveas(figure(5),strcat(fitOutputPath,'Profile ',num2str(profile), 'of ',tot,' - ',strcat('Master','-','plotFit')));
delete(gcf);




	profile = find(handles.uipanel3==handles.profiles,1);
	fitOutputPath =strcat(handles.xrd.DataPath,'FitOutputs/Fit_Figure/');
	if ~exist(fitOutputPath,'dir')
		mkdir(fitOutputPath);
	end
	
	tot=handles.text_numprofile.String(end);
	
	for s=1:length(handles.xrd.Filename)
		f_new=figure('visible', 'off');
		a1=copyobj(handles.axes1,f_new);
		a2=copyobj(handles.axes2,f_new);
		ff = strsplit(handles.xrd.Filename{s}, '.');
		filename=['Profile ',num2str(profile),' of ',tot,' - ', ff{1}];
		set(gcf,'name',filename,'numbertitle','off');
		set(a1.Title,'String',filename);
		saveas(gcf,[fitOutputPath,filename,'-plotFit.png'])
		delete(gcf)
	end
	
	plotX(handles, 'allfits');
    
	saveas(figure(5),strcat(fitOutputPath,'Profile ',num2str(profile), 'of ',tot,' - ',strcat('Master','-','plotFit')));
	delete(gcf);