function arrayposition=FindValue(data,value2theta)
% function arrayposition=Find2theta(data,value2theta)
% Finds the nearest position in a vector
% MUST be a single array of 2theta values only (most common error)

if nargin~=2
    error('Incorrect number of arguments')
    arrayposition=0;
else
    % conditional to increase the accuracy of the selected cell
    greater = find(data >= value2theta);
    less = find(data <= value2theta);
    % test or test2 can be empty if the value sits at the edge
    % of a data set
    if isempty(greater)
        greater=less;
    elseif isempty(less)
        less=greater;
    end
    
   % Find closest point to value2theta 
    right = abs(data(greater(1))-value2theta);
    left = abs(value2theta-data(less(end)));
    
    if right <= left
        arrayposition = greater(1);
    else
        arrayposition = less(end);
    end
    
end