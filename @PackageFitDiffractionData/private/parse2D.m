function parse2D(Stro)
	if isempty(Stro.SPR_Chi)
		[file, path] = uigetfile({'*.chi','*.chi'},'Select Diffraction Chi File','MultiSelect', 'off');
		Stro.SPR_Chi = strcat(path,file);
	end
	
	%            for k = startImages:endImages
	for k = 1:length( Stro.Filename )
		%leading zeros (lZ)
		% if k<10, lZ=''; elseif k<100, lZ=''; else lZ=''; end;
		if k<10, lZ='00'; elseif k<100, lZ='0'; else lZ=''; end;
		
		filename = Stro.Filename{k};
		fprintf(1, '\nProcessing %s...', filename);
		
		% load data
		fid = fopen(strcat(Stro.DataPath,filename));
		i = 1; j = 1;
		while j ~= -1
			A{i} = fgetl(fid);
			%FGETL Read line from file, discard newline character
			%A{i} is intensities versus distance
			j = A{i};
			i = i + 1;
		end
		fclose(fid);
		
		data{k+1} = str2num(cat(1, A{2:end-1}));
		datamatrix(k+1,:,:) = str2num(cat(1, A{2:end-1}));
		
		numAzim = size(data{k+1}, 1);
		numBins = size(data{k+1}, 2);
	end
	fprintf(1,'\n');
	numAzim=24;
	
	if Stro.symdata==1
		DifData = cat(3, 0.5 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,1,:)) + squeeze( datamatrix(2:length(Stro.Filename)+1,numAzim/2+1,:)) )/2);
		for i=2:numAzim/4
			DifData = cat(3, DifData, 0.25 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/2+2-i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/2+i,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim-i+2,:)) )/4);
		end
		DifData = cat(3, DifData, .5 * ( squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim/4+1,:)) + squeeze(datamatrix(2:length(Stro.Filename)+1,numAzim * 3 / 4 + 1,:)) )/2);
		
	else
		DifData = cat(3, squeeze(datamatrix(2:length(Stro.Filename)+1,1,:)));
		for i=2:numAzim/4+1
			DifData = cat(3, DifData, squeeze(datamatrix(2:length(Stro.Filename)+1,i,:)));
		end
	end
	
	Stro.numAzim = numAzim;
	Stro.SPR_Data = DifData;
	
	
	fid = fopen(Stro.SPR_Chi, 'r');
	fgetl(fid);fgetl(fid);fgetl(fid);fgetl(fid);
	
	datain = fscanf(fid,'%f',[2 ,inf]);
	Stro.two_theta = datain(1,:);
	
	if isempty( Stro.SPR_Angle )
		Stro.setSPR_Angle()
	else
		Stro.setSPR_Angle( Stro.SPR_Angle )
	end
	
	fclose(fid);
	
end
