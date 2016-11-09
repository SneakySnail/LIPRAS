% Change look and feel
	com.jidesoft.plaf.LookAndFeelFactory.installJideExtension();
	
	jFrame=get(hObject,'JavaFrame');
	jFigPanel =  get(jFrame, 'FigurePanelContainer');
	JavaFrame = jFigPanel.getComponent(0).getRootPane;
	
	
	% Set figure look and feel
	originalLnF = javax.swing.UIManager.getLookAndFeel;
	uimanager = javaObjectEDT('javax.swing.UIManager');
	
	
	try
		lf = javax.swing.UIManager.getCrossPlatformLookAndFeelClassName();
		javaMethodEDT('setLookAndFeel', uimanager, lf);
		% 		javax.swing.UIManager.setLookAndFeel(lf);
		% 		drawnow();
	catch
		try
			lf = 'javax.swing.plaf.nimbus.NimbusLookAndFeel';
			javaMethodEDT('setLookAndFeel', uimanager, lf);
			% 			drawnow();
		catch
			javaMethodEDT('setLookAndFeel', uimanager, originalLnF);
			% 			drawnow();
		end
	end
	
	
	
	javaMethodEDT('setLookAndFeel', uimanager, originalLnF);
	javax.swing.SwingUtilities.updateComponentTreeUI(JavaFrame);
	drawnow();
	
	
	setappdata(handles.figure1, 'originalLnF', originalLnF);
	setappdata(handles.figure1,'lf', lf);
	setappdata(handles.figure1, 'jFigPanel', jFigPanel);
	setappdata(handles.figure1, 'JavaFrame', JavaFrame);
	setappdata(handles.figure1, 'jRootPane', jRootPane);
	
	%*********************
	uimanager = javaObjectEDT('javax.swing.UIManager');
	lf = getappdata(handles.figure1, 'lf');
		javaMethodEDT('setLookAndFeel', uimanager, lf);
		
		
		
		drawnow();
		javaMethodEDT('setLookAndFeel', uimanager, getappdata(handles.figure1, 'originalLnF'));