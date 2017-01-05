classdef Constraints
    %CONSTRAINTS A value class that is stored in the class ProfileData to help
    %   provide implementation abstraction. It accepts an array of size ?x5,
    %   where the first column 
    
    properties
       NumPeaks
    end
    
    properties (Dependent)
        Logical 
        % A structure containing logical values with members 'N', 'x', 'f', 'w', and 'm'
        CoeffList
        coeffs = '' % Cell array of the constrained coeffs
        
    end
    properties (Dependent, Hidden)
        N
        x
        f
        w
        m
    end
    
    properties (Hidden)
        Logical_
        Logical_N_
        Logical_x_
        Logical_f_
        Logical_w_
        Logical_m_
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
    
    
    methods
        function this = Constraints(constraints)
        if nargin < 1
            this.Logical = false(1, 5);
        else
            this.Logical = logical(constraints);
        end
        
        this.total = length(find(sum(this.Logical.N, 1)));
        end
        
        
        
        function value = get.coeffs(this)
        value = '';
        
        if this.isNConstrained
            value = [value, {'N'}];
        end
        
        if this.isXConstrained
            value = [value, {'x'}];
        end
        
        if this.isFConstrained
            value = [value, {'f'}];
        end
        
        if this.isWConstrained
            value = [value, {'w'}];
        end
        
        if this.isMConstrained
            value = [value, {'m'}];
        end
        
        end
        
        %         function val = get.N(this)
        %         val = ~isempty(find(this.Logical(:, this.N_COLUMN), 1));
        %         end
        
        function val = get.N(this)
        val = this.Logical(:, this.N_COLUMN)';
        end
        
        
        %         function val = get.x(this)
        %         val = ~isempty(find(this.Logical(:, this.x_COLUMN), 1));
        %         end
        
        function val = get.x(this)
        val = this.Logical(:, this.x_COLUMN)';
        end
        
        %         function val = get.f(this)
        %         val = ~isempty(find(this.Logical(:, this.f_COLUMN), 1));
        %         end
        
        function val = get.f(this)
        val = this.Logical(:, this.f_COLUMN)';
        end
        
        %         function val = get.w(this)
        %         val = ~isempty(find(this.Logical(:, this.w_COLUMN), 1));
        %         end
        
        function val = get.w(this)
        val = this.Logical(:, this.w_COLUMN)';
        end
        
        %         function val = get.m(this)
        %         val = ~isempty(find(this.Logical(:, this.m_COLUMN), 1));
        %         end
        
        function val = get.m(this)
        val = this.Logical(:, this.m_COLUMN)';
        end
        
        function val = get.nPeaks(this)
        val = size(this.Logical, 1);
        end
        
        function this = update(this, constraints)
        this.Logical = constraints;
        end
        
        function value = get.Logical(this)   
        value.N = this.Logical_(:,1)';
        
        value.x = this.Logical_(:,2)';
        
        value.f = this.Logical_(:,3)';
        
        value.w = this.Logical_(:,4)';
        
        value.m = this.Logical_(:,5)';
        
            
        
        
        
        end
    end
    
    methods
        function this = set.Logical(this, value)
        if isempty(this.Logical_)
            this.Logical_ = value;
        end
        
        if ~islogical(value) && ~isstruct(value)
            MException('Constraints:Logical:InvalidType')
        end
        
        if size(value, 2) ~= 5
            MException('Constraints:Logical:InvalidLength')
        end
        
        if isstruct(value)
            if isfield(value, 'N')
                this.Logical_N_ = value;
            end
            if isfield(value, 'x')
                this.Logical_x_ = value;
            end
            if isfield(value, 'f')
                this.Logical_f_ = value;
            end
            if isfield(value, 'w')
                this.Logical_w_ = value;
            end
            if isfield(value, 'm')
                this.Logical_m_ = value;
            end
            
        else
            this.Logical_N_ = value(:, 1);
            this.Logical_x_ = value(:, 2);
            this.Logical_f_ = value(:, 3);
            this.Logical_w_ = value(:, 4);
            this.Logical_m_ = value(:, 5);
        end
        
        end
    
        function result = isNConstrained(this)
        result = ~isempty(find(this.Logical.N, 1));
        end
        function result = isXConstrained(this)
        result = ~isempty(find(this.Logical.x, 1));
        end
        function result = isFConstrained(this)
        result = ~isempty(find(this.Logical.f, 1));
        end
        function result = isWConstrained(this)
        result = ~isempty(find(this.Logical.w, 1));
        end
        function result = isMConstrained(this)
        result = ~isempty(find(this.Logical.m, 1));
        end
        
    end
    
    
    
    
    
end