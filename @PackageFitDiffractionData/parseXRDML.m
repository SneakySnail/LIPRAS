function parseXRDML(Stro,index)

Stro.suffix = 'xrdml';

DataIndex = 1;
Data = {};
Data{1,1} = 0;
X = 0;
Z = 0;
fileIndex = 0;

file = [Stro.DataPath Stro.DataSet{1}.FileName];
data = utils.fileutils.parseXML(file);
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
                temperature(PosI,:) = mean(strread(data.Children(1,dataIndex).Children(1,scanIndex).Children(1,PosI).Children(1,4).Children(1,1).Data,'%f'))-273.15;
            else
                temperature(PosI,:) = 25;
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
        
        
        
    end
end


% Reading Kalpha1, Kalpha2, Kbeta, and Ratio from XRDML
% how to read XML, if the element is tabbed over twice,
% you need two instances of Children to access it then
% the Name, or Attribute. To read the value within it,
% you will need another Children since it will be
% tabbed over again.
for p=1:scanIndex
    if strcmp(data.Children(1,dataIndex).Children(1,p).Name, 'usedWavelength')
        KAlpha1=data.Children(1,dataIndex).Children(1,4).Children(1,2).Children(1,1).Data;
        KAlpha2=data.Children(1,dataIndex).Children(1,4).Children(1,4).Children(1,1).Data;
        kBeta=data.Children(1,dataIndex).Children(1,4).Children(1,6).Children(1,1).Data;
        Ratio_alph1_alph2=data.Children(1,dataIndex).Children(1,4).Children(1,8).Children(1,1).Data;
        disp('1')
    end
    
end






Stro.KAlpha1(index,:)=str2double(KAlpha1);
Stro.KAlpha2(index,:)=str2double(KAlpha2);
Stro.KBeta(index,:)=str2double(kBeta);
Stro.RKa1Ka2(index,:)=str2double(Ratio_alph1_alph2);

Stro.two_theta = tth';
Stro.data_fit(index,:) = intensity';
if length(unique(temperature))==2
    temperature=unique(temperature);
    temperature=temperature(2);
else
    temperature=25;
end
Stro.Temperature(index,:) = temperature;
end