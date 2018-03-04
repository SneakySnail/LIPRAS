classdef PseudoVoigt < model.fit.FitFunctionInterface
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        Name = 'Pseudo-Voigt'
        
        CoeffNames = {'N' 'x' 'f' 'w'};
        
        ID
        
    end
    
    
    methods
        function this = PseudoVoigt(id, constraints)
        if nargin < 1
            id = 1;
        end
        
        if nargin < 2
            constraints = '';
        end
        
        this@model.fit.FitFunctionInterface(id, constraints);
        
        if ~isempty(find(strcmpi(this.ConstrainedCoeffs, 'm'), 1))
            this = this.constrain('m');
        end
        end
        
        function str = getEqnStr(this, xval)
        import utils.contains
        coeff = this.getCoeffs;
        Nidx = find(contains(coeff, 'N'), 1);
        xidx = find(contains(coeff, 'x'), 1);
        fidx = find(contains(coeff, 'f'), 1);
        widx = find(contains(coeff, 'w'), 1);
        if nargin > 1
           coeff{xidx} = num2str(xval);
        end
        str = [coeff{Nidx} '*((' coeff{widx} '*(2/pi)*(1/' coeff{fidx} ')*1/(1+(4*(xv-' coeff{xidx} ...
            ')^2/' coeff{fidx} '^2))) + ((1-' coeff{widx} ')*(2*sqrt(log(2))/(sqrt(pi)))*1/' ...
            coeff{fidx} '*exp(-log(2)*4*(xv-' coeff{xidx} ')^2/' coeff{fidx} '^2)))'];
        end
        
        function value = getCoeffs(this)
        this.ConstrainedLogical(5) = false;
        value = getCoeffs@model.fit.FitFunctionInterface(this);
        end
        
        function output = getDefaultInitialValues(this, data, peakpos)
        value = getDefaultInitialValues@model.fit.FitFunctionInterface(this, data, peakpos);
        
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        output.w = value.w;

        end
        
        function output = getDefaultLowerBounds(this, data, peakpos)
        value = getDefaultLowerBounds@model.fit.FitFunctionInterface(this, data, peakpos);
        
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        output.w = value.w;
        end
        
        function output = getDefaultUpperBounds(this, data, peakpos)
        value = getDefaultUpperBounds@model.fit.FitFunctionInterface(this, data, peakpos);
        
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        output.w = value.w;

        end
    end
    
    methods (Static)
        
        
        function result = isMConstrained()
        result = false;
        end
        
    end
    
    
    methods (Access = protected)
        function output = calculate_(this, xdata, coeffvals)
        coeffs = this.getCoeffs;
        
        for i=1:length(coeffs)
           c = coeffs{i}(1);
           if c == 'N'
               N = coeffvals(i);
           elseif c == 'x'
               xv = coeffvals(i);
           elseif c == 'f'
               f = coeffvals(i);
           elseif c == 'w'
               w = coeffvals(i);
           end
        end
        
        output = N.*((w.*(2./pi).*(1./f).*1./(1+(4.*(xdata-xv).^2./f.^2))) + ...
            ((1-w).*(2.*sqrt(log(2))./(sqrt(pi))).*1./f.*exp(-log(2).*4.*(xdata-xv).^2./f.^2)));
        end
        
        
    end
    
end

