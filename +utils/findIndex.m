function arraypositions = findIndex(data, pattern)
%FINDINDEX(DATA, PATTERN) Finds the nearest position in a vector
%
%   If PATTERN is an array of numbers, Returns a numeric array of the indices of points specified in
%   the argument 'points'. For each point in the 'value2theta' argument, this
%   function finds the nearest value of the point.

if nargin~=2
    error('Incorrect number of arguments')
end

position = zeros(1, length(pattern));
for i=1:length(pattern)
    % conditional to increase the accuracy of the selected cell
    greater = find(data >= pattern(i));
    less = find(data <= pattern(i));
    
    % 'less' or 'greater' can be empty if the value sits at the edge
    % of a data set
    if isempty(greater)
        greater = less;
        
    elseif isempty(less)
        less = greater;
    end
    
    % Find closest point to value2theta
    right = abs(data(greater(1))-pattern(i));
    
    left = abs(pattern(i) - data(less(end)));
    
    if right <= left
        position(i) = greater(1);
    else
        position(i) = less(end);
    end
end

arraypositions = position;

    