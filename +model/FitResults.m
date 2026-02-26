classdef FitResults
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        FileName        % Name used when printing out to a file

        ProfileNum 
        
        FunctionNames

        Fmodel
        
        FmodelGOF
        
        LSWeights
        
        Rp
        
        Rwp
        
        Rchi2
        
        FitInfo
        
        FmodelCI

        CovJacobianFit
        
        CoeffNames

        CoeffValues

        CoeffError

        TwoTheta

        Background      % Background fit

        FitInitial      % Struct with fields 'start', 'lower', and 'upper'

        FData           % Numeric array result after fitting TwoTheta with Fmodel

        FPeaks          % Numeric array result of each function's fits
        
        FCuKa2Peaks     % Empty if no Cu-Ka2 
        
        PredictInt % Prediction of model at 95% confidence interval

        eqnStr % Equation string with and without Background
    end
    
    properties
        CuKa = false;
        
        KAlpha1
        
        KAlpha2
    end
    
    
    properties (Hidden) % Because they were used for getting the fit
        BackgroundModel
        
        BackgroundOrder
        
        BackgroundPoints
        
        Intensity       % Raw data
        
        PeakPositions
        
        Constraints
        
        FitOptions
        
        OutputPath

        FitType
        FitFunctions
        CuKa2Functions
    end

properties (Access = protected)
%     FitType
%     FitFunctions

end

properties (Constant)
CONFIDENCE_LEVEL = 0.95;
end
    
    methods
        function this = FitResults(profile, filenumber)
        %FITRESULTS constructor for fitting the data. It saves the fit results and also the fit
        %   parameters that were used.
        %
        %   
        if profile.CuKa
            this.CuKa = true;
            this.CuKa2Functions = profile.xrd.CuKa2Peak;
            this.KAlpha1 = profile.xrd.KAlpha1;
            this.KAlpha2 = profile.xrd.KAlpha2;
        end
        xrd = profile.xrd;
        xrd.CF=profile.CF; % Pass Curve Fitting Toolbox dependency
        this.FileName      = strrep(xrd.getFileNames{filenumber}, '.', '_');
        this.ProfileNum    = profile.getCurrentProfileNumber;
        this.OutputPath    = profile.OutputPath;
        this.FunctionNames = xrd.getFunctionNames;
        this.TwoTheta      = xrd.getTwoTheta(filenumber);
        this.Intensity     = xrd.getData(filenumber);
        if xrd.BkgLS
        else
        this.Background    = xrd.calculateBackground(filenumber);
        end
        this.BackgroundOrder = xrd.getBackgroundOrder;
        this.BackgroundModel = xrd.getBackgroundModel;
        this.BackgroundPoints = xrd.getBackgroundPoints;
        this.PeakPositions = xrd.PeakPositions;
        this.Constraints = xrd.getConstraints;
        [this.FitType,this.eqnStr]       = xrd.getFitType(filenumber);
        this.FitFunctions  = xrd.getFunctions;


% Start of CF Dependency
if profile.CF
        this.CoeffNames    = coeffnames(this.FitType)';

        if and(filenumber>1,xrd.recycle_results==1)
            this.FitOptions    = xrd.getFitOptions(filenumber);
        elseif filenumber==1 && xrd.BkgLS && xrd.recycle_results
            xrd.recycle_results=0;
            this.FitOptions    = xrd.getFitOptions(filenumber);
            xrd.recycle_results=1;
        else
        this.FitOptions    = xrd.getFitOptions(filenumber);
        end
        
        % if strcmp(profile.Weights,'Default') % this is what sets different between default and 1/obs
        %     if ~isempty(profile.Errors)
        %         this.FitOptions.Weights=1./(xrd.DataSet{filenumber}.getDataErrors).^2; % default to 1/sigma^2 when errors are read in or generated upon file read
        %     else
        %         this.FitOptions.Weights=1./xrd.DataSet{filenumber}.getDataIntensity;
        %     end
        % end
        
        if xrd.BkgLS && ~isempty(xrd.BkgCoeff) && filenumber==1 % handling bkgCoeff refined and how they cycle after being refined
            if length(xrd.BkgCoeff)==this.BackgroundOrder+1           % when BkgOrder is switched after a refined bkg has been done    
            this.FitOptions.StartPoint(1:this.BackgroundOrder+1)=xrd.BkgCoeff;            
            end
            
        elseif xrd.BkgLS && ~isempty(xrd.BkgCoeff) && this.BackgroundOrder+1<length(xrd.BkgCoeff) && filenumber==1
            disp('Bkg Order less than Bkg coefficients stored')
        elseif xrd.BkgLS && xrd.recycle_results && ~isempty(xrd.BkgCoeff)
            %Nothing keep it rolling
        end
