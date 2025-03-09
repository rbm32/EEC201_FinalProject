function bestCodebookIndex = findBestCodebook(MFCC, codebooks)
    % Input:
    % MFCC - A matrix of MFCCs with dimensions (numCoefficients x numFrames)
    % codebooks - A cell array of codebooks, where each element is a matrix 
    %             of size (numCoefficients x numCodebookVectors)
    
    % Output:
    % bestCodebookIndex - Index of the codebook in the cell array that results in 
    %                      the least total distance
    
    numCodebooks = length(codebooks);  % Number of codebooks in the cell array
    totalDistances = zeros(numCodebooks, 1);  % Array to store the total distances for each codebook
    
    % Loop through each codebook in the cell array
    for i = 1:numCodebooks
        % Get the current codebook
        codebook = codebooks{i};
        
        % Compute the Euclidean distance between the MFCC matrix and the current codebook
        distances = computeEuclideanDistance(MFCC, codebook);
        
        % Calculate the total distance by summing all the distances
        totalDistances(i) = sum(min(distances));  % Sum all distances to get the total
        
    end
    
    % Find the index of the codebook with the least total distance
    [~, bestCodebookIndex] = min(totalDistances);
end



function distances = computeEuclideanDistance(MFCC, codebook)
    % Input:
    % MFCC - A matrix of MFCCs with dimensions (numCoefficients x numFrames)
    % codebook - A matrix representing the codebook with dimensions (numCoefficients x numCodebookVectors)
    
    % Output:
    % distances - A matrix of distances with dimensions (numFrames x numCodebookVectors)
    
    % Get the number of frames in the MFCC matrix and the number of codebook vectors
    [numCoefficients, numFrames] = size(MFCC);
    [numCoefficientsCodebook, numCodebookVectors] = size(codebook);
    
    % Check if the number of coefficients in MFCC matches the number of coefficients in the codebook
    if numCoefficients ~= numCoefficientsCodebook
        error('Number of coefficients in MFCC and codebook do not match.');
    end
    
    % Initialize the distance matrix
    distances = zeros(numFrames, numCodebookVectors);
    
    % Loop through each frame in the MFCC matrix
    for i = 1:numFrames
        % Extract the current MFCC vector (frame)
        mfccFrame = MFCC(:, i);
        
        % Compute the Euclidean distance between the current MFCC frame and each codebook vector
        for j = 1:numCodebookVectors
            codebookVector = codebook(:, j);
            % Euclidean distance formula: sqrt(sum((x - y).^2))
            distances(i, j) = sqrt(sum((mfccFrame - codebookVector).^2));
        end
    end
end