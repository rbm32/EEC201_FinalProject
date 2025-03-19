%% ========================================================================
%  EEC 201 Final Project - Speaker Recognition Optimization
%  University of California, Davis
%
%  Authors: Haodong Liang and Ryan Bruch

%  Description:
% This script implements a speaker recognition system. The system 
% extracts MFCC features from training audio data, builds a speaker model 
% (codebook) using the Linde-Buzo-Gray (LBG) algorithm, and evaluates the 
% model using test data

%  How to Use:
%  1. Update `trainFolders` and `testFolders` with paths to folders 
%     containing `.wav` files for each speaker.
%  2. Ensure that each speaker's `.wav` files have matching filenames 
%     in both the training and testing folders.
%  3. Run the script to train the system and evaluate speaker recognition.
%  4. The script will display individual and overall recognition accuracy.

%% -----------------------------------
% EEC 201 Final Project Main Script
% By Haodong Liang and Ryan Bruch

clear; clc; close all;
addpath("SpeechRecognition");
addpath("Functions");

fs_mel       = 12500;  % Sampling rate used for mel filter bank
p            = 62;     % Number of mel filters
n            = 1024;   % FFT length
nc           = 27;     % Number of MFCC coefficients to keep
frameLen     = 355;    % Frame length in samples
overlap      = 232;    % Overlap between frames (in samples)
numCodewords = 30;     % Desired number of VQ codewords per speaker
epsilon      = 0.0001; % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001; % Convergence Threshold for the LBG algorithm
keepfirst = false; % Whether or not keep the first MFCC coefficient

% Define training and testing folder paths in cell arrays
trainFolders = {...
    'Data/Speach_Data_2024/Training_Data', ...
    'Data/2024StudentAudioRecording/Zero-Training', ...
    'Data/2024StudentAudioRecording/Twelve-Training', ...
    'Data/2025StudentAudioRecording/Five Training', ...
    'Data/2025StudentAudioRecording/Eleven Training'};

testFolders = {...
    'Data/Speach_Data_2024/Test_Data', ...
    'Data/2024StudentAudioRecording/Zero-Testing', ...
    'Data/2024StudentAudioRecording/Twelve-Testing', ...
    'Data/2025StudentAudioRecording/Five Test', ...
    'Data/2025StudentAudioRecording/Eleven Test'};

% Initialize results storage
numSets = length(trainFolders);
predictedLabels = cell(1, numSets);
trueLabels = cell(1, numSets);
accuracies = zeros(1, numSets);

% Loop through training and testing sets
for i = 1:numSets
    trainFolder = trainFolders{i};
    testFolder = testFolders{i};

    speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
    [predictedLabels{i}, trueLabels{i}, accuracies(i)] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);
end

% Compute overall accuracy
totalCorrect = sum(cellfun(@(pred, true) sum(pred == true), predictedLabels, trueLabels));
totalSpeakers = sum(cellfun(@length, trueLabels));

accuracyPercentage = (totalCorrect / totalSpeakers) * 100;

% Display the total summary
fprintf('----------------------------------------\n');
fprintf('      Total Speaker Recognition Results  \n');
fprintf('----------------------------------------\n');
fprintf('Total Correctly Identified Speakers: %d\n', totalCorrect);
fprintf('Total Number of Speakers: %d\n', totalSpeakers);
fprintf('Overall Accuracy: %.2f%%\n', accuracyPercentage);
fprintf('----------------------------------------\n');
