function prevConds(app, mode)
% This may replace is fitDirty




if strcmp(mode,'set') % sets initial selected fxns and constraints
    app.CheckBox0=[fliplr([app.ConstraintsPanel.Children.Value]) app.AsymmetryCheckBox.Value]; % Checkboxes

    app.Fxn0=app.UITable.Data;

elseif strcmp(mode,'update')

    if sum(m)>0 % for when checkboxes are checked
    app.prevCondsChanged=1;
    end

end

end