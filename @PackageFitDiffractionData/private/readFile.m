function readFile(Stro,index,fid)

for i=1:Stro.skiplines
		fgetl(fid);
end
if or(strcmp( Stro.suffix, 'csv'), strcmp( Stro.suffix, '.csv'))
		datain = xlsread(fid,'A:B');
		datain = transpose(datain);
elseif or(strcmp( Stro.suffix, 'xy'), strcmp( Stro.suffix, '.xy'))
		datain = fscanf(fid,'%f',[2 ,inf]);
elseif or(strcmp( Stro.suffix, 'fxye'), strcmp( Stro.suffix, '.fxye'))
		datain = fscanf(fid,'%f',[3 ,inf]);
		datain(1,:) = datain(1,:) ./ 100;
elseif or(strcmp( Stro.suffix, 'chi'),strcmp( Stro.suffix, '.chi'))
		fgetl(fid);fgetl(fid);fgetl(fid);fgetl(fid);
		datain = fscanf(fid,'%f',[2 ,inf]);
else
		datain = fscanf(fid,'%f',[2 ,inf]);
end

fclose(fid);

Stro.two_theta = datain(1,:);
Stro.data_fit(index,:) = datain(2,:);
end
