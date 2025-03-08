clear; clc; close all;

%% Test 7 and 8 %%
clear; clc; close all;

%% Parameters
trainFolder    = 'GivenSpeech_Data/Training_Data';
testFolder     = 'GivenSpeech_Data/Test_Data';
fs_mel        = 12500;   % Sampling rate used for mel filter bank
p             = 50;      % Number of mel filters
n             = 256;     % FFT length
nc            = 30;      % Number of MFCC coefficients to keep
frameLen      = 256;     % Frame length in samples
overlap       = 128;     % Overlap between frames (in samples)
numCodewords  = 7;       % Desired number of VQ codewords per speaker
epsilon       = 0.0001;    % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001;
keepfirst      = false;

%% ----------------- Training Phase -----------------
[speechFiles_train, speechData_train, speechData_norm_train, freqData_train] = loadSpeechData(trainFolder);
speechData_trunc_train = truncateVectorByThreshold(speechData_norm_train, 0.2);
numSpeakers = length(speechFiles_train);

% Train a VQ codebook for each speaker
speakerCodebook = cell(numSpeakers, 1);
for i = 1:numSpeakers
    speech = speechData_trunc_train{i};
    fs_speech = freqData_train{i};
    
    % Compute MFCC frames (each column is a frame); transpose so each row is one feature vector.
    C = mfcc_frames(speech, fs_speech, fs_mel, p, n, nc, frameLen, overlap, keepfirst)';
    
    % Train VQ codebook using the LBG algorithm
    codebook = trainVQCodebook(C, numCodewords, epsilon, distortionThreshold);
    speakerCodebook{i} = codebook;
end

%% ----------------- Testing Phase on Unfiltered Data -----------------
[speechFiles_test, speechData_test, speechData_norm_test, freqData_test] = loadSpeechData(testFolder);
speechData_trunc_test = truncateVectorByThreshold(speechData_norm_test, 0.2);
numTest = length(speechFiles_test);

predictedLabels = zeros(numTest, 1);
trueLabels = zeros(numTest, 1);

for i = 1:numTest
    speech = speechData_trunc_test{i};
    fs_speech = freqData_test{i};
    
    % Compute MFCC frames for test utterance (each row is one feature vector)
    C = mfcc_frames(speech, fs_speech, fs_mel, p, n, nc, frameLen, overlap, keepfirst)';
    
    % Compute average distortion to each speaker's codebook.
    distortions = zeros(numSpeakers, 1);
    for sp = 1:numSpeakers
        cb = speakerCodebook{sp};  % Each row of cb is a codeword.
        numFramesTest = size(C, 1);
        totalDist = 0;
        for j = 1:numFramesTest
            frame = C(j, :);
            dists = sqrt(sum((cb - frame).^2, 2));
            totalDist = totalDist + min(dists);
        end
        distortions(sp) = totalDist / numFramesTest;
    end
    [~, recognizedSpeaker] = min(distortions);
    predictedLabels(i) = recognizedSpeaker;
    
    trueLabels(i) = i;  
end

origAccuracy = sum(predictedLabels == trueLabels) / numTest;
fprintf('Original (Unfiltered) Test Accuracy: %.2f%%\n', origAccuracy*100);

%% ----------------- Testing Phase on Notch-Filtered Data -----------------
% Define a set of notch filter center frequencies (in Hz)
notchFrequencies = [800, 1000, 1200, 1400];
notchAccuracies = zeros(length(notchFrequencies), 1);

for nf = 1:length(notchFrequencies)
    notchFreq = notchFrequencies(nf);
    % W0: normalized frequency )
    W0 = notchFreq / (fs_mel/2);  
    BW = 0.01;
    [b, a] = iirnotch(W0, BW);
    fs = 12500;
    figure;
    freqz(b, a, 1024, fs);
    title(sprintf('Notch Filter Frequency Response @ %d Hz', notchFreq));
    predictedLabelsNotch = zeros(numTest, 1);
    for i = 1:numTest
        speech = speechData_trunc_test{i};
        % Apply the notch filter to the test signal.
        speechFiltered = filter(b, a, speech);
        fs_speech = freqData_test{i};
        
        % Compute MFCC frames on the notch-filtered signal.
        C = mfcc_frames(speechFiltered, fs_speech, fs_mel, p, n, nc, frameLen, overlap, keepfirst)';
        
        % Compute average distortion to each speaker's codebook.
        distortions = zeros(numSpeakers, 1);
        numFramesTest = size(C, 1);
        for sp = 1:numSpeakers
            cb = speakerCodebook{sp};
            totalDist = 0;
            for j = 1:numFramesTest
                frame = C(j, :);
                dists = sqrt(sum((cb - frame).^2, 2));
                totalDist = totalDist + min(dists);
            end
            distortions(sp) = totalDist / numFramesTest;
        end
        
        [~, recognizedSpeaker] = min(distortions);
        predictedLabelsNotch(i) = recognizedSpeaker;
    end
    
    acc = sum(predictedLabelsNotch == trueLabels) / numTest;
    notchAccuracies(nf) = acc;
    fprintf('Notch Frequency %d Hz: Test Accuracy = %.2f%%\n', notchFreq, acc*100);
end

fprintf('\nSummary of Recognition Accuracy:\n');
fprintf('Original Unfiltered: %.2f%%\n', origAccuracy*100);
for nf = 1:length(notchFrequencies)
    fprintf('Notch Filter @ %d Hz: %.2f%%\n', notchFrequencies(nf), notchAccuracies(nf)*100);
end

