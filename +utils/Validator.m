classdef Validator < handle
%VALIDATOR ensures that the inputted data in the Model will always return a valid output. It does NOT 
%   update the View or the Model and only returns the values that should be saved.
   properties
       profiles 
       
       xrd
   end
    

    properties (Hidden)
        Message
        
    end
   
   methods
       function this = Validator(profiles, xrd)
       this.profiles = profiles;
       this.xrd = xrd;
       end
       
       function validMin = min2T(this, newMin)
       % If NEWMIN is specified, it checks whether or not it is a valid minimum 2theta. If it is a
       % valid value, it returns the same value. If not, it returns the previous value.
       msgPrefix = '<html><font color="red">';
       oldMin = this.profiles.xrd.Min2T;
       if isnan(newMin)
           newMin = oldMin;
           this.profiles.Status = [msgPrefix 'Not a valid number.'];
       end
       boundswarnmsg = [msgPrefix 'The inputted value is not within bounds.'];
       if newMin < this.profiles.xrd.AbsoluteRange(1)
           newMin = this.profiles.xrd.AbsoluteRange(1);
           this.profiles.Status = boundswarnmsg;
       elseif newMin >= this.profiles.xrd.Max2T
           newMin = oldMin;
           this.profiles.Status = boundswarnmsg;
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
           this.profiles.Status = [msgPrefix 'Not a valid number.'];
       end
       boundswarnmsg = [msgPrefix 'The inputted value is not within bounds.'];
       if newMax <= this.profiles.xrd.Min2T
           newMax = oldMax;
           this.profiles.Status = boundswarnmsg;
       elseif newMax > this.profiles.xrd.AbsoluteRange(2)
           newMax = this.profiles.xrd.AbsoluteRange(2);
           this.profiles.Status = boundswarnmsg;
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
       
       function numpeaks = numberOfPeaks(this, num)
       numpeaks = round(num);
       end
       
       function peakPositions = peakPositions(this, pos)
       % Returns the peak positions within the two theta range.
       peakPositions = [];
       if nargin < 2
           pos = this.profiles.xrd.PeakPositions;
       end
       if isempty(pos)
           return
       end
       
       twotheta = this.profiles.xrd.getTwoTheta;
       posIdx = pos>min(twotheta) & pos<max(twotheta);
       peakPositions = pos(posIdx);
       end
       
       function fitinitial = defaultFitBoundsPreserved(this, newBounds)
       %FITBOUNDS returns valid fit initial values, without replacing values for previously existing
       %    coefficient values.
       %    
       if isempty(this.profiles.FitInitial)
           oldCoeffs = '';
       else
           oldBounds = this.profiles.FitInitial;
           oldCoeffs = oldBounds.coeffs;
           xidx = find(utils.contains(oldBounds.coeffs, 'x'));
           oldBounds.start(xidx) = -1;
           oldBounds.lower(xidx) = -1;
           oldBounds.upper(xidx) = -1;
       end
       numvals = length(newBounds.coeffs);
       fitinitial = struct('coeffs', {newBounds.coeffs}, ...
                           'start', zeros(1,numvals), ...
                           'lower', zeros(1,numvals), ...
                           'upper', zeros(1,numvals));
                       
       for i=1:length(newBounds.coeffs)
           oldCoeffIdx = find(utils.contains(oldCoeffs, newBounds.coeffs{i}),1);
           if isempty(oldCoeffIdx)
               fitinitial.start(i) = newBounds.start(i);
               fitinitial.lower(i) = newBounds.lower(i);
               fitinitial.upper(i) = newBounds.upper(i);
           else
               % Overwrite all negative values
               if oldBounds.start(oldCoeffIdx) < 0
                   fitinitial.start(i) = newBounds.start(i);
               else
                   fitinitial.start(i) = oldBounds.start(oldCoeffIdx);
               end
               if oldBounds.lower(oldCoeffIdx) < 0
                   fitinitial.lower(i) = newBounds.lower(i);
               else
                   fitinitial.lower(i) = oldBounds.lower(oldCoeffIdx);
               end
               if oldBounds.upper(oldCoeffIdx) < 0
                   fitinitial.upper(i) = newBounds.upper(i);
               else
                   fitinitial.upper(i) = oldBounds.upper(oldCoeffIdx);
               end
           end
           % Make sure lower and upper peak position are within range
           if find(utils.contains(newBounds.coeffs{i}, 'x'),1)
               fitinitial.lower(i) = max(fitinitial.lower(i), this.xrd.Min2T);
               fitinitial.upper(i) = min(fitinitial.upper(i), this.xrd.Max2T);
           end
       end
       end
       
       function fitinitial = verifiedFitBounds(this, newBounds)
       fitinitial = newBounds;
       for i=1:length(newBounds.coeffs)
           fitinitial.start(i) = this.startPoint(newBounds.coeffs{i}, newBounds.start(i));
           fitinitial.lower(i) = this.lowerBound(newBounds.coeffs{i}, newBounds.lower(i));
           fitinitial.upper(i) = this.upperBound(newBounds.coeffs{i}, newBounds.upper(i));
       end
       end
       
       function coeffValue = startPoint(this, coeffName, input)
       % Ensures that the value specified by INPUT is within the fit bounds for the coefficient
       %    specified by COEFFNAME. It checks the values using the Model (i.e.
       %    handles.profiles.xrd) rather than the View (handles.gui).
       statPref = ['<html><font color="red">' coeffName '=' num2str(input) ' is not valid. '];
       coeffs = this.profiles.xrd.getCoeffs;
       fitInitial = this.profiles.xrd.FitInitial;
       row = find(strcmp(coeffs, coeffName),1);
       previousValue = fitInitial.start(row);
       lowerBound = fitInitial.lower(row);
       upperBound = fitInitial.upper(row);
       if isnan(input)
           coeffValue = previousValue;
           this.profiles.Status = statPref;
       elseif input == -1
           coeffValue = input;
       elseif input < lowerBound
           coeffValue = lowerBound;
           this.profiles.Status = [statPref 'Must be greater than or equal to the lower bound.'];
       elseif input > upperBound
           coeffValue = upperBound;
           this.profiles.Status = [statPref 'Must be less than or equal to the upper bound.'];
       else
           coeffValue = input;
       end
       end
       
       function coeffValue = lowerBound(this, coeffName, input)
       % Checks that the value specified by INPUT for the coefficient specified by COEFFNAME is
       %    not larger than the start point or upper bound.
       statPref = ['<html><font color="red">' coeffName '=' num2str(input) ' is not valid. '];
       coeffs = this.profiles.xrd.getCoeffs;
       fitInitial = this.profiles.xrd.FitInitial;
       row = find(strcmp(coeffs, coeffName),1);
       startPoint = fitInitial.start(row);
       previousValue = fitInitial.lower(row);
       
       if isnan(input) 
           coeffValue = previousValue;
           this.profiles.Status = statPref;
       elseif input == -1
           coeffValue = input;
       elseif input > startPoint
           coeffValue = startPoint;
           this.profiles.Status = [statPref 'Must be less than or equal to the coefficient starting point.'];
       else
           coeffValue = input;
       end
       end
       
       function coeffValue = upperBound(this, coeffName, input)
       statPref = ['<html><font color="red">' coeffName '=' num2str(input) ' is not valid. '];
       coeffs = this.profiles.xrd.getCoeffs;
       fitInitial = this.profiles.xrd.FitInitial;
       row = find(strcmp(coeffs, coeffName),1);
       startPoint = fitInitial.start(row);
       previousValue = fitInitial.upper(row);
       if isnan(input)
           coeffValue = previousValue;
           this.profiles.Status = statPref;
       elseif input == -1
           coeffValue = input;
       elseif input < startPoint
           coeffValue = startPoint;
           this.profiles.Status = [statPref 'Must be greater than or equal to the coefficient starting point.'];
       else
           coeffValue = input;
       end
       end
       
   end
end