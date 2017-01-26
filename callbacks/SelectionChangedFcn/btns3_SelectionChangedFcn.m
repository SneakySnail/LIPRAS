function btns3_SelectionChangedFcn(hObject, evt, handles)
% Executes upon Plot View change in the Results tab.

switch hObject.SelectedObject
        case handles.radio_peakeqn
                handles.gui.onPlotFitChange('peakfit');
                
        case handles.radio_coeff
                handles.gui.onPlotFitChange('coeff');
                
        case handles.radio_statistics
            hObject.SelectedObject = evt.OldValue;
            handles.gui.onPlotFitChange('stats');
           
                
end