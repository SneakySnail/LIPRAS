function SplitSprFile
%% Description

% This .m file splits SPR files generated from FIT2D, given a chi file,
% into individual xy files for input into LIPRAS

% Written by Giovanni Esteves
% Department of Materials Science and Engineering
% North Carolina State University, 2015
% email: gesteves21@gmail.com

%% File select
disp('Select .spr File')
[filenamespr, datapathspr]=uigetfile('.spr','MultiSelect','on'); %will ask user to input a new file if no...program skips to line 42
disp('Select .chi File')
[filename, datapath]=uigetfile([datapathspr,'*.chi']); %will ask user to input a new file if no...program skips to line 42

if isa(filenamespr,'char')==1
    filenamespr={filenamespr};
elseif filenamespr==0 % if user cancels file selection at spr file selection
    return
elseif filename==0 % if user cancels file selection at picking chi file
    return
end

%% Data Read
for f=1:length(filenamespr)
 
% Read Spr
readspr=fopen(strcat(datapathspr,filenamespr{f}),'r');
fgetl(readspr);
% Read Chi
inFile = strcat(datapath, filename);    
openresults=fopen(inFile,'r');
for i=1:4
fgetl(openresults);
end
results1=transpose(fscanf(openresults,'%f',[2 inf]));%opens the file listed above and obtains data in all 5 columns
% Assign Data
twotheta=results1(:,1);
intensity=results1(:,2);
dim=size(twotheta);
dataspr=fscanf(readspr, '%f', [dim(1) inf]);
dimspr=size(dataspr);
%Check is files match using # of twotheta values
if dim(1)~=dimspr(1)
    error('Number of twotheta values dont match corresponding spr file, did you pick the right chi/spr file?')
end

%% Data Rewrite
filenamesplit=strsplit(filenamespr{f},'.');
for j=1:dimspr(2)
    FileId=strcat(datapathspr,filenamesplit(1),'-bin-',num2str(j),'.xy');
    dtw=fopen(char(FileId),'w');
    datatowrite(:,1)=twotheta;
    datatowrite(:,2)=dataspr(:,j);
    for m=1:dim(1)
    fprintf(dtw,'%f\t %f \t \n',datatowrite(m,1)',datatowrite(m,2)');
    end
    fclose('all');

    newdir=strcat(datapathspr,'bin',num2str(j));
if exist(newdir,'dir')
    copyfile(FileId{:},newdir)
else
    mkdir(newdir)
    copyfile(FileId{:},newdir)   
end
% Folder 'All'
allnewdir=strcat(datapathspr,'All');
if exist(allnewdir,'dir')
    movefile(FileId{:},allnewdir)
else
    mkdir(allnewdir)
    movefile(FileId{:},allnewdir)   
end
end

end