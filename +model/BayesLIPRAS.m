function [bi, status]=BayesLIPRAS(app, SP, LB, UB, SD, Sig2, Sig2SD, Sig2UB, Sig2LB,iterations, burnin,Naive,Default,BayesBkg)
status.success = false;
status.message = '';

% BayesBkg is 
handles=app;
h=waitbar(0,'Bayesian analysis running...','CreateCancelBtn','delete(gcf)');
fig = ancestor(h,'figure');                 % waitbar figure
fig.Name = 'Bayesian Analysis';             % optional title
fig.Icon = app.figure1.Icon;                    % PNG/JPG/ICO file on path or fullfile(...)

numFile=length(handles.profiles.FitResults{1});
bi.burnin=burnin;
bi.iterations=iterations;

idBkg=sum(contains(app.profiles.FitResults{1}{1}.CoeffNames,'bkg'))+1; % to remove Bkg Coeffs when they will not be in Bayesian analysis

if BayesBkg
                    idBkg=1;
    if any(contains(handles.profiles.FitResults{1}{1}.CoeffNames,'bkg')) % checks to make sure bkg coeffs were refined in LS LIPRAS
    else
        % warndlg('You can only include the background in the Bayesian analysis if you refined it in the least squares portion of LIPRAS. Either uncheck "Include Bkg" or refine the Background in your model')
        bi.fault=1;
        close(h)
        uialert(app.figure1, 'You can only include the Bkg in the Bayesian analysis if you refined it in the least squares portion of LIPRAS. Either uncheck "Include Bkg" or refine the Background in your model', 'Notice'); % handy alert
        status.message = 'Bkg needs to be refined least squares analysis before use in Bayesian';

        return
    end
end

for f=1:numFile
 
% bi.Eqn=formula(handles.profiles.FitResults{1}{f}.Fmodel); % for when to include Bkg in Bayesian
bi.Eqn=handles.profiles.FitResults{1}{f}.eqnStr;
bi.Eqn_noBkg=handles.profiles.xrd.getEqnStr; % use this to avoid bkg included in Bayesian

if BayesBkg==0; bi.Eqn=bi.Eqn_noBkg; end

bi.ntt=handles.profiles.FitResults{1}{f}.TwoTheta;
bi.nttS{f}=bi.ntt;
bi.nint=handles.profiles.xrd.getData(f);
bi.nintS{f}=bi.nint;
% bi.coeff=coeffnames(handles.profiles.FitResults{1}{f}.Fmodel)';
bi.coeff=handles.profiles.FitResults{1}{f}.CoeffNames;

if strcmp(Naive,'on')
bi.SP=handles.profiles.FitResults{1}{f}.CoeffValues;
bi.Err=handles.profiles.FitResults{1}{f}.CoeffError;
bi.m=3;
bi.UB=bi.SP+bi.Err*bi.m;
bi.LB=bi.SP-bi.Err*bi.m;
bi.param_sd=bi.Err/1.96;
app.HTML.HTMLSource='<div align="right"><font size="2" face="Helvetica"><i>Bound multiplier set to 3 for "Auto"</i></font></div>';


