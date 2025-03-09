function normalizedCell = normalizeVectors(cellArray)
    % Check if the input is a cell array
    if ~iscell(cellArray)
        error('Input must be a cell array.');
    end
    
    % Initialize the output cell array
    normalizedCell = cell(size(cellArray));
    
    % Iterate through each cell
    for i = 1:numel(cellArray)
        vec = cellArray{i};
        if isnumeric(vec) && ~isempty(vec)
            maxVal = max(vec);
            if maxVal ~= 0
                normalizedCell{i} = vec / maxVal;
            else
                normalizedCell{i} = vec; % Avoid division by zero
            end
        else
            normalizedCell{i} = vec; % Keep non-numeric or empty cells unchanged
        end
    end
end

% Example usage:
% cellArray = {[1, 2, 3], [4, 5, 6], [7, 8, 9]};
% normalizedCell = normalize_vectors(cellArray);
% disp(normalizedCell);
