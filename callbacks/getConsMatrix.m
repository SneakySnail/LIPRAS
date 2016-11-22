
% Klarissa, this will pull the selected values for the table, then generate
% a matrix based on the constraints selected. The resulting matric cMat
% will be used by makeFxn to make all the functions. 
function cMat = getConsMatrix(handles)
b=handles.table_paramselection.Data;
a=handles.table_paramselection.ColumnName;
mc=cat(1,a',b);
for i = 1:size(a,1)
    
if strcmp(a{i},'N');N=b(:,i);end
if strcmp(a{i},'x');x=b(:,i);end
if strcmp(a{i},'f'); f=b(:,i);end
if strcmp(a{i},'m');m=b(:,i);end
if strcmp(a{i},'w');w=b(:,i);end

end
dim=size(b,1);

% if one variable is not selected it will be assigned a dim by 1 matrix of
% zeros
if exist('N','var')==0; N=num2cell(zeros(dim,1));end
if exist('x','var')==0; x=num2cell(zeros(dim,1));end
if exist('f','var')==0; f=num2cell(zeros(dim,1));end
if exist('m','var')==0; m=num2cell(zeros(dim,1));end
if exist('w','var')==0; w=num2cell(zeros(dim,1));end

cMat=cat(2,N,x,f,m,w); %final matrix of constraints to use in makeFxn ( i would keep this order of parameters)
cMat=cellfun(@double,cMat);

