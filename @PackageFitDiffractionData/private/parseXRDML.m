function parseXRDML(Stro)
	
	Stro.suffix = 'xrdml';
	
	DataIndex = 1;
	Data = {};
	Data{1,1} = 0;
	X = 0;
	Z = 0;
	fileIndex = 0;
	
	for fileNumb = 1:length(Stro.Filename)
		file = Stro.Filename{fileNumb};
		[parthstr,name,ext] = fileparts(file);
		if strcmp(ext, char('.xrdml'))
			data = parseXML(file);
			for i = 1:length(data.Children)
				if strcmp(data.Children(1,i).Name, 'xrdMeasurement')
					dataIndex = i;
				end
			end
			for i = 1:length(data.Children(1,dataIndex).Children)
				if strcmp(data.Children(1,dataIndex).Children(1,i).Name, 'scan')
					tth = 0;
					fileIndex = fileIndex + 1;
					scanIndex = i;
					for PosI = 1:length(data.Children(1,dataIndex).Children(1,scanIndex).Children)
						if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Name, 'dataPoints')
							for DataPointsi = 1:length(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children)
								if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Name, 'positions')
									if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Attributes(1,1).Value, '2Theta')
										if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,2).Name, 'listPositions')
											tth = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,2).Children(1,1).Data,'%f');
										else
											ttho = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,2).Children(1,1).Data,'%f');
											tthf = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,4).Children(1,1).Data,'%f');
										end
									end
								end
								if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Name, 'intensities')
									intensity = strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,DataPointsi).Children(1,1).Data,'%f');
								end
							end
						end
						if strcmp(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Name, 'nonAmbientPoints')
							temperature = mean(strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,4).Children(1,1).Data,'%f'))-273.15;
						else
							temperature = 25;
						end
					end
					if tth == 0
						step = (tthf - ttho) / (length( intensity )-1);
						tth = ttho:step:tthf;
						tth = tth';
						if length(tth') ~= length( Data{DataIndex,1}(1,:))
							DataIndex = DataIndex + 1;
							Data{DataIndex,1} = 0;
							fileIndex = 1;
						end
					end
					if Data{DataIndex,1} == 0
						Data{DataIndex,1} = cat(Data{DataIndex,1},tth');
						Data{DataIndex,2}(1:length(tth)) = temperature;
						Data{DataIndex,3} = intensity';
					else
						Data{DataIndex,1}(fileIndex,:) = tth';
						Data{DataIndex,2}(fileIndex,:) = temperature;
						Data{DataIndex,3}(fileIndex,:) = intensity';
					end
				end
			end
		end
	end
	
	for k = 2:DataIndex
		X = Data{k,1};
		Y = Data{k,2};
		Z = Data{k,3};
		numScans = size(X);
		numScans = numScans(1);
		for i = 1:numScans
			for j = i:numScans
				if Y(j,1) < Y(i,1)
					swapZ = Z(j,:);
					swapY = Y(j,:);
					Y(j,:) = Y(i,:);
					Z(j,:) = Z(i,:);
					Y(i,:) = swapY;
					Z(i,:) = swapZ;
				end
			end
		end
		Data{k,1} = X;
		Data{k,2} = Y;
		Data{k,3} = Z;
	end
	
	Stro.two_theta = Data{2,1}(1,:);
	Stro.data_fit = Data{2:DataIndex,3};
	Stro.temperature = Data{2:DataIndex,2}(:,1);
end