classdef Validator < handle
%VALIDATOR is an implementation of an MVC software design. It controls the data flow between
%   the View (handles.gui) and the Model (handles.profiles). It does NOT update the View or the
%   Model. It only returns values that should be saved.
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
       
       function fitinitial = updatedFitBounds(this)
       %UPDATEFITBOUNDSTABLE updates table_fitinitial on 'Update' button press. It asserts that
       %    if there were previous values in the table with the same coefficient name as the new
       %    coefficients, then it uses those values instead of the default ones.
       newCoeffs = this.profiles.xrd.getCoeffs;
       oldCoeffs = this.gui.Coefficients;
       defaultVals.start = this.profiles.xrd.getDefaultBounds('start');
       defaultVals.lower = this.profiles.xrd.getDefaultBounds('lower');
       defaultVals.upper = this.profiles.xrd.getDefaultBounds('upper');
       oldVals = this.gui.FitInitial;
       newVals = struct('start',zeros(1,length(newCoeffs)),...
           'lower',zeros(1,length(newCoeffs)),...
           'upper',zeros(1,length(newCoeffs)));
       
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
       newVals.coeffs = newCoeffs;
       fitinitial = newVals;
       end
       
       function handles = get.hg(this)
       % Returns an updated handles structure
       handles = guidata(this.hg_.figure1);
       end
   end
end