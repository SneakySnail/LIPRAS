% TODO Move to FDGUIv2_1
function outputError(Stro,Profile)


% Move SPR Angle to different class with inherited properties
% 			outFilePrefix = strcat(Stro.OutputPath,'Fit_Parameters_',strrep(Stro.Filename{1},'.','_'),'_Angle_',num2str(Stro.SPR_Angle),'_');
% outFilePrefix = strcat(Stro.OutputPath,'Fit_Parameters_',strrep(Stro.Filename{1},'.','_'),'_Series_Angle_',num2str(Stro.SPR_Angle),'_');

if isa(Stro.Filename,'char')
    Stro.Filename = {Stro.Filename};
end

if ~exist( Stro.OutputPath, 'dir' )
    mkdir( Stro.OutputPath );
end

outFilePrefix = strcat(Stro.OutputPath,'Fit_Parameters_',strrep(Stro.Filename{1},'.','_'),'_');

if length(Stro.Filename) > 1
    outFilePrefix = [outFilePrefix 'Series_'];
end

index = 0;
iprefix = '00';

while exist(strcat(outFilePrefix,strcat(iprefix,num2str(index)),'_Profile_',num2str(Profile.id),'.txt'),'file') == 2
    index = index + 1;
    if index > 100
        iprefix = '';
    elseif index > 10
        iprefix = '0';
    end
end

fid=fopen(strcat(outFilePrefix,strcat(iprefix,num2str(index)),'_Profile_',num2str(Profile.id),'.txt'),'w'); %the name of the file it will write containing the statistics of the fit

% File info
%TODO add platform-independent data file reading
fprintf(fid, 'DataPath: %s\n\n', Stro.DataPath);

fprintf(fid, 'Filenames: ');
fprintf(fid, '%s ', Stro.Filename{:});
fprintf(fid, '\n\n');

fprintf(fid, '2ThetaRange: %f %f\n\n',Stro.Min2T, Stro.Max2T);

fprintf(fid, 'PolynomialOrder: %i\n', Profile.PolyOrder);
fprintf(fid, 'BackgroundPoints:');
fprintf(fid, ' %f', Profile.BackgroundPoints(:));

%fprintf(fid, '\n\nPeak Parameters\n');
fprintf(fid,'FitFunction(s): ');
fprintf(fid,'%s; ', Profile.FcnNames{:});

fprintf(fid,'\nFitRange: %.4f\n', Profile.FitRange);

fprintf(fid,'\nConstraints:');
fprintf(fid, ' %d',Stro.Constrains);

fprintf(fid, '\n\n== Initial Fit Parameters ==\n');

for g=1:size(Profile.FcnNames,1)
    fprintf(fid, '%s ', Profile.Coefficients{:}); %write coefficient names
    fprintf(fid, '\nSP: ');
    fprintf(fid, '%#.5g ', Profile.FitInitial.start);
    fprintf(fid, '\nUB: ');
    fprintf(fid, '%#.5g ', Profile.FitInitial.lower);
    fprintf(fid, '\nLB: ');
    fprintf(fid, '%#.5g ', Profile.FitInitial.upper); 
end
%===============================================================================




fprintf(fid, '\n\nFit Errors\n');

if strcmp( Stro.suffix, 'xrdml')
    fprintf(fid, 'Filename\t temperature\t Rp\t Rwp\t red-chi2'); % What is being printed on the new txt file on the rirst row (this just labels what column refers to what)
else
    fprintf(fid, 'Filename\tRp\t Rwp\t red-chi2'); % What is being printed on the new txt file on the rirst row (this just labels what column refers to what)
end

for i=1:size( Stro.data_fit, 1) %this takes the length specified above in line 30
    obs=Stro.fit_results{i}(2,:)'; %specifies observed values
    
    calc = Stro.fit_results{i}(3,:)';
    for j=1:size(Stro.PSfxn,1)
        calc = calc + Stro.fit_results{i}(3+j,:)';
    end
    fprintf(fid,'\n');
    Rp=(sum(abs(obs-calc))./(sum(obs)))*100; %calculates Rp
    w=(1./obs); %defines the weighing parameter for Rwp
    Rwp=(sqrt(sum(w.*(obs-calc).^2)./sum(w.*obs.^2)))*100 ; %Calculate Rwp
    
    DOF=Stro.FmodelGOF{i}.dfe; % degrees of freedom from error
    Rexp=sqrt(DOF/sum(w.*obs.^2)); % Rexpected
    rchi2=(Rwp/Rexp)/100; % reduced chi-squared, GOF
    
    if strcmp( Stro.suffix, 'xrdml')
        [~, filename, ~] = fileparts( Stro.Filename{1} );
        fprintf(fid, '%s\t %.0f\t %.2f\t %.2f\t %.2f',filename, Stro.temperature(i), Rp, Rwp, rchi2);
        
    else
        [~, filename, ~] = fileparts( Stro.Filename{i} );
        fprintf(fid, '%s\t%.2f\t%.2f\t%.2f', filename, Rp, Rwp, rchi2);
    end
    %writes the filename, Rp, and Rwp for into a text file rounding to 2 decimal places
end

fclose(fid); %closes file
end