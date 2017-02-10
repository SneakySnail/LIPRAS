classdef LiprasGuiChiDataTest < matlab.unittest.TestCase
    %LIPRASGUICHIFILESTEST tests the LIPRAS GUI with data imported from .chi files. It verifies that
    %   the values displayed in the GUI are the same as the values saved in handles.profiles AND
    %   handles.gui.
    properties
        hg
        AxisLimTolerance = 0.1;
    end
   
    methods (TestClassSetup)
        function createGUI(testCase)
        %CREATEGUI saves the handle of the GUI figure to its property TestFigure. Because LIPRAS is
        %   a singleton program, it will create a new figure only if one does not exist. Otherwise,
        %   it will bring to focus the currently open figure.
        delete(findall(0,'tag', 'figure1'));
        clear('handles', 'var');
        fig = LIPRAS;
        testCase.hg = guidata(fig);
        gui = testCase.hg.gui;
        profiles = testCase.hg.profiles;
        
        testCase.verifyEmpty(gui.DataPath);
        testCase.verifyEqual(testCase.hg.edit8.String, 'Upload new file(s)...');
        testCase.verifyEmpty(profiles.DataPath);
        testCase.verifyEqual(profiles.OutputPath, ['FitOutputs' filesep]);
        % Only read in 2 files for simplicity
        [data, filenames, path] = utils.fileutils.newDataSet({'350.chi', '351.chi','354.chi', '355.chi'}, [pwd filesep]);
        testCase.hg.profiles.newXRD(PackageFitDiffractionData(data, filenames, path));
        
        % Simulate button_browse press. Copy of button_browse_Callback function so as not to trigger
        % uigetfile dialog.
        ui.update(testCase.hg, 'dataset');
        
        % Verify that path was updated
        testCase.verifyNotEmpty(gui.DataPath);
        testCase.verifyNotEmpty(profiles.DataPath);
        testCase.verifyNotEqual(testCase.hg.edit8.String, 'Upload new file(s)...');
        testCase.verifyEqual([profiles.DataPath 'FitOutputs' filesep], profiles.OutputPath);
        end
    end
    
    % Unit test functions
    methods (Test)
        
        function editMinProfileRangeTest(testcase)
        %EDITMINPROFILERANGE changes the minimum profile range to 3.4.
        handles = testcase.hg;
        handles.tabpanel.Selection = 1;
        value = 3.4;
        set(handles.edit_min2t, 'string', num2str(value));
        LIPRAS('edit_min2t_Callback',handles.edit_min2t, [], handles);
        % Assert that the model values are the same as the GUI's
        testcase.verifyEqual(handles.profiles.xrd.Min2T, value);
        testcase.verifyLessThan(handles.axes1.XAxis.Limits(1)-value, testcase.AxisLimTolerance);
        end
        
        function editMaxProfileRangeTest(testcase)
        handles = testcase.hg;
        handles.tabpanel.Selection = 1;
        value = 5;
        set(handles.edit_max2t, 'string', num2str(value));
        LIPRAS('edit_max2t_Callback',handles.edit_max2t, [], handles);
        % Assert that the model values are the same as the GUI's
        testcase.verifyEqual(handles.profiles.xrd.Max2T, value);
        testcase.verifyLessThan(handles.axes1.XAxis.Limits(2)-value, testcase.AxisLimTolerance);
        end
        
        function editBackgroundModelTest(testcase)
        %EDITBACKGROUNDOPTIONS
        %
        %   Changes:
        %       BackgroundModel = 'Spline'
        handles = testcase.hg;
        handles.tabpanel.Selection = 1;
        testobj1 = handles.popup_bkgdmodel;
        testobj1.Value = 2;
        LIPRAS('popup_bkgdmodel_Callback',testobj1,[],handles);
        testcase.verifyEqual(testobj1.String{testobj1.Value}, 'Spline');
        testcase.verifyEqual(handles.gui.BackgroundModel, 'Spline');
        testcase.verifyEqual(handles.profiles.xrd.getBackgroundModel, 'Spline');
        end
        
        function backgroundPointsTest(testcase)
        %BACKGROUNDPOINTS
        %       Background Points = [3.5, 4, 4.2, 4.7, 4.8, 4.3]
        handles = testcase.hg;
        handles.tabpanel.Selection = 1;
        testobj = handles.push_newbkgd;
        % Using the variable evt to pass into the GUI callback as the eventdata argument
        evt.test = [3.5, 4, 4.2, 4.7, 4.8, 4.25]; 
        LIPRAS('push_newbkgd_Callback',testobj,evt,handles);
        testcase.verifyEqual(sort(evt.test), handles.profiles.xrd.getBackgroundPoints);
        end
        
        function numberOfPeaksTest(testcase)
        %NUMBEROFPEAKS
        handles = testcase.hg;
        handles.tabpanel.Selection = 2;
        testobj = handles.edit_numpeaks.JavaPeer;
        evt.test = 5;
        LIPRAS('edit_numpeaks_Callback',testobj,evt,handles);        
        % Number of peaks: uicontrol value == expected value
        testcase.verifyEqual(testobj.getValue, evt.test); 
        % Function names: uicontrol value == handles.gui value
        testcase.verifyLength(handles.table_paramselection.Data(:,1)',evt.test);
        % Function names: handles.gui value == profiles.xrd value
        testcase.verifyLength(handles.gui.FcnNames, evt.test); 
        % Function names: profiles.xrd == 5
        testcase.verifyLength(handles.profiles.xrd.getFunctionNames, evt.test);
        % Constraints: handles.gui value must be empty
        testcase.verifyLength(handles.gui.Constraints, evt.test);
        end
        
        function importParameterFileTest(testcase)
        handles = testcase.hg;
        evt.test = 'Fit_Parameters_355_chi_Series_000_Profile_1.txt';
        evt.path = handles.profiles.OutputPath;
        LIPRAS('menu_parameter_Callback',handles.menu_parameter,evt,handles);
        end
        
        function fitDataSetTest(testcase)
        handles = testcase.hg;
        push_fitdata_Callback(handles.push_fitdata,[],handles);
        end
    end
    
    methods
        
    end
end