%         disp(this.FitOptions.StartPoint) % to check SP being recycled

    if any(this.FitOptions.Weights==Inf)
    this.FitOptions.Weights(this.FitOptions.Weights==Inf)=mean(this.FitOptions.Weights(this.FitOptions.Weights~=Inf)); % sets to low value because intensity is low
    end
        
        if xrd.BkgLS
                    [fmodel, fmodelgof, outputMatrix] = fit(this.TwoTheta', ...
                                 (this.Intensity)', ...
                                  this.FitType, this.FitOptions);
        else
        [fmodel, fmodelgof, outputMatrix] = fit(this.TwoTheta', ...
                                 (this.Intensity - this.Background)', ...
                                  this.FitType, this.FitOptions);
        end
        fmodelci = confint(fmodel, this.CONFIDENCE_LEVEL);
        
        this.Fmodel    = fmodel;
        this.FmodelGOF = fmodelgof;
        this.FmodelCI  = fmodelci;
        this.LSWeights=this.FitOptions.Weights';
        this.FitInfo=outputMatrix;
%         this.CovJacobianFit=(this.FitInfo.Jacobian'*this.FitInfo.Jacobian)^(-1)*this.FmodelGOF.rmse^2;
        this.FData       = fmodel(this.TwoTheta)';
        this.FPeaks      = zeros(length(xrd.getFunctions),length(this.FData));
        this.FCuKa2Peaks = zeros(length(xrd.getFunctions),length(this.FData));
        this.CoeffValues = coeffvalues(fmodel);
        this.CoeffError  = 0.5 * (fmodelci(2,:) - fmodelci(1,:));
        this.PredictInt=predint(fmodel,this.TwoTheta,0.95,'functional','on');
        DOF=fmodelgof.dfe;

else
% --------------------------------------------
% REPLACEMENT FOR: fit / confint / predint
% NO TOOLBOX REQUIRED
% --------------------------------------------
        this.FitOptions    = xrd.getFitOptions(filenumber); % should not fail
        % this.CoeffNames=this.FitOptions.coeff; % Needed to be added since original form uses CFT dependency
        this.CoeffNames=this.FitType;
% ---- Select ydata ----
if xrd.BkgLS
    ydata = (this.Intensity)';
else
    ydata = (this.Intensity - this.Background)';
end

this.LSWeights=xrd.w';
W = xrd.w';

% ---- Convert FitType → RHS expression ----

expr = this.eqnStr;           % keep only the right-hand side

% ---- Vectorize operators ----
expr = strrep(expr,'^','.^');
expr = strrep(expr,'*','.*');
expr = strrep(expr,'/','./');

% ---- Replace coefficient names with p(i) ----
for k = 1:numel(this.CoeffNames)
    cname = this.CoeffNames{k};
    expr = regexprep(expr, ...
        ['(?<![A-Za-z0-9_])', cname, '(?![A-Za-z0-9_])'], ...
        sprintf('p(%d)',k));
end

% ---- Construct model function ----
model = str2func(['@(p,xv) ' expr]);
p0 = this.FitOptions.SP;
opts = optimset( ...
    'Display','off', ...
    'MaxIter',5000, ...      % more stable like fit
    'TolX',1e-12, ...
    'TolFun',1e-12);

% ---- Objective: weighted least squares ----
objfun = @(p) sum( ( W .* ( model(p, this.TwoTheta') - ydata ) ).^2 );

        if xrd.ignore_bounds

% ------------------------------------------------------------
% NO BOUNDS OPTION — direct fminsearch using only SP
% ------------------------------------------------------------
    p = fminsearch(objfun, p0, opts);

        else
% ---- Bounds transform (FitOptions are YOUR variables) ----
lb = this.FitOptions.LB;
ub = this.FitOptions.UB;

% ---- Fix invalid bounds ----
    bad = (ub <= lb);
    ub(bad) = lb(bad) + eps;

    % ---- Clamp start point into bounds ----
    p0 = max(p0, lb);
    p0 = min(p0, ub);

    % ---- Safe transform ----
    arg = 2*(p0-lb)./(ub-lb) - 1;
    arg = min(max(arg, -1+1e-12), 1-1e-12);

    % toUnit   = @(p) asin( min(max(2*(p-lb)./(ub-lb)-1, -1+1e-12), 1-1e-12) );
    fromUnit = @(u) lb + (sin(u)+1).*(ub-lb)/2;

    p0u = asin(arg);

    % ---- Solve in transformed space ----
    pu = fminsearch(@(pu)objfun(fromUnit(pu)'), p0u, opts);
    p  = fromUnit(pu);
        end
% --------------------------------------------
% STORE EXACTLY WHAT THE ORIGINAL CODE EXPECTED
% --------------------------------------------

% There is no fmodel (toolbox object), so set empty
this.Fmodel = [];

% Coefficients
this.CoeffValues = p(:)';

% Model prediction
this.FData = model(p, this.TwoTheta')';

% ---- Numeric Jacobian (needed for CI + PI) ----
y0 = model(p, this.TwoTheta');
N = numel(y0);
M = numel(p);

J = zeros(N,M);
eps0 = 1e-6;
for i = 1:M
    dp = zeros(size(p)); dp(i) = eps0* (1 + abs(p(i)));
    yi = model(p+dp, this.TwoTheta');
    J(:,i) = (yi - y0) / eps0;
end

% ---- GOF (replacing fmodelgof) ----
res = y0 - ydata(:);
DOF = N - M;
s2  = sum(res.^2) / DOF;

this.FmodelGOF.sse  = sum(res.^2);
this.FmodelGOF.rmse = sqrt(this.FmodelGOF.sse / N);
this.FmodelGOF.dfe  = DOF;
% ---- R^2 and adjusted R^2 ----
ybar = mean(ydata(:));
SST  = sum((ydata(:) - ybar).^2);

this.FmodelGOF.rsquare = 1 - this.FmodelGOF.sse / SST;
this.FmodelGOF.adjrsquare = 1 - (1 - this.FmodelGOF.rsquare) * (N - 1) / (DOF);

% ---- Confidence intervals (replaces confint) ----
Cov = inv(J.'*J) * s2;
this.CovJacobianFit = Cov;

z = sqrt(2) * erfinv(this.CONFIDENCE_LEVEL);  % ≈ 1.96 for 95%

err = z * sqrt(diag(Cov));
this.CoeffError = err(:)';
this.FmodelCI   = [p(:)-err  p(:)+err];

% ---- Prediction interval (replaces predint) ----
Vp = diag(J*Cov*J.');
delta = z * sqrt(Vp);
yp = this.FData(:);
this.PredictInt = [yp-delta yp+delta];

% ---- Placeholders to match old behavior ----
this.FitInfo = struct('exitflag',[],'output',opts);

this.FPeaks      = zeros(length(xrd.getFunctions), length(this.FData));
this.FCuKa2Peaks = zeros(length(xrd.getFunctions), length(this.FData));
    
%----------End of No toolbox routine--------------
end
    
% Rp, Rwp, and Rchi2 Calculations
    obs=this.Intensity';
    w=this.LSWeights;

    if any(contains(this.CoeffNames,'bkg')) % for when BkgLS is checked
        calc=this.FData'; 
    else
        calc = this.Background' + this.FData';        
    end

    this.Rp = (sum(abs(obs-calc))./(sum(obs))) * 100; %calculates Rp
    this.Rwp = (sqrt(sum(w.*(obs-calc).^2)./sum(w.*obs.^2)))*100;

    % ----------- Chi-square (weighted or unweighted) -----------
    if strcmp(profile.Weights,'None')
        % unweighted χ²
        this.Rchi2 = sum((obs-calc).^2) / DOF;
    else
        % weighted χ²  (W = 1/σ²)
        this.Rchi2 = sum( this.LSWeights .* ((obs-calc).^2) ) / DOF;
    end

        for i=1:length(this.FitFunctions)
             peak = this.calculatePeakFit(i);
             this.FPeaks(i,:) = peak(1,:);
            if this.CuKa
                this.FCuKa2Peaks(i,:) = peak(2,:);
            end
        end
        
        if and(filenumber>1,xrd.recycle_results==1)
        xrd.FitInitial.start=this.CoeffValues;
        elseif filenumber==1 && xrd.BkgLS && xrd.recycle_results
            xrd.FitInitial.start = this.CoeffValues;
        else
            if profile.CF
            this.FitInitial.start = this.FitOptions.StartPoint;
            else
            this.FitInitial.start = this.FitOptions.SP;
            end
        end
        
        if filenumber==xrd.NumFiles && xrd.BkgLS
            xrd.FitInitial.start=this.CoeffValues(xrd.Background.Order+2:end); % fixes the starting values to remove bkg coeffs
        end
        
        if xrd.BkgLS % evaluates Poly Bkg based on refined Bkg Coefficients

           mu=[mean(this.TwoTheta) std(this.TwoTheta)]; % for centering and scaling
           this.Background=polyval(fliplr(this.CoeffValues(1,1:this.BackgroundOrder+1)), this.TwoTheta,[],mu); 
        else
        end
        this.FitInitial.coeffs = this.CoeffNames;
        xrd.CurrentPro=1;
        end
        
        function output = calculateFitNoBackground(this, fcnID)
        %CALCULATEFIT returns an array 
        output = this.FData;
        end

        function output = calculateError(this)
        output = this.FData - this.Intensity;
        end

        function output = calculatePeakFit(this, fcnID)
        % calculatePeakFit  
        twotheta = this.TwoTheta;
        fcnCoeffNames = this.FitFunctions{fcnID}.getCoeffs;
        idx = zeros(1,length(fcnCoeffNames));
        for i=1:length(fcnCoeffNames)
            idx(i) = find(strcmpi(this.CoeffNames, fcnCoeffNames{i}),1);
        end
        coeffvals = this.CoeffValues(idx);
        output = this.FitFunctions{fcnID}.calculateFit(twotheta, coeffvals);
        if this.CuKa
            output(2,:) = this.CuKa2Functions{fcnID}.calculateFit(twotheta,coeffvals);
        end
        end
        end
end

