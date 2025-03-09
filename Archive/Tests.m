%% EEC 201 Final Project

%% Parameters
N_frame = 256;              % length of each frame for spectrogram
Win = kaiser(N_frame, .5);  % Window function for spectrogram
K = 20;                     % number of mel coefficients 
Nover = round(N_frame/3);   % amount of overlap for each frame
M=10;                       % Number of codewords
truncThresh = .95;          % fraction of total energy to keep when truncating recordings
iter = 100;                 % max number of iterations to perform on the LBG algorithm
eps = .00001;               % error threshold for the LBG algorithm


% Get a list of all .wav files in the folder
Fs = 12500; % standard recording frequency
TrainFolder = 'EEC201AudioRecordings\Five Training';
TestFolder = 'EEC201AudioRecordings\Five Test';

[TrainDataRaw, trainSpeakers] = readAudioFromFolder(TrainFolder);
[TestDataRaw, testSpeakers] = readAudioFromFolder(TestFolder);

%% Test 4

TrainData = normalizeVectors(TrainDataRaw);
TestData = normalizeVectors(TestDataRaw);

TrainData = truncateVectorByThreshold(TrainData, truncThresh);
TestData = truncateVectorByThreshold(TestData, truncThresh);

MFCCtrain = {};
tiledlayout('flow')
for i = 1:length(TrainData)
    nexttile;
    MFCCtrain{i} = generateMFCC(TrainData{i}, K, Win, N_frame, Nover, Fs, PlotSpectrogram=true, PlotMelFilterBank=false);
end

%% Tests 5 and 6

CBtrain = {};

for i = 1:length(MFCCtrain)
    CBtrain{i} = trainVQ_LBG(MFCCtrain{i}, M, iter, eps);
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


plotMelCepstrumWithVQ(melCepstrum1, melCepstrum2, codebook1, codebook2, coefIdx1, coefIdx2);

%% Test 7

TrainFolder = 'EEC201AudioRecordings\Five Training';
TestFolder = 'EEC201AudioRecordings\Five Test';
[identifiedSpeakers1, trueSpeakers1, accuracy1] = SpeakerDetection(TrainFolder, TestFolder, truncThresh, K, Win, N_frame, Nover, Fs, M, iter, eps);
display("Accuracy: " + round(accuracy1.*100, 2)+"%");

TrainFolder = 'EEC201AudioRecordings\Eleven Training';
TestFolder = 'EEC201AudioRecordings\Eleven Test';
[identifiedSpeakers2, trueSpeakers2, accuracy2] = SpeakerDetection(TrainFolder, TestFolder, truncThresh, K, Win, N_frame, Nover, Fs, M, iter, eps);
display("Accuracy: " + round(accuracy2.*100, 2)+"%");

