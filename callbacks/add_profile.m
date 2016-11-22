function handles = add_profile(handles)

profileNum = handles.guidata.numProfiles+1;
handles.guidata.numProfiles = profileNum;
handles.profiles(7).UserData = profileNum;

handles.profiles(profileNum) = duplicate_uipanel3();

createXRD();

handles = change_profile(profileNum, handles);

createGUIdata();

controlProfilePanel(handles);


        function controlProfilePanel(handles)
                if handles.guidata.numProfiles >= 6
                        set(handles.push_addprofile, 'enable', 'off');
                        
                elseif handles.guidata.numProfiles > 1
                        set(handles.push_prevprofile, 'visible','on','enable','on');
                        set(handles.push_nextprofile,'visible','on', 'enable', 'off');
                        set(handles.push_addprofile, 'enable', 'on');
                        set(handles.push_removeprofile,'enable','on', 'visible', 'on');
                else
                        set(handles.push_prevprofile, 'visible','off');
                        set(handles.push_nextprofile,'visible','off');
                        set(handles.push_addprofile, 'enable', 'on');
                        set(handles.push_removeprofile, 'visible', 'off');
                end
        end


%****************************************
% New
%****************************************
        function createGUIdata()
                setappdata(handles.uipanel3, 'xrd', handles.xrdContainer(profileNum));
                setappdata(handles.uipanel3, 'numPeaks', 0);
                setappdata(handles.uipanel3, 'PSfxn', '');
                setappdata(handles.uipanel3, 'PeakPositions', []);
                setappdata(handles.uipanel3, 'constraints', zeros(1,5));
                setappdata(handles.uipanel3, 'fitBounds', []);
                setappdata(handles.uipanel3, 'coeff', '');
                setappdata(handles.uipanel3, 'fit_results', []);
                
        end


        function obj = duplicate_uipanel3()
                
                
                % Takes handles.profiles(1) and returns a deep copy. If there is an existing
                % profile panel, then just reset the panel.
                obj = copyobj(handles.profiles(7), handles.figure1);
                
                popup = findobj(obj.Children, 'style', 'popupmenu');
                edit = findobj(obj.Children, 'style', 'edit');
                check = findobj(obj.Children, 'style', 'checkbox');
                
                
                baseCtrls = findobj(handles.profiles(7).Children);
                newCtrls = findobj(obj.Children);
                assert(length(baseCtrls) == length(newCtrls)); % Make sure they have the same number of children
                
                % Assign callbacks for all new uicontrols
                for i=1:length(baseCtrls)
                        if isprop(baseCtrls(i), 'Callback')
                                newCtrls(i).Callback = baseCtrls(i).Callback;
                        end
                        if isprop(baseCtrls(i), 'CellEditCallback')
                                newCtrls(i).CellEditCallback = baseCtrls(i).CellEditCallback;
                        end
                        if isprop(baseCtrls(i), 'CellSelectionCallback')
                                newCtrls(i).CellSelectionCallback = baseCtrls(i).CellSelectionCallback;
                        end
                        if isprop(baseCtrls(i), 'SelectionChangedFcn')
                                newCtrls(i).SelectionChangedFcn = baseCtrls(i).SelectionChangedFcn;
                        end
                        if isprop(baseCtrls(i), 'ButtonDownFcn')
                                newCtrls(i).ButtonDownFcn = baseCtrls(i).ButtonDownFcn;
                        end
                end
                
                editpeak = findobj(newCtrls, 'tag', 'edit_numpeaks');
                addlistener(editpeak, 'UserData', 'PostSet', @(o,e)guidata.numpeaks(o,e,guidata(e.AffectedObject)));
                
                
                %********************************************************%
                % Create tab panels
                %********************************************************%
                handles.tabpanel = uix.TabPanel('parent', obj, 'tag','tabpanel');
                set(findobj(obj,'tag', 'panel_setup'), 'parent', handles.tabpanel, 'visible', 'on', 'title', '');
                set(findobj(obj,'tag','panel_parameters'),'parent',handles.tabpanel, 'visible', 'on', 'title','');
                set(findobj(obj,'tag','panel_results'), 'parent', handles.tabpanel, 'visible', 'on', 'title','');
                set(handles.panel_coeffs, 'visible', 'off');
                
                set(handles.tabpanel, 'tabtitles', {'1. Setup', '2. Options', '3. Results'}, ...
                        'tabenables', {'on','off','off'}, 'fontsize', 11, 'tabwidth', 75);
                
                
        end


        function createXRD
                handles.xrdContainer(profileNum) = copy(handles.xrdContainer(7));
                handles.profiles(profileNum).UserData = profileNum;
                
                % Add listener for each xrd object
                addlistener(handles.xrdContainer(profileNum), 'Status', ...
                        'PostSet', @(o,e)statusChange(o,e,handles,profileNum));
                
                minbox = findobj(handles.profiles(profileNum),'Tag','edit_min2t');
                maxbox = findobj(handles.profiles(profileNum),'Tag','edit_max2t');
                
                range = [handles.xrdContainer(7).Min2T handles.xrdContainer(7).Max2T];
                set(minbox,'String',num2str(range(1)));
                set(maxbox,'String',num2str(range(2)));
                
                panel4=findobj(handles.profiles(profileNum),'Tag','panel_coeffs');
                uitable=findobj(panel4,'Tag','table_fitinitial');
                uitable.Data=cell(1,4);
        end

end