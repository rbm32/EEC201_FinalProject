clear; clc; close all;

%% Test 9 %%
trainFolder = 'GivenSpeech_Data_10/Training_Data';
testFolder = 'GivenSpeech_Data_10/Test_Data';

fs_mel        = 12500;   % Sampling rate used for mel filter bank
p             = 50;      % Number of mel filters
n             = 256;     % FFT length
nc            = 30;      % Number of MFCC coefficients to keep
frameLen      = 256;     % Frame length in samples
overlap       = 128;     % Overlap between frames (in samples)
numCodewords  = 7;       % Desired number of VQ codewords per speaker
epsilon       = 0.0001;    % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001;
keepfirst = false; % Wheter or not keep the first MFCC coefficient

speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);

[predictedLabels, trueLabels, Accuracy] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);
