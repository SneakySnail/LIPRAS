function fcnList = CheckForNonStandDependencies(fcnName)

fcnList = matlab.codetools.requiredFilesAndProducts(fcnName,'toponly');
listIndex = strmatch('C:\Program Files\MATLAB\',fcnList);
fcnList = fcnList(setdiff(1:numel(fcnList),listIndex));