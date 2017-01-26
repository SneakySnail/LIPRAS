function onPushUpdate(this, profiles)

coeff = profiles.xrd.getCoeffs;

this.Coefficients = coeff;

assignin('base', 'handles', this.hg);
guidata(this.hg.figure1, this.hg)