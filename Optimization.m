%% ========================================================================
%  EEC 201 Final Project - Speaker Recognition Optimization
%  University of California, Davis
%
%  Authors: Haodong Liang and Ryan Bruch
%  Modified by: [Your Name]

%  Description:
%  This script optimizes the parameters of a speaker recognition system 
%  using two approaches:
%  
%  1. **Brute Force Search**:
%     - Iterates through all possible parameter combinations.
%     - Evaluates recognition accuracy for each setting.
%     - Stores the best-performing parameter set.
%  
%  2. **Genetic Algorithm (GA) Optimization**:
%     - Uses an evolutionary approach to efficiently find optimal parameters.
%     - Adapts parameter selection over generations to maximize accuracy.
%     - Saves the best-found parameters and accuracy.
%
%  How to Use:
%  1. Ensure all training and testing `.wav` files are stored in correctly 
%     structured folders defined in the `datasets` variable.
%  2. Run the script to perform parameter optimization.
%  3. The script will output and save:
%     - A table of tested parameter combinations and their accuracies.
%     - The best-performing parameter set.
%     - The estimated recognition accuracy for the best parameters.

%% Optimization code


clear; clc; close all;
addpath("SpeechRecognition");
addpath("Functions");
%% Brute Force Approach
fs_mel = 12500;       % sampling rate
epsilon = 0.001;     % splitting factor for the LBG algorithm
distortionThreshold = 0.0001;  % distortion threshold
keepfirst = false;    % whether to keep the first MFCC coefficient

% Define parameter ranges to loop through
p_values             = [50, 60];         % Number of mel filters
n_values             = [512 1024];       % FFT length
nc_values            = [30, 35 40];      % Number of MFCC coefficients to keep
frameLen_values      = [256, 512 1024];  % Frame length 
overlap_values       = [128, 256];       % Overlap between frames
numCodewords_values  = [8 10 12 14 16];  % Number of VQ codewords per speaker

% Define training and testing folders
datasets = {
    {'Data/Speach_Data_2024/Training_Data', 'Data/Speach_Data_2024/Test_Data'},
    {'Data/2024StudentAudioRecording/Zero-Training', 'Data/2024StudentAudioRecording/Zero-Testing'},
    {'Data/2024StudentAudioRecording/Twelve-Training', 'Data/2024StudentAudioRecording/Twelve-Testing'},
    {'Data/2025StudentAudioRecording/Five Training', 'Data/2025StudentAudioRecording/Five Test'},
    {'Data/2025StudentAudioRecording/Eleven Training', 'Data/2025StudentAudioRecording/Eleven Test'}
};


total_loops = length(p_values) * length(n_values) * length(nc_values) * ...
              length(frameLen_values) * length(overlap_values) * length(numCodewords_values);

fprintf('Total number of iterations: %d\n', total_loops);


resultsTable = table();

% progress bar
iteration_count = 0; 
start_time = tic; 
h = waitbar(0, 'Processing Parameter Combinations...');

