function output = contains(str, pattern)
%CONTAINS This function extends the matlab contains() function. 
%
%   OUTPUT = CONTAINS(STR, PATTERN) 
if isempty(str)
    output = false;
    return
elseif ischar(str)
    str = {str};
end
output = false(1, length(str));
if isempty(pattern)
    output(cellfun(@isempty, str)) = true;
    return
elseif ischar(pattern)
    pattern = {pattern};
end
for i=1:length(str)
    if isempty(str{i})
        output(i) = false;
    elseif isempty(pattern)
        output(i) = false;
    else
        % If any cell in PATTERN matches str{i}, return TRUE
        val = false(1, length(pattern));
        for j=1:length(pattern)
            val(j) = contains(str{i}, pattern{j});
        end
        if ~isempty(find(val,1))
            output(i) = true;
        else
            output(i) = false;
        end
    end
end

end