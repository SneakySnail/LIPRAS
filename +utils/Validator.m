classdef Validator < handle
%VALIDATOR ensures that the inputted data in the GUI will always return a valid output. It controls 
%   the data flow between the View (handles.gui) and the Model (handles.profiles). It does NOT 
%   update the View or the Model and only returns the values that should be saved.
   properties
      gui      % View
      profiles % Model
   end
    
    properties (Hidden, Dependent)
       hg
    end
   
    properties (Hidden)
        hg_
    end
   
   methods
       function this = Validator(handles)
       this.hg_ = handles;
       this.gui = handles.gui;
       this.profiles = handles.profiles;
       end
       
       function validMin = min2T(this, newMin)
       % If NEWMIN is specified, it checks whether or not it is a valid minimum 2theta. If it is a
       % valid value, it returns the same value. If not, it returns the previous value.
       if nargin < 2
           newMin = this.gui.Min2T;
       end
       msgPrefix = '<html><font color="red">';
       oldMin = this.profiles.xrd.Min2T;
       if isnan(newMin)
           newMin = oldMin;
           this.hg.statusbarObj.setText([msgPrefix 'Not a valid number.']);
       end
       boundswarnmsg = [msgPrefix 'The inputted value is not within bounds.'];
       if newMin < this.profiles.xrd.AbsoluteRange(1)
           newMin = this.profiles.xrd.AbsoluteRange(1);
           this.hg.statusbarObj.setText(boundswarnmsg);
       elseif newMin > this.profiles.xrd.Max2T
           newMin = oldMin;
           this.hg.statusbarObj.setText(boundswarnmsg);
       end
       validMin = newMin;
       end
       
       function validMax = max2T(this, newMax)
       % Same as min2T (see above), but for the maximum 2theta.
       if nargin < 2
           newMax = this.gui.Max2T;
       end
       msgPrefix = '<html><font color="red">';
       oldMax = this.profiles.xrd.Max2T;
       if isnan(newMax)
           newMax = oldMax;
           this.hg.statusbarObj.setText([msgPrefix 'Not a valid number.']);
       end
       boundswarnmsg = [msgPrefix 'The inputted value is not within bounds.'];
       if newMax < this.profiles.xrd.Min2T
           newMax = oldMax;
           this.hg.statusbarObj.setText(boundswarnmsg);
       elseif newMax > this.profiles.xrd.AbsoluteRange(2)
           newMax = this.profiles.xrd.AbsoluteRange(2);
           this.hg.statusbarObj.setText(boundswarnmsg);
       end
       validMax = newMax;
       end
       
       function bkgdpoints = backgroundPoints(this, points)
       %backgroundPoints returns points within the 2 theta range. Ensures that if the user changes
       %    the two theta range after already selecting background points, only the points within 
       %    range are used. 
       bkgdpoints = [];
       if nargin < 2
           points = this.profiles.xrd.getBackgroundPoints;
       end
       if isempty(points)
           return
       end
       twotheta = this.profiles.xrd.getTwoTheta;
       bkgdIdx = points>min(twotheta) & points<max(twotheta);
       bkgdpoints = points(bkgdIdx);
       end
       
       function fitinitial = fitBounds(this)
       %FITBOUNDS returns valid fit initial values
       %    if there were previous values in the table with the same coefficient name as the new
       %    coefficients, then it uses those values instead of the default ones. If the cell is
       %    empty, it returns a value of -1 for that cell position. The GUIController
       newCoeffs = this.profiles.xrd.getCoeffs;
       oldCoeffs = this.gui.Coefficients;
       defaultVals.start = this.profiles.xrd.getDefaultBounds('start');
       defaultVals.lower = this.profiles.xrd.getDefaultBounds('lower');
       defaultVals.upper = this.profiles.xrd.getDefaultBounds('upper');
       oldVals = this.gui.FitInitial;
       newVals = struct('coeffs', {newCoeffs}, ...
           'start',-ones(1,length(newCoeffs)),...
           'lower',-ones(1,length(newCoeffs)),...
           'upper',-ones(1,length(newCoeffs)));
       for i=1:length(newCoeffs)
           oldCoeffIdx = find(utils.contains(oldCoeffs,newCoeffs{i}),1);
           if isempty(oldCoeffIdx)
               newVals.start(i) = defaultVals.start(i);
               newVals.lower(i) = defaultVals.lower(i);
               newVals.upper(i) = defaultVals.upper(i);
           else
               newVals.start(i) = oldVals.start(oldCoeffIdx);
               newVals.lower(i) = oldVals.lower(oldCoeffIdx);
               newVals.upper(i) = oldVals.upper(oldCoeffIdx);
           end
       end
       fitinitial = newVals;
       end
       
       function coeffValue = startPoint(this, coeffName, input)
       % Ensures that the value specified by INPUT is within the fit bounds for the coefficient
       %    specified by COEFFNAME. It checks the values using the Model (i.e.
       %    handles.profiles.xrd) rather than the View (handles.gui).
       statPref = '<html><font color="red">';
       coeffs = this.profiles.xrd.getCoeffs;
       fitInitial = this.profiles.xrd.FitInitial;
       row = find(strcmp(coeffs, coeffName),1);
       previousValue = fitInitial.start(row);
       lowerBound = fitInitial.lower(row);
       upperBound = fitInitial.upper(row);
       if isnan(input)
           coeffValue = previousValue;
           this.profiles.Status = [statPref 'Not a valid number'];
       elseif input == -1
           coeffValue = input;
           this.profiles.Status = [statPref 'Value for ' coeffName ' was set to empty.'];
       elseif input < lowerBound
           coeffValue = lowerBound;
           this.profiles.Status = [statPref 'Value must be >= the lower bound.'];
       elseif input > upperBound
           coeffValue = upperBound;
           this.profiles.Status = [statPref 'Value must be <= the lower bound.'];
       else
           coeffValue = input;
       end
       end
       
       function coeffValue = lowerBound(this, coeffName, input)
       statPref = '<html><font color="red">';
       coeffs = this.profiles.xrd.getCoeffs;
       fitInitial = this.profiles.xrd.FitInitial;
       row = find(strcmp(coeffs, coeffName),1);
       startPoint = fitInitial.start(row);
       previousValue = fitInitial.lower(row);
       if isnan(input) 
           coeffValue = previousValue;
           this.profiles.Status = [statPref 'Not a valid number'];
       elseif input == -1
           coeffValue = input;
           this.profiles.Status = [statPref 'Value for ' coeffName ' was set to empty.'];
       elseif input > startPoint
           coeffValue = startPoint;
           this.profiles.Status = [statPref 'Value must be <= the coefficient starting point.'];
       else
           coeffValue = input;
       end
       end
       
       function coeffValue = upperBound(this, coeffName, input)
       statPref = '<html><font color="red">';
       coeffs = this.profiles.xrd.getCoeffs;
       fitInitial = this.profiles.xrd.FitInitial;
       row = find(strcmp(coeffs, coeffName),1);
       startPoint = fitInitial.start(row);
       previousValue = fitInitial.upper(row);
       if isnan(input)
           coeffValue = previousValue;
           this.profiles.Status = [statPref 'Not a valid number'];
       elseif input == -1
           coeffValue = input;
           this.profiles.Status = [statPref 'Value for ' coeffName ' was set to empty.'];
       elseif input < startPoint
           coeffValue = startPoint;
           this.profiles.Status = [statPref 'Value must be >= the coefficient starting point.'];
       else
           coeffValue = input;
       end
       end
       
       function handles = get.hg(this)
       % Returns an updated handles structure
       handles = guidata(this.hg_.figure1);
       end
   end
end