% Loop over parameter combinations
for p = p_values
    for n = n_values
        for nc = nc_values
            for frameLen = frameLen_values
                for overlap = overlap_values
                    for numCodewords = numCodewords_values

                        % Track progress
                        iteration_count = iteration_count + 1;
                        
                        % Estimate remaining time
                        elapsed_time = toc(start_time); 
                        avg_time_per_iteration = elapsed_time / iteration_count; 
                        remaining_time = avg_time_per_iteration * (total_loops - iteration_count); 
                        estimated_minutes = floor(remaining_time / 60);
                        estimated_seconds = mod(round(remaining_time), 60);
                        
                        % Update progress bar 
                        waitbar(iteration_count / total_loops, h, ...
                            sprintf('Progress: %d/%d (%.2f%%) | Time Left: %02d:%02d min', ...
                            iteration_count, total_loops, (iteration_count / total_loops) * 100, estimated_minutes, estimated_seconds));


                        accuracies = nan(1, length(datasets));  
                        dataset_sizes = nan(1, length(datasets));  % Store the number of elements in each dataset

                        % Iterate over datasets
                        for i = 1:length(datasets)
                            trainFolder = datasets{i}{1};
                            testFolder = datasets{i}{2};

                            try
                                % Train speaker recognition model
                                speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);

                                % Test speaker recognition model
                                [predictedLabels, trueLabels, Accuracy] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

                                % Store accuracy
                                accuracies(i) = Accuracy;
                                dataset_sizes(i) = length(trueLabels); 
                                
                            catch ME
                                % Handle errors
                                fprintf('Error encountered: %s\n', ME.message);
                                fprintf('Skipping combination: p=%d, n=%d, nc=%d, frameLen=%d, overlap=%d, numCodewords=%d\n', ...
                                    p, n, nc, frameLen, overlap, numCodewords);
                                continue;
                            end
                        end

                        % Compute total accuracy
                        valid_indices = ~isnan(accuracies) & ~isnan(dataset_sizes);  
                        if any(valid_indices)
                            total_accuracy = sum(accuracies(valid_indices) .* dataset_sizes(valid_indices)) / sum(dataset_sizes(valid_indices));
                        else
                            total_accuracy = NaN;
                        end

                        % Append results to the table
                        newRow = table(p, n, nc, frameLen, overlap, numCodewords, ...
                                       accuracies(1), accuracies(2), accuracies(3), accuracies(4), total_accuracy, ...
                                       'VariableNames', {'p', 'n', 'nc', 'frameLen', 'overlap', 'numCodewords', ...
                                                         'Accuracy_Zero', 'Accuracy_Twelve', 'Accuracy_Five', 'Accuracy_Eleven', 'Total_Accuracy'});
                        resultsTable = [resultsTable; newRow];

                    end
                end
            end
        end
    end
end

close(h);

% Save results as MAT file
save('OptimizationResults\SpeakerRecognitionResults.mat', 'resultsTable');

disp('Parameter sweep completed. Results saved.');

[bestAccuracy, bestIdx] = max(resultsTable.Total_Accuracy);
if ~isempty(bestIdx)
    bestParameters = resultsTable(bestIdx, :);
    disp('Best Parameter Combination Found:');
    disp(bestParameters);
    
    % Save best result separately
    save('OptimizationResults\BestSpeakerRecognitionResult.mat', 'bestParameters');
end

%% Genetic Algorithm Approach

clear; clc; close all;
addpath("SpeechRecognition");
addpath("Functions");

% Define the number of parameters
numParams = 6;  % (p, n, nc, frameLen, overlap, numCodewords)

% Define the lower and upper bounds for each parameter
lb = [40, 128, 10, 128, 128, 5];    % Lower bounds (integers)
ub = [60, 1000, 30, 512, 256, 50];   % Upper bounds (integers)

% Ensure integer constraints for GA
intCon = 1:numParams;  % All parameters must be integers

% Define your required specific parameter set
specific_initial_guess = [62, 1024, 27, 355, 232, 30];

% Generate the rest of the initial population
num_random_pop = 14;  % Reduce population size for efficiency
random_pop = zeros(num_random_pop, numParams);

for i = 1:numParams
    random_pop(:, i) = randi([lb(i), ub(i)], num_random_pop, 1); % Generate random values within bounds
end

% Ensure one of them is exactly the specified values
initialPopulation = [specific_initial_guess; random_pop];

% Define the fitness function (minimize negative accuracy)
fitnessFcn = @(x) evaluateParameters(x(1), x(2), x(3), x(4), x(5), x(6));

% Open parallel pool if not already open
if isempty(gcp('nocreate'))
    parpool('local');
end

