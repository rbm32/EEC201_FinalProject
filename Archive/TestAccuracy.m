
playAudioRecording = false; % Set to TRUE if you want to hear all audio recordings played

% Get a list of all .wav files in the folder
Fs = 12500; % standard recording frequency
Ts = 1/Fs;
% note that the readAudioFromFolder function only keeps one audio channel
[TrainDataFull, trainSpeakers] = readAudioFromFolder('Speach_Data_2024\Training_Data');
[TestDataFull, testSpeakers] = readAudioFromFolder('Speach_Data_2024\Test_Data');


%% Parameters
N_frame = 128;              % length of each frame
Win = kaiser(N_frame, .5);  % Window function
K = 10;                     % number of mel coefficients 
Nover = round(N_frame/3);   % amount of overlap for each frame
M=7;
truncThresh = .2;
iter = 5e3;
eps = .00001;

results = {};
k =1;
for N_frame = 2.^([6 7 8 9])
    for
    
    accuracy(i) = GenerateAccuracy(TrainDataFull, truncThresh, TestDataFull, K, Win, N_frame, Nover, Fs, M, iter, eps);
    

    k = k+1
end


%%

function [accuracy] = GenerateAccuracy(TrainDataFull, truncThresh, TestDataFull, K, Win, N_frame, Nover, Fs, M, iter, eps)
TrainData = truncateVectorByThreshold(TrainDataFull, truncThresh);
TestData = truncateVectorByThreshold(TestDataFull, truncThresh);

%%
MFCCtrain = {};
MFCCtest = {};
for i = 1:length(TrainData)
    MFCCtrain{i} = generateMFCC(TrainData{i}, K, Win, N_frame, Nover, Fs, PlotSpectrogram=false, PlotMelFilterBank=false);
end

for i = 1:length(TestData)
    MFCCTest{i} = generateMFCC(TestData{i}, K, Win, N_frame, Nover, Fs, PlotSpectrogram=false, PlotMelFilterBank=false);
end


%% Generate a codebook for each speaker
CBtrain = {};
CBtest = {};

for i = 1:length(MFCCtrain)
    CBtrain{i} = trainVQ_LBG(MFCCtrain{i}, M, iter, eps);
end


for i = 1:length(MFCCtest)
    CBtest{i} = trainVQ_LBG(MFCCtest{i}, K-1, iter, eps);
end

% Compare MFCC between two speakers
speaker1 = 1;
speaker2 = 2;
coefIdx1 = 1;
coefIdx2 = 2;

melCepstrum1 = MFCCtrain{speaker1};
melCepstrum2 = MFCCtrain{speaker2};

codebook1 = CBtrain{speaker1};
codebook2 = CBtrain{speaker2};


% plotMelCepstrumWithVQ(melCepstrum1, melCepstrum2, codebook1, codebook2, coefIdx1, coefIdx2);

%%
MFCC1 = MFCCtrain{1};
CB1 = CBtrain{1};
correctGuesses = [];
identifiedSpeaker = [];
for i=1:length(TestData)
    [identifiedSpeaker(i)] = findBestCodebook(MFCCtrain{i}, CBtrain);
    correctGuesses(i) = identifiedSpeaker(i) == i;
end

accuracy = sum(correctGuesses) ./ length(correctGuesses)
end