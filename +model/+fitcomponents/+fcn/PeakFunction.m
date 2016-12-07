classdef PeakFunction

    properties
        Name
        Constraints
        Id
    end
    
    properties (Dependent)
        Equation
    end
    
    properties (Constant)
        minPeaks = 0;
        maxPeaks = 20;
    end
    
    enumeration
        Gaussian        ('Gaussian')
        Lorentzian      ('Lorentzian')
        PearsonVII      ('Pearson VII')
        PseudoVoigt     ('Psuedo Voigt')
    end
    

    methods
        function obj = PeakFunction(name)
        obj.Name = name;
        obj.Id = 0;
        
        end
        
        function obj = set.Id(obj, num)
            obj.Id = num;
        end
        
        
        
        function str = get.Equation(obj)
        N = ['N' num2str(obj.Id)];
        xv = ['x' num2str(obj.Id)];
        f = ['f' num2str(obj.Id)];
        m = ['m' num2str(obj.Id)];
        w = ['w' num2str(obj.Id)];
        NL = ['N',num2str(obj.Id),'L'];
        mL = ['m',num2str(obj.Id),'L'];
        NR = ['N',num2str(obj.Id),'R'];
        mR = ['m',num2str(obj.Id),'R'];
        
        switch obj.Name
            case PeakFunction.Gaussian
                str = [N '*((2*sqrt(log(2)))/(sqrt(pi)*' ...
                    f ')*exp(-4*log(2)*((xv-' xv ')^2/' f '^2)))'];
                
                
            case PeakFunction.Lorentzian
                str = [N '*1/pi* (0.5*' f '/((xv-' ...
                    xv ')^2+(0.5*' f ')^2))'];
                
                
            case PeakFunction.PearsonVII
                str = [N '*2*((2^(1/' m ')-1)^0.5) /' f ...
                    '/(pi^0.5)*gamma(' m ')/gamma(' m ...
                    '-0.5) * (1+4*(2^(1/' m ')-1)*((xv-' xv ...
                    ')^2)/' f '^2)^(-' m ')'];
                
                
            case PeakFunction.PseudoVoigt
                str = [N,'*((',w,'*(2/pi)*(1/',f, ')*1/(1+(4*(xv-',xv,')^2/', ...
                    f,'^2))) + ((1-',w, ')*(2*sqrt(log(2))/(sqrt(pi)))*1/',f, ...
                    '*exp(-log(2)*4*(xv-',xv,')^2/',f,'^2)))'];
            
        end
        
        end
        
        
    end
    
end

