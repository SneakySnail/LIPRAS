function fitData(Stro, handles)

Stro.fit_results={};
Stro.fit_parms={};
Stro.fit_parms_error={};

fitOutputPath = '';
profiledata = handles.cfit(handles.guidata.currentProfile);


%create arbitrary axis for plotting of data
arb = 1:1:size(Stro.data_fit,1); %here

g = Stro.makeFunction(Stro.PSfxn);

% Execute on remainder of files
for i=1:length(Stro.Filename)
    if handles.radio_stopleastsquares.Value==1
        Stro.Status=[Stro.Status,'Stopped.'];
        break
    end
    Stro.Status=['Fitting ', Stro.Filename{1},': Dataset ',num2str(i),' of ',num2str(length(Stro.Filename)),'... '];
    fitSingleFile(i);
end

linkaxes([handles.axes1 handles.axes2],'x')
axes(handles.axes1) % this is slow, consider moving outside of loop


% Writes Fmodel and Fdata, after the fitting has been completed
for i=1:length(Stro.Filename)
    
    if isa(Stro.Filename,'char')
        [~, filename, ~] = fileparts(Stro.Filename);
    elseif length(Stro.Filename) == 1
        [~, filename, ~] = fileparts(Stro.Filename{i});
    else
        [~, filename, ~] = fileparts(Stro.Filename{i});
    end
    
    % Writes individual Fdata
    Stro.SaveFitData(strcat(fitOutputPath,filename,'_Profile_',num2str(handles.guidata.currentProfile),'_',num2str(arb(i)),'.Fdata'),Stro.fit_results{i});
    
    Fmodel=Stro.Fmodel(i);
    Fcoeff=Stro.Fcoeff(1);
    FmodelGOF=Stro.FmodelGOF(i);
    FmodelCI=Stro.FmodelCI(i);
    % Writes individual Fmodel
    Stro.SaveFitValues(strcat(fitOutputPath,filename,'_Profile_',num2str(handles.guidata.currentProfile),'_',num2str(arb(i)),'.Fmodel'),Stro.PSfxn,Fmodel,Fcoeff,FmodelGOF,FmodelCI);
    
end



    function fitSingleFile(iFile)
    
    %this is the primary function
    datasent = profiledata.Data;
    
    Stro.fitXRD(datasent, iFile, handles, g);
    
    % Master File, writes all Fmodel results into one file
    fitOutputPath = strcat(Stro.OutputPath,'FitData/');
    
    if ~exist(fitOutputPath,'dir')
        mkdir(fitOutputPath);
    end
    
    
    if isempty(Stro.SPR_Angle)
        filetosave=strcat(fitOutputPath,strrep(Stro.Filename{1},'.','_'),'_Master','_peak',num2str(1),'_Profile_',num2str(handles.guidata.currentProfile),'.Fmodel');
    else
        % Move to inherited class for SPR ======================================
        filetosave=strcat(fitOutputPath,strrep(Stro.Filename{1},'.','_'),'_Angle_',num2str(Stro.SPR_Angle),'_Master','_peak',num2str(1),'_Profile_',num2str(handles.guidata.currentProfile),'.Fmodel');
    end
    
    if iFile == 1  %only if first file to open (master loop); print file header
        fid = fopen(filetosave,'w');
        fprintf(fid, 'This is an output file from a MATLAB routine.\n');
        fprintf(fid, strcat('The following peaks are all of the type: ', profiledata.FcnNames{:}, '\n'));
        for j=1:length(profiledata.Coefficients)
            fprintf(fid, '%s\t', char(profiledata.Coefficients(j))); %write coefficient names
        end
        
        p=fieldnames(Stro.FmodelGOF{iFile})';
        fprintf(fid, '%s\t',p{:}); %write GOF names
        for j=1:size(Stro.FmodelCI{iFile,1},2)
            fprintf(fid, '%s\t', strcat('LowCI:',char(profiledata.Coefficients(j)))); %write LB names
            fprintf(fid, '%s\t', strcat('UppCI:',char(profiledata.Coefficients(j)))); %write UB names
        end
        fprintf(fid, '\n');
        fclose(fid);
    end
    fid = fopen(filetosave,'a');
    for j=1:length(profiledata.Coefficients)
        fprintf(fid, '%#.5g\t', Stro.Fmodel{iFile}); %write coefficient values
    end
    %                             GOFoutputs=[Stro.FmodelGOF{i,m}.sse Stro.FmodelGOF{i,m}.rsquare Stro.FmodelGOF{i,m}.dfe Stro.FmodelGOF{i,m}.adjrsquare Stro.FmodelGOF{i,m}.rmse];
    a=struct2cell(Stro.FmodelGOF{iFile});
    fprintf(fid, '%#.5g\t',[a{:}]); %write GOF values
    for j=1:size(Stro.FmodelCI{iFile}, 2)
        fprintf(fid,'%#.5g\t', Stro.FmodelCI{iFile}(1,j)); %write lower bound values
        fprintf(fid,'%#.5g\t', Stro.FmodelCI{iFile}(2,j)); %write upper bound values
    end
    fprintf(fid, '\n');
    fclose(fid);
    % End of Master File
    
    
    Stro.fit_parms{iFile} = coeffvalues(Stro.Fmodel{iFile});
    Stro.fit_parms_error{iFile} = 0.5*(Stro.FmodelCI{iFile}(2,:) - Stro.FmodelCI{iFile}(1,:));
    
    
    if iFile~=length(Stro.Filename) && Stro.recycle_results
        Stro.fit_initial{1,iFile+1}=Stro.fit_parms{iFile};
    end
    
    Stro.fit_results{iFile} = Stro.Fdata;
    
    end

end
