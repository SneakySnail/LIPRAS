classdef GetCoeffTest < matlab.unittest.TestCase
    %FITTEST Tests the result of fits made using PackageFitDiffractionData.
    %   Detailed explanation goes here
   
    properties
       xrd 
    end
    
    properties (TestParameter)
        fcnNames = {'Gaussian', 'Lorentzian', ...
            'Pearson VII', 'Pseudo Voigt', ...
            'Asymmetric Pearson VII'};
        
        numFcn = struct('single', 1, 'double', 2, ...
            'triple', 3, 'quadruple', 4);
    end
    
     methods(TestMethodSetup)
        function createFitObj(testCase)
            % comment
            addpath('..');
            testCase.xrd = PackageFitDiffractionData;
        end
     end
    
    methods (Test, ParameterCombination = 'sequential')
        
        function testSingleFcnNoConstraints(testCase, fcnNames)
        % Tests the getCoeff method without constraints.
        %   fcn - the function name to test. 
        constraints = zeros(1,5); % test without constraints
        expectedResult = {};
        
        switch fcnNames
            case 'Gaussian'
                expectedResult = {'N1', 'x1', 'f1'};
                
            case 'Lorentzian'
                expectedResult = {'N1', 'x1', 'f1'};
                
            case 'Pearson VII'
                expectedResult = {'N1', 'x1', 'f1', 'm1'};
                
            case 'Pseudo Voigt'
                expectedResult = {'N1', 'x1', 'f1', 'w1'};
                
            case 'Asymmetric Pearson VII'
                expectedResult = {'N1L', 'N1R', 'x1', 'f1', 'm1L', 'm1R'};
                
            otherwise
                
        end
                
        actualResult = testCase.xrd.getCoeff({fcnNames}, constraints);
        
        testCase.verifyEqual(expectedResult, actualResult);
        end
        
        
%         function testDoubleFcnNoConstraints(testCase, numFcn)
%         constraints = zeros(1,5); % test without constraints
%         expectedResult = {};
%         end
        
    end
    
   
        
end

