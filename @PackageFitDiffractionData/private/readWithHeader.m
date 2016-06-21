function readWithHeader(Stro,fileIndex,inFile)

fid = fopen(inFile,'r');
index = 0;
done = 0;
while done == 0;
		line = fgetl(fid);
		a = strsplit(line, ' ');
		try
				if strcmp(a(2),'Temp')
						temp = sprintf('%s*', cell2mat(a(5)));
						Stro.temperature(fileIndex) = sscanf(temp, '%f*');
				end
				if strcmp(a(1), '')
						S = sprintf('%s*', cell2mat(a(2)));
				else
						S = sprintf('%s*', cell2mat(a(1)));
				end
				N = sscanf(S, '%f*');
				if isempty(N)
						
				elseif isa(N, 'double')
						done = 1;
				end
		catch
				
		end
		
		index = index + 1;
end
Stro.skiplines = index;
fid = fopen(inFile,'r');
Stro.readFile(fileIndex,fid)
end
