function truncatedOutput = truncateVectorByThreshold(inputData, thresholdRatio)
    % Input:
    % inputData - The input data, either a numeric vector or a cell array of vectors
    % thresholdRatio - The ratio of the max value used as a threshold (0 to 1)
    
    % Output:
    % truncatedOutput - The truncated vector or a cell array of truncated vectors

    % Check if inputData is a cell array
    if iscell(inputData)
        % Initialize output as a cell array of the same size
        truncatedOutput = cell(size(inputData));
        
        % Iterate over each cell and apply the truncation
        for i = 1:numel(inputData)
            truncatedOutput{i} = truncateSingleVector(inputData{i}, thresholdRatio);
        end
        
    else
        % If inputData is a single vector, apply truncation directly
        truncatedOutput = truncateSingleVector(inputData, thresholdRatio);
    end
end

function truncatedVector = truncateSingleVector(inputVector, thresholdRatio)
    % Helper function to truncate a single vector based on threshold
    
    % Calculate the threshold based on the maximum value of the input vector
    threshold = max(inputVector) * thresholdRatio;
    
    % Find indices where the input vector meets the threshold
    validIndices = find(inputVector >= threshold);
    
    % If no values meet the threshold, return an empty array
    if isempty(validIndices)
        truncatedVector = [];
        return;
    end
    
    % Determine the start and end indices for truncation
    startIdx = min(validIndices);
    endIdx = max(validIndices);
    
    % Truncate the vector
    truncatedVector = inputVector(startIdx:endIdx);
end
