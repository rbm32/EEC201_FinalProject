clear; clc; close all;

%% Test 10a %%

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

trainFolder = '2024StudentAudioRecording/Zero-Training';
testFolder = '2024StudentAudioRecording/Zero-Testing';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels1, trueLabels1, Accuracy1] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = '2024StudentAudioRecording/Twelve-Training';
testFolder = '2024StudentAudioRecording/Twelve-Testing';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels2, trueLabels2, Accuracy2] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = '2024StudentAudioRecording/All-Training';
testFolder = '2024StudentAudioRecording/All-Testing';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels3, trueLabels3, Accuracy3] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

%% Test10b %%
trainFolder = '2025StudentAudioRecording/Five Training';
testFolder = '2025StudentAudioRecording/Five Test';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels4, trueLabels4, Accuracy4] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);

trainFolder = '2025StudentAudioRecording/Eleven Training';
testFolder = '2025StudentAudioRecording/Eleven Test';
speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);
[predictedLabels5, trueLabels5, Accuracy5] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);
