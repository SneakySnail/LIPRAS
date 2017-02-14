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
    
    greatest = greater(1);
    least = less(end);
    % Find closest point to value2theta
    right = abs(data(greatest)-pattern(i));
    if abs(data(greater(end))-pattern(i)) < right
        greatest = greater(end);
        right = data(greatest)-pattern(i);
    end
    left = abs(pattern(i) - data(least));
    if abs(pattern(i)-data(less(1))) < left
        least = less(1);
        left = abs(pattern(i)-data(least));
    end
    
    if right <= left
        position(i) = greatest;
    else
        position(i) = least;
    end
end

arraypositions = position;

    