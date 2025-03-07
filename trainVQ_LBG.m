function [codebook, distortion] = trainVQ_LBG(trainingData, numCodebookVectors, maxIter, epsilon)
    % trainVQ_LBG Trains a VQ codebook using the Linde-Buzo-Gray (LBG) algorithm
    %
    % Inputs:
    %   trainingData     - Matrix of training data (each column is a data vector)
    %   numCodebookVectors - Number of codebook vectors (codebook size)
    %   maxIter          - Maximum number of iterations for LBG algorithm
    %   epsilon          - Convergence threshold (stop when change in centroids is smaller than epsilon)
    %
    % Outputs:
    %   codebook         - Final VQ codebook (codebook vectors, where each row is a codeword)
    %   distortion       - Final distortion (mean squared error)

    % Get the number of features (rows) and number of training vectors (columns)
    [numFeatures, numSamples] = size(trainingData);
    
    % Step 1: Initialize the codebook with a deterministic subset of the training data
    % Instead of random selection, pick the first numCodebookVectors columns
    if numCodebookVectors > numSamples
        error('Number of codebook vectors cannot exceed the number of training samples.');
    end
    codebook = trainingData(:, 1:numCodebookVectors);
    
    % Step 2: Set initial distortion and iteration count
    distortion = inf;  % Start with a large distortion value
    iter = 0;
    
    % Main LBG algorithm loop
    while iter < maxIter
        iter = iter + 1;
        
        % Step 3: Assign each data vector to the nearest centroid (codebook vector)
        indices = assignToCodebook(trainingData, codebook);
        
        % Step 4: Update the centroids (codebook vectors)
        newCodebook = updateCodebook(trainingData, indices, numCodebookVectors);
        
        % Step 5: Compute the new distortion (mean squared error)
        newDistortion = computeDistortion(trainingData, newCodebook, indices);
        
        % Check for convergence (distortion change is below epsilon)
        if abs(distortion - newDistortion) < epsilon
            break;
        end
        
        % Update the codebook and distortion for the next iteration
        codebook = newCodebook;
        distortion = newDistortion;
    end
    
    % Codebook is already in the correct orientation: numCodebookVectors x numFeatures
end

% Helper function: Assign each data vector to the closest codebook vector
function indices = assignToCodebook(data, codebook)
    % Compute the distance between each data vector and all codebook vectors
    distances = pdist2(data', codebook');
    
    % Assign each data vector to the nearest codebook vector (minimum distance)
    [~, indices] = min(distances, [], 2);
end

% Helper function: Update the codebook by averaging the data vectors assigned to each centroid
function newCodebook = updateCodebook(data, indices, numCodebookVectors)
    % Initialize new codebook
    newCodebook = zeros(size(data, 1), numCodebookVectors);
    
    for i = 1:numCodebookVectors
        % Find the data vectors assigned to this codebook vector
        assignedData = data(:, indices == i);
        
        % Update the codebook vector to be the average of the assigned data
        if ~isempty(assignedData)
            newCodebook(:, i) = mean(assignedData, 2);
        end
    end
end

% Helper function: Compute the distortion (mean squared error)
function distortion = computeDistortion(data, codebook, indices)
    numDataVectors = size(data, 2);
    distortion = 0;
    
    for i = 1:numDataVectors
        distortion = distortion + sum((data(:, i) - codebook(:, indices(i))).^2);
    end
    
    % Compute the mean squared error
    distortion = distortion / numDataVectors;
end
