classdef CuKalpha2 
    properties
        Function
        KAlpha1
        KAlpha2
    end
    
    methods
        function this = CuKalpha2(funcObj, Ka1, Ka2)
        %CuKapha2 creates a CuKalpha2 peak function for the fit object specified in fitObj.
        this.Function = funcObj;
        this.KAlpha1 = Ka1;
        if nargin > 2
            this.KAlpha2 = Ka2;
        else
            this.KAlpha2 = Ka1;
        end
        end
        
        function str = getEqnStr(this)
        str = this.Function.getEqnStr;
        Nx = this.Function.coeff('N');
        if ischar(Nx)
            Nx = {Nx};
        end
        for i=1:length(Nx)
           Ncoeff = ['((1/1.9)*' Nx{i} ')'];
           str = strrep(str, Nx{i}, Ncoeff);
        end
        xx = this.Function.coeff('x');
        xKa2 = ['model.fit.CuKalpha2.Ka2fromKa1(' xx ',' num2str(this.KAlpha1) ',' ...
            num2str(this.KAlpha2) ')'];
        str = strrep(str, xx, xKa2);
        end
        
        function output = calculateFit(this, xdata, coeffvals)
        xidx = find(utils.contains(this.Function.getCoeffs, 'x'),1);
        Nidx = find(utils.contains(this.Function.getCoeffs, 'N'));
        coeffvals(xidx) = this.Ka2fromKa1(coeffvals(xidx),this.KAlpha1,this.KAlpha2);
        coeffvals(Nidx) = 1/1.9*coeffvals(Nidx);
        output = this.Function.calculateFit(xdata, coeffvals);
        end
    end
    
    methods (Static)
        function position2 = Ka2fromKa1(position1, lambda1, lambda2)
        %KA2FROMKA1 calculates the second peak position using KAlpha1 and KAlpha2.
        %
        %   POSITION1 is the 2theta position of the first peak.
        position2 = 180 / pi * (2*asin(lambda2/lambda1*sin(pi / 180 * (position1/2))));
        end 
    end
end