function fitXRD(Stro, data, position, filenum,handles,g)
position=position(1);
[P, S, U] = PackageFitDiffractionData.fitBkgd(data, Stro.bkgd2th, Stro.PolyOrder);

% FOR GUI, BACKGROUND
hold on
bkgdArray = polyval(P,data(1,:),S,U);
% handles.noplotfit.Value=0;
if handles.noplotfit.Value==1

plot(data(1,:),bkgdArray,'k-') %to check okay
end

%END

% Make new matrix with NB ("no background")
dataNB = data;
dataNB(2,:) = data(2,:) - bkgdArray;
% Stro.fit_results{i}
%     column 1 = 2theta
%     column 2 = raw data
%     column 3 = background function
%     column 4 = Overall fit w/o background
%     column 5 = 1st peak w/o background...
%     column 6+ = next peak w/o background..., etc.
fitteddata=data;
fitteddata(3,:)=bkgdArray;

% Size of array to fit
fitrangeX=length(dataNB(1,:));

% Add CuKa if statement here
avg = mean(position(1,:)); % average of all peaks
positionX(1) = PackageFitDiffractionData.Find2theta(dataNB(1,:),avg); % index into dataNB array
minr=positionX(1)-floor(fitrangeX(1)/2);
if minr<1; minr=1; end
maxr=positionX(1)+ceil(fitrangeX(1)/2);
if maxr>fitrangeX; maxr=fitrangeX; end
fitdata{1} = dataNB(:,minr:maxr);
assignin('base','fitdata',fitdata) % ADDED BY GIO


coefficients{1}=coeffnames(g);
len=length(coefficients{1});

if Stro.recycle_results
    SP = Stro.fit_initial{1,filenum};
else
    SP = Stro.fit_initial{1};
end
LB = Stro.fit_initial{2};
UB = Stro.fit_initial{3};

s = fitoptions('Method','NonlinearLeastSquares','StartPoint',SP,'Lower',LB,'Upper',UB);
[fittedmodel{1},fittedmodelGOF{1}]=fit(fitdata{1}(1,:)',fitdata{1}(2,:)',g,s);
fittedmodelCI{1} = confint(fittedmodel{1}, Stro.level);
% store fitted data, aligned appropriately in the column
fitteddata(1+3,minr:maxr)=fittedmodel{1}(fitdata{1}(1,:));
assignin('base','fitteddata',fitteddata)

if handles.noplotfit.Value==1
    cla
% FOR GUI, FIT
plot(fitdata{1}(1,:),fittedmodel{1}(fitdata{1}(1,:))'+bkgdArray(minr:maxr),'-','Color',[0 .5 0],'LineWidth',1.5);
pause(0.05);
%END

% FOR GUI, DATA
plot(data(1,:),data(2,:),'o','MarkerSize',4,'LineWidth',1,'MarkerEdgeColor',[.08 .17 .55], 'MarkerFaceColor',[.08 .17 .55]) % CHANGES MARKER COLOR
% END

% FOR GUI DIFFERENCE PLOT
axes(handles.axes2) % this is slow, consider moving outside loop
cla
for j=1:size(position,1)
    plot(fitdata{j}(1,:),fitdata{j}(2,:)-fittedmodel{j}(fitdata{j}(1,:))','-r');
end
xlim([Stro.Min2T Stro.Max2T])

linkaxes([handles.axes1 handles.axes2],'x')
axes(handles.axes1) % this is slow, consider moving outside of loop
end

Stro.Fdata = fitteddata;
Stro.Fcoeff = coefficients;

for i=1:size(position,1)
    Stro.Fmodel{filenum,i} = fittedmodel{i};
    Stro.FmodelGOF{filenum,i} = fittedmodelGOF{i};
    Stro.FmodelCI{filenum,i} = fittedmodelCI{i};
end
