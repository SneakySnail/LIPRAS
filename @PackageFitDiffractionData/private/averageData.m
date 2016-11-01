function averageData(Stro,numFiles)
	Stro.DataAverage = numFiles;
	if ~isempty(Stro.originalData)
		Stro.data_fit = Stro.originalData;
		Stro.temperature = Stro.temperature_init;
		Stro.fit_parms = {};
		Stro.fit_parms_error = {};
		Stro.fit_results = {};
	end
	temp = [];
	data = [];
	[a b] = size( Stro.data_fit );
	for i=0:a/numFiles-1
		for j=1:numFiles
			if j==1
				data(i+1,:) = Stro.data_fit(numFiles*i+j,:)/numFiles;
				if ~isempty(Stro.temperature); temp(i+1) = Stro.temperature(numFiles*i+j,:)/numFiles; end
			else
				data(i+1,:) = data(i+1,:) + Stro.data_fit(numFiles*i+j,:)/numFiles;
				if ~isempty(Stro.temperature); temp(i+1) = temp(i+1) + Stro.temperature(numFiles*i+j,:)/numFiles; end
			end
		end
	end
	
	Stro.originalData = Stro.data_fit;
	Stro.data_fit = data;
	Stro.temperature_init = Stro.temperature;
	Stro.temperature = temp;
	
end