% Set GA options, including the initial population
options = optimoptions('ga', ...
    'PopulationSize', 15, ... % Reduce total population size
    'MaxGenerations', 80, ... % Reduce max generations for efficiency
    'EliteCount', 7, ... % Preserve top 7 candidates each generation
    'CrossoverFraction', 0.2, ... % Increase crossover fraction
    'MutationFcn', {@mutationadaptfeasible, 0.2}, ... % Reduce mutation rate
    'SelectionFcn', @selectiontournament, ... % Tournament selection
    'Display', 'iter', ...
    'UseParallel', true, ...
    'InitialPopulationMatrix', initialPopulation); % Ensure correct first guesses


% Run Genetic Algorithm Optimization
[bestParams, bestAccuracy] = ga(fitnessFcn, numParams, [], [], [], [], lb, ub, [], intCon, options);

% Store results in a table
bestParamsTable = table(bestParams(1), bestParams(2), bestParams(3), bestParams(4), bestParams(5), bestParams(6), -bestAccuracy, ...
    'VariableNames', {'p', 'n', 'nc', 'frameLen', 'overlap', 'numCodewords', 'Total_Accuracy'});

% Save to .mat file
save('OptimizationResults\BestGAParameters.mat', 'bestParamsTable');

% Display Best Found Parameters
fprintf('\n=== Best Parameters Found ===\n');
fprintf('p = %d, n = %d, nc = %d, frameLen = %d, overlap = %d, numCodewords = %d\n', ...
        bestParams(1), bestParams(2), bestParams(3), bestParams(4), bestParams(5), bestParams(6));
fprintf('Best Accuracy Achieved: %.4f\n', -bestAccuracy);
fprintf('Best parameters have been saved in BestGAParameters.mat\n');


%% Optimized Fitness Function
type evaluateParameters.m
function totalAccuracy = evaluateParameters(p, n, nc, frameLen, overlap, numCodewords)
    persistent cache
    if isempty(cache)
        cache = containers.Map('KeyType', 'char', 'ValueType', 'double');
    end
    key = sprintf('%d_%d_%d_%d_%d_%d', p, n, nc, frameLen, overlap, numCodewords);
    if isKey(cache, key)
        totalAccuracy = cache(key);
        return;
    end

    fs_mel = 12500;       
    epsilon = 0.0001;    
    distortionThreshold = 0.000001;
    keepfirst = false;

    datasets = {
        {'Data/Speach_Data_2024/Training_Data', 'Data/Speach_Data_2024/Test_Data'},
        {'Data/2024StudentAudioRecording/Zero-Training', 'Data/2024StudentAudioRecording/Zero-Testing'},
        {'Data/2024StudentAudioRecording/Twelve-Training', 'Data/2024StudentAudioRecording/Twelve-Testing'},
        {'Data/2025StudentAudioRecording/Five Training', 'Data/2025StudentAudioRecording/Five Test'},
        {'Data/2025StudentAudioRecording/Eleven Training', 'Data/2025StudentAudioRecording/Eleven Test'}
    };

    accuracies = nan(1, length(datasets));  
    dataset_sizes = zeros(1, length(datasets)); % Preallocate with zeros

    parfor i = 1:length(datasets)
        trainFolder = datasets{i}{1};
        testFolder = datasets{i}{2};

        try
            % Train speaker recognition model
            speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
            
            % Test speaker recognition model
            [predictedLabels, trueLabels, Accuracy] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

            accuracies(i) = Accuracy;
            dataset_sizes(i) = length(trueLabels);
        catch
            accuracies(i) = NaN; % Assign NaN instead of returning
            dataset_sizes(i) = 0; % Ensure sizes are properly handled
        end
    end

    valid_indices = ~isnan(accuracies) & (dataset_sizes > 0);
    if any(valid_indices)
        totalAccuracy = sum(accuracies(valid_indices) .* dataset_sizes(valid_indices)) / sum(dataset_sizes(valid_indices));
    else
        totalAccuracy = -1e3; % If all values failed, return NaN
    end
    fprintf('Accuracy: %d\n', totalAccuracy);
    totalAccuracy = -totalAccuracy; % Negate for GA minimization
    
    cache(key) = totalAccuracy; % Store result to avoid recomputation
end
