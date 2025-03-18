clear; clc; close all;
addpath("SpeechRecognition");
addpath("Functions");

fs_mel       = 12500;  % Sampling rate used for mel filter bank
fs_mel       = 12500;  % Sampling rate used for mel filter bank
p            = 62;     % Number of mel filters
n            = 1024;    % FFT length
nc           = 27;     % Number of MFCC coefficients to keep
frameLen     = 355;    % Frame length in samples
overlap      = 232;    % Overlap between frames (in samples)
numCodewords = 30;      % Desired number of VQ codewords per speaker
epsilon      = 0.0001; % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001; % Convergence Threshold for the LBG algorithm
keepfirst = false; % Whether or not keep the first MFCC coefficient
  
    
trainFolder = 'Data/Speach_Data_2024/Training_Data';
testFolder = 'Data/Speach_Data_2024/Test_Data';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels0, trueLabels0, Accuracy0] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = 'Data/2024StudentAudioRecording/Zero-Training';
testFolder = 'Data/2024StudentAudioRecording/Zero-Testing';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels1, trueLabels1, Accuracy1] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = 'Data/2024StudentAudioRecording/Twelve-Training';
testFolder = 'Data/2024StudentAudioRecording/Twelve-Testing';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels2, trueLabels2, Accuracy2] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = 'Data/2025StudentAudioRecording/Five Training';
testFolder = 'Data/2025StudentAudioRecording/Five Test';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels4, trueLabels4, Accuracy4] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = 'Data/2025StudentAudioRecording/Eleven Training';
testFolder = 'Data/2025StudentAudioRecording/Eleven Test';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels5, trueLabels5, Accuracy5] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