if and(any(contains(bi.coeff,'bkg') ), BayesBkg==0)% ignore Bkg coeffs in Bayesian
bi.coeff(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.SP(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.LB(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.UB(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.param_sd(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.Err(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
end

elseif strcmp(Default,'on')

bi.SP=handles.profiles.FitResults{1}{f}.CoeffValues;
bi.Err=handles.profiles.FitResults{1}{f}.CoeffError;
bi.m=1; % If you increase this, change the default value LBUB goes to before running BayesLIPRAS
bi.UB=bi.SP+bi.Err*1;
bi.LB=bi.SP-bi.Err*1; % changed from multiplier so user uses custom button
bi.param_sd=bi.Err/2;  % changed from multiplier so user uses custom button
app.UITable4.Data=[bi.SP' bi.LB' bi.UB' bi.param_sd'];


if and(any(contains(bi.coeff,'bkg') ),BayesBkg==0)% ignore Bkg coeffs in Bayesian
bi.coeff(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.SP(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.LB(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.UB(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.param_sd(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
bi.Err(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
app.UITable4.Data=[bi.SP' bi.LB' bi.UB' bi.param_sd']; % snip again if they are introduced above

end
    
else
    bi.SP=SP;
    bi.UB=UB;
    bi.LB=LB;
    bi.param_sd=SD;
    bi.Err = handles.profiles.FitResults{1}{f}.CoeffError;

    if and(any(contains(bi.coeff,'bkg') ),BayesBkg==0)% ignore Bkg coeffs in Bayesian
    bi.coeff(1:handles.profiles.xrd.getBackgroundOrder+1)=[];
    end
end

if any(isnan(bi.Err))
bi.Err(isnan(bi.Err))=.01;
disp('Fixed NaN in Err')
end 

bi.coeffOrig=bi.coeff;
Fxn=bi.Eqn;
Fxn=strrep(Fxn,'*','.*');
Fxn=strrep(Fxn,'^','.^');
Fxn=strrep(Fxn,'/','./');
bb=strcat(bi.coeff,',');
coeff=strcat(bb{:});
jp=strcat('@(', coeff,'xv) ');

FxnF = str2func([jp Fxn]);
xv=bi.ntt;

if strcmp(Naive,'on')
    if any(contains(handles.profiles.FitResults{1}{1}.CoeffNames,'bkg') )% ignore Bkg coeffs in Bayesian
    calc=handles.profiles.FitResults{1}{f}.FData;
    else
    calc=handles.profiles.FitResults{1}{f}.FData+handles.profiles.FitResults{1}{f}.Background;
    end
bi.sigma2 = std((bi.nint-calc))^2;
bi.sigma2sd = sqrt(bi.sigma2)*4;
bi.sigma2ub= prctile(std([bi.nint; calc],0,1),95)^2;
bi.sigma2lb= prctile(std([bi.nint; calc],0,1),5)^2;
else
    bi.sigma2 = Sig2;
    bi.sigma2sd = Sig2SD;
    bi.sigma2ub= Sig2UB;
    bi.sigma2lb= Sig2LB;
end

acc=zeros(length(bi.SP),1); % need to reset for every file
accS=0;

param=bi.SP; % load SP for file, this will change when Bayesian switches to new file

if f==1
acc=zeros(length(bi.SP),1);
logp_trace=cell(bi.iterations,numFile);
param_trace = cell(bi.iterations, numFile);
sigma2_trace = cell(bi.iterations, numFile);
fit_trace = cell(bi.iterations-bi.burnin, numFile);
logp=zeros(bi.iterations,1);
logp_new=zeros(bi.iterations,1);
ob_count = zeros(length(param),1); % counter when random parameters are out of bound
num_var=length(param);
sigma2Orig=bi.sigma2;
end

Bkg=handles.profiles.FitResults{1}{f}.Background;
if BayesBkg==1;Bkg=0;end

for RBay=1:1 % for future release, allow repetitions of Bayesian analysis
    if RBay>1
    param=[p1.mu p2.mu p3.mu p4.mu p5.mu p6.mu p7.mu p8.mu];
    param_sd=[p1.sigma p2.sigma p3.sigma p4.sigma p5.sigma p6.sigma p7.sigma p8.sigma];
    end
tic
for i=1:bi.iterations
        inp=[num2cell(param,1) {xv}];
        fit_total=FxnF(inp{:});
        fit_total=fit_total(1,:);
        logp(i)=LogLike(bi.nint, fit_total(1,:)+Bkg,bi.sigma2);
%% Cycle Through Indiv. Params 
    for j=1:num_var
        param_new= param;
            rand_param = param(j) + bi.param_sd(j) * randn; % No Statistic Toolbox
            if rand_param>bi.UB(j) || rand_param<bi.LB(j) % check to make sure they are within the UB and LB
                ob_count(j)=ob_count(j)+1; % counts how many times parameters are generated outside UB and LB
                prob=1E-100; % sets Prob to zero 
            else
            param_new(j)=rand_param;   % Newly generated parameter substitutes into array of parameters that describe the model       
            inp_new=[num2cell(param_new,1) {xv}]; % Formatting for vectorization
            fit_total_new=FxnF(inp_new{:}); % Computes the model for all 2theta values
            fit_total_new=fit_total_new(1,:);
            logp_new(i)=LogLike(bi.nint, fit_total_new(1,:)+Bkg, bi.sigma2); % calculates loglikelihood using MATLAB's pdf function using 'Normal' distribution
            prob=min(exp(logp_new(i)-logp(i)),1); % calculate probability, 
            end
    r=rand(1); % generate random number
    if r<=prob %  accepts the new parameters
    param=param_new;
    fit_total=fit_total_new;
    logp(i)=logp_new(i); % store calculated loglikelihood 
    if i>=bi.burnin
    acc(j)=acc(j)+1; % acceptance 
    end
    end         
            logp_trace{i,f}=logp(i); % stores loglikelihood into trace of loglikelihood
            param_trace{i,f}=param; % stores params in fit trace
    end % ends the for loop for cycling through each variable in the model
    
%% Draw New Sigma2
Gibbs=app.GibbsSamplingCheckBox.Value;
if Gibbs==1
if BayesBkg==1
    a=0.1; b=0.1;
else
a= sum(sqrt((bi.nint-handles.profiles.FitResults{1}{f}.FData-Bkg).^2)); % needed when bkg was not refined in least-squares because
                                                                                                                                                        % modeled background produce alot of deviation from data
% a=10000;
b=0.1;
end
alpha = a + length(bi.nint)/2;
beta  = b + 0.5 * sum((bi.nint - fit_total_new).^2);

bi.sigma2_new = invgamma_rnd(alpha, beta); % inverse gamma sampling for Gibbs "

else
bi.sigma2_new = bi.sigma2 + bi.sigma2sd * randn; %, no toolbox, new sigma2 from normal distribution with mean(sigma2) and sigma(sigma2sd)
end   
   % autocorrelation, correlation between samples as a function lag (how
   % far apart they are). Have autocorrelation plot for every parameter.
   % calculate of an effective sample size, if its its high its good or
   % close to the number of actual samples you drew
   
if Gibbs==1
        inp_new=[num2cell(param,1) {xv}];  % Formatting for vectorization
        fit_total_new=FxnF(inp_new{:}); % Compute the model with current parameters
        fit_total_new=fit_total_new(1,:);
        logp_new(i)=LogLike(bi.nint, fit_total_new(1,:)+Bkg, bi.sigma2_new);  % calculate Loglikelihood
        prob=min(exp(logp_new(i)-logp(i)),1); % calculate probability
else
    if bi.sigma2_new>bi.sigma2ub || bi.sigma2_new < bi.sigma2lb % checks to insure newly generated variable is withing range 
        ob_count(num_var)=ob_count(num_var)+1;
        prob=1E-100;
    else
        % This is for sigma2 so param is used instead of param_new, param is newly accepted or previously accepted list of params in iteration
        inp_new=[num2cell(param,1) {xv}];  % Formatting for vectorization
        fit_total_new=FxnF(inp_new{:}); % Compute the model with current parameters
        fit_total_new=fit_total_new(1,:);
        logp_new(i)=LogLike(bi.nint, fit_total_new(1,:)+Bkg, bi.sigma2_new);  % calculate Loglikelihood
        prob=min(exp(logp_new(i)-logp(i)),1); % calculate probability
    end
end
if Gibbs==1;prob=1;end % so it always accepts
  
r=rand(1); % generate random number 
if r<=prob % accepts sigma2 if prob is greater than or equal to r
bi.sigma2=bi.sigma2_new;
fit_total=fit_total_new;
logp(i)=logp_new(i);
    if i>=burnin
    accS=accS+1;
    end
end
       
sigma2_trace{i,f}=bi.sigma2; % store sigma2

if i>bi.burnin
    fit_trace{i-bi.burnin,f}=fit_total(1,:); % stores fit_trace after burnin has been met
end
% Status
if rem(i,1000)==0 
    numera(f)=i;
    perc=(sum(numera))/(iterations*numFile)*100;
    try
        waitbar(perc/100,h, sprintf('%s %.2f%%','Bayesian analysis running...',perc),'CreateCancelBtn');
        BD.fault=0;
    catch
        bi.fault=1;
        return
        h=waitbar(perc/100,sprintf('%s %.2f%%','Bayesian analysis running...',perc));
    end
%     disp(i)
end        
end
end

% Timer
et(f)=toc;
toc

atime(f)=(length(handles.profiles.FitResults{1})-f)*mean(et);
disp(['Time left= ',num2str(atime(f)) 'secs']);

% Acceptance Ratio
bi.acc_ratio(:,f) = acc/(bi.iterations-bi.burnin);
bi.accS(:,f)=accS/(bi.iterations-bi.burnin);
% Fit, Error, Sigma
    temp1=fit_trace(:,f);
    temp2=cell2mat(temp1);
    bi.fit_mean{f}=mean(temp2);
    bi.fit_sigma{f} =std(temp2); % this assumes a normal distributon for resulting parameters, needs to change
    bi.fit_low{f} = prctile(temp2, 2.5); % takes percentiles to represent std of parameters
    bi.fit_high{f} = prctile(temp2, 97.5); % quantile or prctile work for this
end

for f=1:f
% File Writer
filess=handles.gui.FileNames{f};
nf=strsplit(filess,'.');
nfs{f}=nf{1};
       if handles.profiles.UniqueSave
              index = 0;
            iprefix = '00';
            while exist(strcat(handles.profiles.OutputPath,'Fit_',strcat(iprefix,num2str(index))),'dir') ==7
                index = index + 1;
                if index > 100
                    iprefix = '';
                elseif index > 10
                    iprefix = '0';
                end
            end
            outpath=strcat(handles.profiles.OutputPath,'Bayes_Fit_',strcat(iprefix,num2str(index-1)), filesep);  
            mkdir(outpath)
       else
            outpath = [handles.profiles.OutputPath 'FitData' filesep];
            if exist(outpath,'dir')==0 % incase user deletes this folder
                mkdir(outpath)
            end
       end
masterfilename1= [outpath nf{1} '_Bayesian_Param_Trace' '.Bayes'];
masterfilename2= [outpath nf{1} '_Bayesian_LogP_Sigma2_Trace' '.Bayes'];
masterfilename3= [outpath nf{1} '_Bayesian_Fit_Mean_Error_Sigma' '.Bayes'];

fidmaster1 = fopen(masterfilename1, 'w');
       fprintf(fidmaster1,'%s\t', bi.coeffOrig{:});
       fprintf(fidmaster1, '\n');

fidmaster2 = fopen(masterfilename2, 'w');
    fprintf(fidmaster2, 'LogLikelihood Trace\t Sigma Trace \n');
    
fidmaster3 = fopen(masterfilename3, 'w');
    fprintf(fidmaster3, '2-theta \t Fit Mean\t Fit High\t Fit Low\t Sigma \n');

       for i=1:length(param_trace)
           % Param_trace
           line = param_trace{i,f};
           fprintf(fidmaster1, '%2.8f\t', line(:));
           fprintf(fidmaster1, '\n');
           % Likelihood trace
           line2 = [logp_trace{i,f} sigma2_trace{i,f}];
           fprintf(fidmaster2, '%2.8f\t', line2(:));
           fprintf(fidmaster2, '\n');            
       end
       
       for o=1:length(bi.fit_mean{f})
                       % Fit trace
           line3 = [bi.nttS{f}(o) bi.fit_mean{f}(o) bi.fit_high{f}(o) bi.fit_low{f}(o) bi.fit_sigma{f}(o)];
           fprintf(fidmaster3, '%2.8f\t', line3(:));
           fprintf(fidmaster3, '\n');   
       end
       
fclose('all');

obs=bi.nintS{f};
Bkg=handles.profiles.FitResults{1}{f}.Background;
if BayesBkg==1;Bkg=0;end

calc=bi.fit_mean{f}+Bkg;

Rp(f)=sum(abs(obs-calc))/sum(obs)*100; % caculate a goodness-of-fit value, the lower the better
w{f}=handles.profiles.FitResults{1}{f}.LSWeights;
Rwp(f)=sqrt(sum(w{f}'.*(obs-calc).^2)/sum(w{f}'.*(obs).^2))*100; % caculate a goodness-of-fit value, the lower the better
fprintf('%s %.4f %s\n','LSRp=',handles.profiles.FitResults{1}{f}.Rp,'%')
fprintf('%s %.4f %s\n','BayesRp=',Rp(f),'%')
end

bi.param_trace=reshape(cell2mat(param_trace), [i, j, f]);
bi.sigma2_trace=reshape(cell2mat(sigma2_trace), [i, 1, f]);
bi.logp_trace=reshape(cell2mat(logp_trace), [i, 1 , f]);
bi.numFile=numFile;
bi.idBkg=idBkg;
bi.Rp=Rp;
bi.Rwp=Rwp;
bi.fault=0;
bi.sigma2=sigma2Orig; % this is so the sigma2 value that was used as a starting parameter is not erased in edit box
close(h)
status.success = true;

end

function [logp] = LogLike(nint,fit_total,sigma)
    sd=sqrt(sigma);
    logp = sum( -0.5*log(2*pi) - log(sd) - 0.5 * ((nint - fit_total)./sd).^2 ); % Removed dependency from Statistics Toolbox
end

function x = invgamma_rnd(alpha, beta, sz)
% invgamma_rnd  Sample from inverse gamma without Statistics Toolbox
%
%   x = invgamma_rnd(alpha, beta) returns a single inverse‐gamma random sample.
%   x = invgamma_rnd(alpha, beta, [m,n,...]) returns an array of that size.
%
%   alpha = shape > 0
%   beta  = scale > 0

    if nargin < 3
        sz = [1,1];
    end

    % sample gamma
    % use Marsaglia and Tsang's method for gamma
    x = zeros(sz);
    for idx = 1:numel(x)
        a = alpha;
        d = a - 1/3;
        c = 1 / sqrt(9*d);

        while true
            % normal proposal
            Z = randn();
            V = (1 + c*Z)^3;
            if V > 0
                U = rand();
                if U < 1 - 0.0331*Z^4 || log(U) < 0.5*Z^2 + d*(1-V+log(V))
                    break
                end
            end
        end
        gamma_sample = d * V;  % this is ~Gamma(alpha,1)

        % scale by beta
        gamma_sample = gamma_sample / beta;

        % inverse
        x(idx) = 1/gamma_sample;
    end
end
