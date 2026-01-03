function [tCoeff]= detFxn(h)
% Will determine the Nx4 matrix that will populate on UITable2

list=h.FcnNames;
nlist=length(list);
h.profiles.xrd.FitFunctions=cell(1,nlist);
c=[h.NCheckBox.Value h.xCheckBox.Value h.fCheckBox.Value h.wCheckBox.Value h.mCheckBox.Value];

if sum(c)==0 % means no constraints
constrained=0;
else
constrained=1;
c1=c>0;
constraints=['N', 'x', 'f' ,'w', 'm'];
% for p=1:sum(c)
constrains=constraints(c1);
% end

end

p=0;
for i=1:nlist
 if strcmp(list(i),'Gaussian')
     n=3;
        if constrained
            h.profiles.xrd.FitFunctions{i}=model.fit.Gaussian(i,constrains);
        else
            h.profiles.xrd.FitFunctions{i}=model.fit.Gaussian(i);
        end
                
 elseif strcmp(list(i),'Lorentzian')
     n=3;
        if constrained
            h.profiles.xrd.FitFunctions{i}=model.fit.Lorentzian(i,constrains);
        else
            h.profiles.xrd.FitFunctions{i}=model.fit.Lorentzian(i);
        end
        
 elseif strcmp(list(i),'Pearson VII')
     n=4;
        if constrained
            h.profiles.xrd.FitFunctions{i}=model.fit.PearsonVII(i,constrains);
        else
            h.profiles.xrd.FitFunctions{i}=model.fit.PearsonVII(i);
        end
        
 elseif strcmp(list(i),'Pseudo-Voigt')
     n=4;
        if constrained
            h.profiles.xrd.FitFunctions{i}=model.fit.PseudoVoigt(i,constrains);
        else
            h.profiles.xrd.FitFunctions{i}=model.fit.PseudoVoigt(i);
        end
        
 elseif strcmp(list(i),'Asymmetric PVII')
     n=6;
        if constrained
            h.profiles.xrd.FitFunctions{i}=model.fit.Asymmetric(i,constrains);
        else
            h.profiles.xrd.FitFunctions{i}=model.fit.Asymmetric(i);
        end
        
 else
     n=0;
     
 end
  
         if h.Asym==1
            h.profiles.xrd.FitFunctions{i}.Asym=1;
        end
 
 p=p+n;
end
 
tCoeff=p;


