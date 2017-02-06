function readFile(Stro,index,fid)
if or(strcmp( Stro.suffix, 'csv'), strcmp( Stro.suffix, '.csv'))
    datain = xlsread(fid);
    % Method for reading of data that does not start with numerial
    % twotheta and intensity
    cc=isnan(datain(:,1)); % checks if any NaN were read in
    for i=1:length(cc) %  sums the results of cc if after summing 5 rows and the sum is 0, then it re-shapes the data read in with xlsread
        s= sum(cc(i:i+5),1);
        if s==0
            p=i;
            break
        end
    end
    
    datain=datain(p:end,:); % reshapes based on for loop results
    datain=datain(:,1:2)'; % now takes the first two columns of intesity and 2-theta and transpose
    
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

if or(strcmp( Stro.suffix, 'csv'), strcmp( Stro.suffix, '.csv'))
else
    fclose(fid); % xlsread does not need fclose
end

Stro.two_theta = datain(1,:);
Stro.data_fit(index,:) = datain(2,:);
end
