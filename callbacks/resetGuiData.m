function handles = resetGuiData(handles, cp, varargin)
if nargin > 2
    for i=1:length(varargin)
        switch lower(varargin{i})
            case 'peakpositions'
                handles.guidata.PeakPositions = [];
                
            case 'psfxn'
                handles.guidata.PSfxn{profileNum} = '';
                
            case 'numpeaks'
                handles.guidata.numPeaks(profileNum) = 0;
                
            case 'constraints'
                handles.guidata.constraints{profileNum} = zeros(1,5);
                
            case 'fit_initial'
                handles.guidata.fit_initial{profileNum} = [];
                
            case 'fitrange'
                handles.guidata.fitrange{profileNum} = [];
                
            case 'coeff'
                handles.guidata.coeff{profileNum} = '';
                
            case 'fit_results'
                handles.guidata.fitted{profileNum} = false;
                
            case 'profile'
                handles = resetProfileData(handles, cp);
                
        end
    end
    
elseif nargin > 1
    handles = resetProfileData(handles, cp);
    
elseif nargin==1
    handles.guidata.numProfiles = 0;
    handles.guidata.currentProfile = 0;
    handles = resetProfileData(handles);
end

assignin('base', 'handles', handles);
guidata(handles.figure1, handles);



function handles = resetProfileData(handles, profileNum)
if nargin > 1
    handles.guidata.PeakPositions{profileNum} = [];
    handles.guidata.PSfxn{profileNum} = '';
    handles.guidata.numPeaks(profileNum) = 0;
    handles.guidata.constraints{profileNum} = zeros(1,5);
    handles.guidata.fit_initial{profileNum} = [];
    handles.guidata.fitrange{profileNum} = [];
    handles.guidata.coeff{profileNum} = '';
    handles.guidata.fitted{profileNum} = false;
else
    handles.guidata.PeakPositions = {[]};
    handles.guidata.PSfxn = {''};
    handles.guidata.numPeaks = 0;
    handles.guidata.constraints = {[]};
    handles.guidata.fit_initial = {[]};
    handles.guidata.fitrange = [];
    handles.guidata.coeff = {''};
    handles.guidata.fitted = {false};
end
    
