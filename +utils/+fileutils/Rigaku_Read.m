function [data]=Rigaku_Read(filename,ext)

openresults=fopen(filename,'r');

if strcmp(ext,'.asc')
    pp=0;
while pp<1
                a=fgetl(openresults);
                as=strsplit(a);
    if strcmp(as{1},'*COUNT') % this line is before * Count
                pp=1;
    elseif strcmp(as{1},'*SCAN_MODE')
        scanType=as{3};
    elseif strcmp(as{1},'*WAVE_LENGTH1')
        kalpha1=str2double(as{3});
    elseif strcmp(as{1},'*WAVE_LENGTH2')
        kalpha2=str2double(as{3});
    elseif strcmp(as{1},'*START')
        start=str2double(as{3});
    elseif strcmp(as{1},'*STOP')
        stop=str2double(as{3});
    elseif strcmp(as{1},'*STEP')
        step=str2double(as{3});    
    elseif a==-1
        disp('Nothing was detected')
        break
    end
end
results1=transpose(textscan(openresults,'%f','Delimiter',','));%opens the file listed above and obtains data in all 5 columns
twotheta=start:step:stop;
intensity=results1{1}';
mult=1;
else
% for i=1:4
% a=fgetl(openresults);
% end
pp=0;
a='Test';
while pp<1
    if strcmp(a,'*RAS_INT_START')
        pp=1;
        continue
    elseif contains(a,'ALPHA1')
        alpha1=strsplit(a);
        kalpha1=str2double(strrep(alpha1{2},'"',''));

    elseif contains(a,'ALPHA2')
        alpha2=strsplit(a);
        kalpha2=str2double(strrep(alpha2{2},'"',''));
    elseif contains(a,'MEAS_SCAN_AXIS_X')
                scanType=strsplit(a);
                scanType=strrep(scanType{2},'"','');
    end
        a=fgetl(openresults);
end
n=3;

results1=fscanf(openresults,'%f',[n inf]);%opens the file listed above and obtains data in all 5 columns
                   %change the 3 in [3, inf]%for all other%xy files that%dont pertain %to%integrations%done on 2-ID-D%data
                                                                                                            
twotheta=results1(1,:);
intensity=results1(2,:);
mult=results1(3,:);
intensity=intensity.*mult;
end

data = struct('KAlpha1',kalpha1,'KAlpha2',kalpha2,'two_theta',twotheta,...
    'data_fit',intensity,'mult',mult,'ext',ext,'scanType',java.lang.String(scanType));

