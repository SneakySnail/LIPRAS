% TODO Move to FDGUIv2_1
function outputError(Stro,~)
	if isa(Stro.Filename,'char')
		Stro.Filename = {Stro.Filename};
	end
	
	if ~exist( Stro.OutputPath, 'dir' )
		mkdir( Stro.OutputPath );
	end
	
	if length(Stro.Filename) == 1
		if isempty(Stro.SPR_Angle)
			outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_RwRp_error_');
		else
			outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_RwRp_error_Angle_',num2str(Stro.SPR_Angle),'_');
		end
	else
		if isempty(Stro.SPR_Angle)
			outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_Series_RwRp_error_');
		else
			outFilePrefix = strcat(Stro.OutputPath,Stro.Filename{1},'_Series_RwRp_error_Angle_',num2str(Stro.SPR_Angle),'_');
		end
	end
	
	index = 0;
	iprefix = '00';
	while exist(strcat(outFilePrefix,strcat(iprefix,num2str(index)),'.txt'),'file') == 2
		index = index + 1;
		if index > 100
			iprefix = '';
		elseif index > 10
			iprefix = '0';
		end
	end
	fid=fopen(strcat(outFilePrefix,strcat(iprefix,num2str(index)),'.txt'),'w'); %the name of the file it will write containing the statistics of the fit
	
	fprintf(fid, 'Fit parameters\n\n');
	fprintf(fid, '2theta_fit_range: %f %f\n\n',Stro.Min2T, Stro.Max2T);
	
	if ~isempty(Stro.SPR_Angle)
		fprintf(fid, 'SPR_Angle: %i \n\n',Stro.SPR_Angle);
	end
	
	fprintf(fid, 'Number_of_background_points: %i\n',length(Stro.bkgd2th));
	fprintf(fid, 'Background_order: %i\n', Stro.PolyOrder);
	fprintf(fid, 'Background_points:');
	for i=1:length(Stro.bkgd2th)
		fprintf(fid, ' %f',Stro.bkgd2th(i));
	end
	fprintf(fid, '\n\nPeak Parameters\n');
	
	fprintf(fid, 'PeakPos:');
	for i=1:size(Stro.PSfxn,1) % i=profilenum
		if i~=1
			fprintf(fid,';');
		end
		for j=1:size(Stro.PSfxn,2) % j=peaknum
			fprintf(fid,' %.3f',Stro.PeakPositions(i,j));
		end
	end
	fprintf(fid,'\nFxn:');
	for i=1:size(Stro.PSfxn,1)
		for j=1:size(Stro.PSfxn,2)
			fprintf(fid,' %s',Stro.PSfxn{j});
		end
	end
	
	if ~isempty(Stro.fitrange)
		fprintf(fid,'\nfitrange:');
		for i=1:size(Stro.PSfxn,1)
			fprintf(fid,' %.4f',Stro.fitrange(i));
		end
	end
	fprintf(fid,'\nConstraints:');
	fprintf(fid, ' %d',Stro.Constrains);
	
	fprintf(fid, '\n\nFit_initial Parameters\n');
	for g=1:size(Stro.PSfxn,1);
		% 				fprintf(fid, '\n%s', Stro.PSfxn{g});
		for f=1:length(Stro.Fcoeff);
			fprintf(fid, '%s ', Stro.Fcoeff{f}{:}); %write coefficient names
		end
		fprintf(fid, '\n%s','SP:');
		fprintf(fid,' %#.5g',(Stro.fit_initial{1,1}));
		fprintf(fid, '\n%s','UB:');
		fprintf(fid,' %#.5g',(Stro.fit_initial{2,1}));
		fprintf(fid, '\n%s','LB:');
		fprintf(fid,' %#.5g',(Stro.fit_initial{3,1}));
		
	end
	
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
        
        DOF=size(obs,1)-Stro.FmodelGOF{i}.dfe; % degrees of freedom from error
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