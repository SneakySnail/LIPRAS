classdef Constraints
    properties (Dependent)
        coeffs = ''
        
    end
    properties (Dependent, Hidden)
        N
        x
        f
        w
        m
    end
    
    properties (Hidden)
        nPeaks
        total
    end
    
    
    properties (Constant, Hidden)
        N_COLUMN = 1;
        x_COLUMN = 2;
        f_COLUMN = 3;
        w_COLUMN = 4;
        m_COLUMN = 5;
    end
    
    properties (Hidden)
        constraints_
    end
    
    
    methods
        function this = Constraints(constraints)
        if nargin < 1
            this.constraints_ = false(1, 5);
        else
            this.constraints_ = logical(constraints);
        end
        
        this.total = length(find(sum(constraints, 1)));
        end
        
        
        
        function value = get.coeffs(this)
        value = '';
        
        if ~isempty(find(sum(this.N, 1),1))
            value = [value, {'N'}];
        end
        
        if ~isempty(find(sum(this.x, 1),1))
            value = [value, {'x'}];
        end
        
        if ~isempty(find(sum(this.f, 1),1))
            value = [value, {'f'}];
        end
        
        if ~isempty(find(sum(this.w, 1),1))
            value = [value, {'w'}];
        end
        
        if ~isempty(find(sum(this.m, 1),1))
            value = [value, {'m'}];
        end
        
        end
        
        %         function val = get.N(this)
        %         val = ~isempty(find(this.constraints_(:, this.N_COLUMN), 1));
        %         end
        
        function val = get.N(this)
        val = this.constraints_(:, this.N_COLUMN)';
        end
        
        
        %         function val = get.x(this)
        %         val = ~isempty(find(this.constraints_(:, this.x_COLUMN), 1));
        %         end
        
        function val = get.x(this)
        val = this.constraints_(:, this.x_COLUMN)';
        end
        
        %         function val = get.f(this)
        %         val = ~isempty(find(this.constraints_(:, this.f_COLUMN), 1));
        %         end
        
        function val = get.f(this)
        val = this.constraints_(:, this.f_COLUMN)';
        end
        
        %         function val = get.w(this)
        %         val = ~isempty(find(this.constraints_(:, this.w_COLUMN), 1));
        %         end
        
        function val = get.w(this)
        val = this.constraints_(:, this.w_COLUMN)';
        end
        
        %         function val = get.m(this)
        %         val = ~isempty(find(this.constraints_(:, this.m_COLUMN), 1));
        %         end
        
        function val = get.m(this)
        val = this.constraints_(:, this.m_COLUMN)';
        end
        
        function val = get.nPeaks(this)
        val = size(this.constraints_, 1);
        end
        
        function this = update(this, constraints)
        this.constraints_ = constraints;
        end
        
    end
    
    
    
end