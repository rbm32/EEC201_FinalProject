function codebook = trainVQCodebook(features, numCodewords, epsilon, distortionThreshold)
% trainVQCodebook  Train a VQ codebook using the Linde-Buzo-Gray algorithm.
%
%   codebook = trainVQCodebook(features, numCodewords, epsilon)
%
%   Inputs:
%       features    - (N x d) matrix, where each row is a d-dimensional
%                     feature vector (e.g., an MFCC vector).
%       numCodewords- Desired number of codewords in the codebook (M).
%       epsilon     - Splitting perturbation factor (e.g., 0.01).
%       distortionThreshold - Threshold to check convergence
%
%   Output:
%       codebook    - (M x d) matrix of the final codewords after LBG training.
%
%   Algorithm Steps:
%   1) Initialize codebook with the centroid of all feature vectors.
%   2) Split each codeword by +/- epsilon.
%   3) Assign each feature vector to its nearest codeword.
%   4) Update each codeword as the centroid of assigned vectors.
%   5) Repeat until desired number of codewords is reached or distortion
%      improvement is below a threshold.

    % Number of feature vectors (N) and their dimension (d).
    [N, d] = size(features);

    % --- Step 1: Initialize with a single centroid ---
    codebook = mean(features, 1);  % (1 x d)
    
    % Keep splitting until we have the desired number of codewords
    while size(codebook, 1) < numCodewords
        
        % --- Step 2: Splitting ---
        % For each codeword, create two codewords with a small perturbation.
        newCodebook = [];
        for i = 1:size(codebook, 1)
            cw = codebook(i, :);
            newCodebook = [newCodebook; cw*(1+epsilon); cw*(1-epsilon)];
        end
        codebook = newCodebook;  % Now we have doubled the codebook size
        
        % --- Step 3 & 4: Iterations (Assignment & Update) ---
        prevDistortion = Inf;
        while true
            % Assign each feature vector to the nearest codeword
            assignments = zeros(N, 1);
            totalDistortion = 0;
            for j = 1:N
                vec = features(j, :);
                % Euclidean distance to each codeword
                dists = sum((codebook - vec).^2, 2);
                [minDist, nearest] = min(dists);
                assignments(j) = nearest;
                totalDistortion = totalDistortion + minDist;
            end
            avgDistortion = totalDistortion / N;
            
            % Check for convergence
            if abs(prevDistortion - avgDistortion) < distortionThreshold
                break;
            end
            prevDistortion = avgDistortion;
            
            % Update codewords (centroids of assigned vectors)
            for i = 1:size(codebook, 1)
                idx = (assignments == i);
                if any(idx)
                    codebook(i, :) = mean(features(idx, :), 1);
                end
            end
        end
        
        % If we exceeded the desired number, truncate extra codewords
        if size(codebook, 1) > numCodewords
            codebook = codebook(1:numCodewords, :);
        end
    end
end
