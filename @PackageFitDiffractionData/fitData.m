function fitData(Stro, ~, ~, ~, ~, ~, handles)
Stro.getBackground();
Stro.fit_results={};
Stro.fit_parms={};
Stro.fit_parms_error={};

% 	Stro.PeakPositions = position;
% Stro.PSfxn = PSfxn;
% 
% if nargin > 3
%     Stro.fit_initial = {SP1;UB1;LB1};
% end

datainMin = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Min2T);
datainMax = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Max2T);

data = Stro.data_fit(:,datainMin:datainMax); %Extract relevant 2theta region
TwT = Stro.two_theta(datainMin:datainMax); %Extract relevant 2theta region

%create arbitrary axis for plotting of data
arb = 1:1:size(Stro.data_fit,1); %here

[~,~]=meshgrid(TwT,arb);

% Arbgridsum=arb;
% datasum=data;
g=Stro.makeFunction(Stro.PSfxn);


for i=1:length(Stro.Filename) %this is the start of the for loop that executes the remainder of the
    Stro.Status=['Fitting ', Stro.Filename{1},': Dataset ',num2str(i),' of ',num2str(length(Stro.Filename)),'... '];
    
    if handles.radio_stopleastsquares.Value==1
        Stro.Status=[Stro.Status,'Stopped.'];
        break
    end
    
    %this is the primary function
    if size(Stro.PSfxn,1)==size(Stro.PeakPositions,1)
        datasent = Stro.getRawData(i, Stro.fitrange);
        
        Stro.fitXRD(datasent, Stro.PeakPositions, i, handles,g);
        
        % Master File, writes all Fmodel results into one file
        fitOutputPath = strcat(Stro.OutputPath,'FitData/');
        
        if ~exist(fitOutputPath,'dir')
            mkdir(fitOutputPath);
        end
        
        if isempty(Stro.SPR_Angle)
            filetosave=strcat(fitOutputPath,strrep(Stro.Filename{1},'.','_'),'_Master','_peak',num2str(1),'_Profile_',num2str(handles.guidata.currentProfile),'.Fmodel');
        else
            filetosave=strcat(fitOutputPath,strrep(Stro.Filename{1},'.','_'),'_Angle_',num2str(Stro.SPR_Angle),'_Master','_peak',num2str(1),'_Profile_',num2str(handles.guidata.currentProfile),'.Fmodel');
        end
        
        if i==1  %only if first file to open (master loop); print file header
            fid = fopen(filetosave,'w');
            fprintf(fid, 'This is an output file from a MATLAB routine.\n');
            fprintf(fid, strcat('The following peaks are all of the type: ', Stro.PSfxn{:}, '\n'));
            for j=1:length(Stro.Fcoeff{1})
                fprintf(fid, '%s\t', char(Stro.Fcoeff{1}(j))); %write coefficient names
            end
            p=fieldnames(Stro.FmodelGOF{i})';
            fprintf(fid, '%s\t',p{:}); %write GOF names
            for j=1:size(Stro.FmodelCI{i,1},2)
                fprintf(fid, '%s\t', strcat('LowCI:',char(Stro.Fcoeff{1}(j)))); %write LB names
                fprintf(fid, '%s\t', strcat('UppCI:',char(Stro.Fcoeff{1}(j)))); %write UB names
            end
            fprintf(fid, '\n');
            fclose(fid);
        end
        fid = fopen(filetosave,'a');
        for j=1:length(Stro.Fcoeff{1})
            fprintf(fid, '%#.5g\t', Stro.Fmodel{i,1}.(Stro.Fcoeff{1}(j))); %write coefficient values
        end
        %                             GOFoutputs=[Stro.FmodelGOF{i,m}.sse Stro.FmodelGOF{i,m}.rsquare Stro.FmodelGOF{i,m}.dfe Stro.FmodelGOF{i,m}.adjrsquare Stro.FmodelGOF{i,m}.rmse];
        a=struct2cell(Stro.FmodelGOF{i,1});
        fprintf(fid, '%#.5g\t',[a{:}]); %write GOF values
        for j=1:size(Stro.FmodelCI{i,1},2)
            fprintf(fid,'%#.5g\t', Stro.FmodelCI{i,1}(1,j)); %write lower bound values
            fprintf(fid,'%#.5g\t', Stro.FmodelCI{i,1}(2,j)); %write upper bound values
        end
        fprintf(fid, '\n');
        fclose(fid);
        % End of Master File
        
    else  %else statement for primary function
        errordlg('Number of inputs are not consistent. Program not executed')
    end   %end of if fxn executing primary program
    
    for iii = 1:size(Stro.Fmodel, 2)
        Stro.fit_parms{i,iii} = coeffvalues(Stro.Fmodel{i,iii});
        Stro.fit_parms_error{i,iii} = 0.5*(Stro.FmodelCI{i,iii}(2,:) - Stro.FmodelCI{i,iii}(1,:));
    end
    
    if i~=length(Stro.Filename) && Stro.recycle_results
        Stro.fit_initial{1,i+1}=Stro.fit_parms{i};
    end
    
    Stro.fit_results{i} = Stro.Fdata;
    
end

Stro.Status = 'Fitting dataset... Done.';

% Writes Fmodel and Fdata, after the fitting has been completed
for g=1:length(Stro.Filename)
    
    if isa(Stro.Filename,'char')
        [~, filename, ~] = fileparts(Stro.Filename);
    elseif length(Stro.Filename) == 1
        [~, filename, ~] = fileparts(Stro.Filename{1});
    else
        [~, filename, ~] = fileparts(Stro.Filename{g});
    end
    
    % Writes individual Fdata
    Stro.SaveFitData(strcat(fitOutputPath,filename,'_Profile_',num2str(handles.guidata.currentProfile),'_',num2str(arb(g)),'.Fdata'),Stro.fit_results{g});
    
    Fmodel=Stro.Fmodel(g);
    Fcoeff=Stro.Fcoeff(1);
    FmodelGOF=Stro.FmodelGOF(g);
    FmodelCI=Stro.FmodelCI(g);
    % Writes individual Fmodel
    Stro.SaveFitValues(strcat(fitOutputPath,filename,'_Profile_',num2str(handles.guidata.currentProfile),'_',num2str(arb(g)),'.Fmodel'),Stro.PSfxn,Fmodel,Fcoeff,FmodelGOF,FmodelCI);
    
end
