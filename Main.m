%% EEC 201 Final Project

%% Download the speach files

playAudioRecording = false; % Set to TRUE if you want to hear all audio recordings played

% Get a list of all .wav files in the folder
Fs = 12500; % standard recording frequency
Ts = 1/Fs;
% note that the readAudioFromFolder function only keeps one audio channel
[TrainDataFull, trainSpeakers] = readAudioFromFolder('Speach_Data_2024\Training_Data');
[TestDataFull, testSpeakers] = readAudioFromFolder('Speach_Data_2024\Test_Data');




% play Training Data
if playAudioRecording
    for i = 1:length(TrainData)
        audioPlayer = audioplayer(TrainData{i},Fs);
        playblocking(audioPlayer)
    end
    
    % play Test Data
    for i = 1:length(TestData)
        audioPlayer = audioplayer(TestData{i},Fs);
        playblocking(audioPlayer)
    end
end


%%
%% Parameters
N_frame = 128;              % length of each frame
Win = kaiser(N_frame, .5);  % Window function
K = 10;                     % number of mel coefficients 
Nover = round(N_frame/3);   % amount of overlap for each frame
M=7;                        % Number of codewords
truncThresh = .2;           % Threshold to truncate the time-domain signals
iter = 5e3;                 % max number of iterations to perform on the LBG algorithm
eps = .00001;               % error threshold for the LBG algorithm
%%

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


% uncomment this if you want to see the 2d clustering of the mel
% coefficients
% plotMelCepstrumWithVQ(melCepstrum1, melCepstrum2, codebook1, codebook2, coefIdx1, coefIdx2);

%% Attempt to identify the speaker

correctGuesses = [];
identifiedSpeaker = [];
for i=1:length(TestData)
    [identifiedSpeaker(i)] = findBestCodebook(MFCCtrain{i}, CBtrain);
    correctGuesses(i) = identifiedSpeaker(i) == i;
end

accuracy = sum(correctGuesses) ./ length(correctGuesses)

