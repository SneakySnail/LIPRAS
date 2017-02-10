classdef LiprasConstraintsTest < matlab.unittest.TestCase
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hg
        xrd
        gui
    end
    
    properties (MethodSetupParameter)
%     fcns = {'Gaussian', 'Lorentzian', 'Pearson VII', 'Pseudo-Voigt', 'Asymmetric Pearson VII'};
    end
    
    properties (TestParameter)
        functionName = {'Gaussian', 'Lorentzian', 'Pearson VII', 'Pseudo-Voigt', 'Asymmetric Pearson VII'};
        coeff = {'N', 'x', 'f', 'w', 'm'};
        numfcns = num2cell(1:5);
        currentfcn = num2cell(1:5);

    end
    
    methods (TestClassSetup) %  % functions that run before every test method
        function testClassSetup(testcase)
        testcase.gui.NumPeaks = 0;
        LIPRAS('edit_numpeaks_Callback',testcase.hg.edit_numpeaks.JavaPeer,struct('test',2),testcase.hg);
        end
    end
    
    methods (TestMethodSetup)
        function setupPeakNumber(testcase, fcns)
        % sets up the GUI to have the number of peaks equal to NUMFCNS and the selected functions 
        evt.test = 2;
        LIPRAS('edit_numpeaks_Callback',testcase.hg.edit_numpeaks.JavaPeer,evt,testcase.hg);
        testcase.verifyEqual(testcase.gui.NumPeaks,evt.test);
        testcase.verifyEqual(testcase.xrd.NumFuncs,evt.test);
        for i=1:evt.test
            LIPRAS('table_paramselection_CellEditCallback',testcase.hg.table_paramselection, ...
                struct('Indices', [i 1], 'test', 'Gaussian'), ...
                testcase.hg);
        end
        end
    end
    
    methods (TestMethodTeardown)
%         function teardownNumberOfPeaks(testcase)
%         evt.test = 5;
%         testcase.gui.FcnNames = cell(1,5);
%         LIPRAS('edit_numpeaks_Callback',testcase.hg.edit_numpeaks.JavaPeer,evt,testcase.hg);
%         end
    end
       
    
    methods (Test)
        function testEnabledConstraintsInPanel(testcase, currentfcn, functionName)
        %TESTENABLEDCONSTRAINTSINPANEL vverifies that the enabled checkboxes in the GUI matches the
        %   coeffnames of a combination of functions. 
        %
        %   Assumes that handles.gui works correctly.
        evt = struct('Indices', [currentfcn 1], 'test', functionName);
        LIPRAS('table_paramselection_CellEditCallback',testcase.hg.table_paramselection,evt,testcase.hg);
        testcase.verifyEqual(testcase.gui.FcnNames,testcase.xrd.getFunctionNames);
        end
    end
end

