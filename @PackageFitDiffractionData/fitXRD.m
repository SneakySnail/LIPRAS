function fitXRD(Stro, data, position, filenum,handles,g)
position=position(1);

if handles.popup_bkgdmodel.Value==1
[P, S, U] = polyfit(handles.xrd.bkgd2th,data(2,handles.pos)', handles.xrd.PolyOrder);
bkgdArray = polyval(P,data(1,:),S,U);
else
  
    
  points=handles.points;
  pos=handles.pos;
  idx=pos;
  bkgx=points';
  bkgx=[data(1,1),bkgx,data(1,end)];
  bkgy(1,:)=data(2,idx);
  bkgy=[data(2,1),bkgy,data(2,end)];
  order=2;
yy=spapi(order,bkgx,bkgy);
bkgdArray = fnval(yy,data(1,:));
end


% FOR GUI, BACKGROUND
hold on

% handles.noplotfit.Value=0;
if handles.noplotfit.Value == 1

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


% Size of array to fit
fitrangeX=length(dataNB(1,:));


dataMin = PackageFitDiffractionData.Find2theta(data(1,:),Stro.Min2T); % shapes the data matrix supplied to fit
dataMax = PackageFitDiffractionData.Find2theta(data(1,:),Stro.Max2T); % shapes data matrix suppled to fit

% Add CuKa if statement here
fitrange=Stro.fitrange;
        mid = mean([Stro.Min2T Stro.Max2T]);
        leftbound = mid-fitrange/2;
        rightbound = mid+fitrange/2;
        if leftbound < Stro.Min2T
            leftbound = Stro.Min2T;
        end
        if leftbound > Stro.Max2T
            rightbound = Stro.Max2T;
        end
        minr = PackageFitDiffractionData.Find2theta(data(1,:),leftbound);
        maxr = PackageFitDiffractionData.Find2theta(data(1,:),rightbound);
%         
% avg = mean(position(1,:)); % average of all peaks
% positionX(1) = PackageFitDiffractionData.Find2theta(dataNB(1,:),avg); % index into dataNB array
% minr=positionX(1)-floor(fitrangeX(1)/2);
% if minr<1; minr=1; end
% maxr=positionX(1)+ceil(fitrangeX(1)/2);
% if maxr>fitrangeX; maxr=fitrangeX; end

a=1;
if minr<dataMin; 
    disp('minr_true')
    minr=dataMin; 
end

if maxr>dataMax; 
      disp('maxr_true')
    maxr=dataMax; 
end

dataMin = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Min2T); % to generate data within user selected fit range
dataMax = PackageFitDiffractionData.Find2theta(Stro.two_theta,Stro.Max2T); % same as above

datafit=Stro.data_fit(:,dataMin:dataMax);
fitdata{1} = dataNB(:,minr:maxr);


fitteddata=data(:,minr:maxr);

fitteddata(3,:)=bkgdArray(:,minr:maxr);

coefficients{1}=coeffnames(g);

if Stro.recycle_results
    SP = Stro.fit_initial{1,filenum};
else
    SP = Stro.fit_initial{1};
end
LB = Stro.fit_initial{2};
UB = Stro.fit_initial{3};
Weight=1./abs(fitdata{1}(1,:));
% Weight(:)=1;
s = fitoptions('Method','NonlinearLeastSquares','StartPoint',SP,'Lower',LB,'Upper',UB,'Weight',Weight);
[fittedmodel{1},fittedmodelGOF{1}]=fit(fitdata{1}(1,:)',fitdata{1}(2,:)',g,s);
fittedmodelCI{1} = confint(fittedmodel{1}, Stro.level);
% store fitted data, aligned appropriately in the column
fdata=data;
fdata(3,:)=bkgdArray;
fdata(4,:)=fittedmodel{1}(data(1,:));
fitteddata(1+3,minr:maxr)=fittedmodel{1}(fitdata{1}(1,:));
fitteddata=fdata;
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
        plot(fitteddata(1,:),fitteddata(2,:)-(fitteddata(3,:)+fitteddata(4,:)),'-r')
%     plot(fitdata{1}(1,:),fitdata{1}(2,:)-fittedmodel{1}(fitdata{1}(1,:))','-r');

xlim([Stro.Min2T Stro.Max2T])

linkaxes([handles.axes1 handles.axes2],'x')
axes(handles.axes1) % this is slow, consider moving outside of loop
end

%Save this matrix to save the fit cutoff fit, to plot later
sfitdata(1,:)=fitdata{1}(1,:);
sfitdata(2,:)=fittedmodel{1}(fitdata{1}(1,:))'+bkgdArray(minr:maxr);

Stro.Fdata = fitteddata;
Stro.Fcoeff = coefficients;

for i=1:size(position,1)
    Stro.Fmodel{filenum,i} = fittedmodel{i};
    Stro.FmodelGOF{filenum,i} = fittedmodelGOF{i};
    Stro.FmodelCI{filenum,i} = fittedmodelCI{i};
end
