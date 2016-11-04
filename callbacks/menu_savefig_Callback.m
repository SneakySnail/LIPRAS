function menu_savefig_Callback(hObject, eventdata, handles)
	profile = find(handles.uipanel3==handles.profiles,1);
	fitOutputPath =strcat(handles.xrd.DataPath,'FitOutputs/Fit_Figure/');
	if ~exist(fitOutputPath,'dir')
		mkdir(fitOutputPath);
	end
	
	tot=handles.text_numprofile.String(end);
	
	for s=1:length(handles.xrd.Filename)
		f_new=figure;
		a1=copyobj(handles.axes1,f_new);
		a2=copyobj(handles.axes2,f_new);
		
		filename=['Profile ',num2str(profile),' of ',tot,' - ',handles.xrd.Filename{s}];
		set(gcf,'name',filename,'numbertitle','off');
		set(a1.Title,'String',filename);
		saveas(gcf,[fitOutputPath,filename,'-plotFit.png'])
		delete(gcf)
	end
	
	handles.xrd.plotFit('all')
	saveas(figure(5),strcat(fitOutputPath,'Profile ',num2str(profile), 'of ',tot,' - ',strcat('Master','-','plotFit')));
	delete(gcf);