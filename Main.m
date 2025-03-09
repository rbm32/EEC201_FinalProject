clear; clc; close all;
addpath("SpeechRecognition");
addpath("Functions");

fs_mel        = 12500;   % Sampling rate used for mel filter bank
p             = 50;      % Number of mel filters
n             = 256;     % FFT length
nc            = 20;      % Number of MFCC coefficients to keep
frameLen      = 256;     % Frame length in samples
overlap       = 128;     % Overlap between frames (in samples)
numCodewords  = 8;       % Desired number of VQ codewords per speaker
epsilon       = 0.0001;    % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001;
keepfirst = false; % Whether or not keep the first MFCC coefficient

trainFolder = 'Data/2024StudentAudioRecording/Zero-Training';
testFolder = 'Data/2024StudentAudioRecording/Zero-Testing';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels1, trueLabels1, Accuracy1] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = 'Data/2024StudentAudioRecording/Twelve-Training';
testFolder = 'Data/2024StudentAudioRecording/Twelve-Testing';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels2, trueLabels2, Accuracy2] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);
