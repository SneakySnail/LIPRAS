classdef PearsonVII < model.fitcomponents.FitFunctionInterface
    %UNTITLED9 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name = 'Pearson VII'
        
        CoeffNames = {'N' 'x' 'f' 'm'};
   
        ID
        
    end
    
    
    methods
        function this = PearsonVII(id, constraints)
        if nargin < 1
            id = 1;
        end
        
        if nargin < 2
            constraints = '';
        end
        
        this@model.fitcomponents.FitFunctionInterface(id, constraints);
        
        if ~isempty(find(strcmpi(this.ConstrainedCoeffs, 'w'), 1))
            this = this.constrain('w');
        end

        end
        
        function str = getEqnStr(this)
        import utils.contains
        coeff = this.getCoeffs;
        Nidx = find(contains(coeff, 'N'), 1);
        xidx = find(contains(coeff, 'x'), 1);
        fidx = find(contains(coeff, 'f'), 1);
        midx = find(contains(coeff, 'm'), 1);
        
        str = [coeff{Nidx} '*2*((2^(1/' coeff{midx} ')-1)^0.5)/' coeff{fidx} ...
            '/(pi^0.5)*gamma(' coeff{midx} ')/gamma(' coeff{midx} '-0.5)*(1+4*(2^(1/' ...
            coeff{midx} ')-1)*((xv-' coeff{xidx} ')^2)/' coeff{fidx} '^2)^(-' coeff{midx} ')'];
        end
        
        function value = getCoeffs(this)
        this.ConstrainedLogical(4) = false;
        value = getCoeffs@model.fitcomponents.FitFunctionInterface(this);
        end
        
        function output = getDefaultInitialValues(this, data)
        value = getDefaultInitialValues@model.fitcomponents.FitFunctionInterface(this, data);
        
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        output.m = value.m;
        end
        
        function output = getDefaultLowerBounds(this, data)
        value = getDefaultLowerBounds@model.fitcomponents.FitFunctionInterface(this, data);
        
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        output.m = value.m;
        end
        
        function output = getDefaultUpperBounds(this, data)
        value = getDefaultUpperBounds@model.fitcomponents.FitFunctionInterface(this, data);
        
        output.N = value.N;
        output.x = value.x;
        output.f = value.f;
        output.m = value.m;
        end
    end
    
    methods (Static)
        
        
        function [c4] = C4(m)
        c4 = 2*((2^(1/m)-1)^0.5)/(pi^0.5)*gamma(m)/gamma(m-0.5);
        end
        
        function result = isWConstrained()
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
           elseif c == 'm'
               m = coeffvals(i);
           end
        end
        
        output = N .* this.C4(m) ./ f .*(1+4 .* (2.^(1/m)-1) .* (xdata-xv).^2 / f.^2) .^(-m);
        
        end
        
    end
    
end

