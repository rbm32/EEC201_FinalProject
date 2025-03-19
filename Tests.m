%% ========================================================================
%  EEC 201 Final Project - Individual Speaker Recognition Tests
%  University of California, Davis
%
%  Authors: Haodong Liang and Ryan Bruch

%  Description:
%  This script allows for the execution of each individual test 
%  rather than running a full automated training and evaluation pipeline

%  How to Use:
%  1. Update `trainFolder` and `testFolder` with the correct dataset paths.
%  2. Adjust the `idx` variable to specify which speech files to process.
%  3. Run the script to visualize and analyze speaker data.
%  4. Use the different test sections to debug and fine-tune speaker recognition models.

clear; clc; close all;
addpath("Functions\")
addpath("SpeechRecognition\")

idx = [1 2 3 4];
%% Initialize training and testing data
trainFolder = 'Data/Speach_Data_2024/Training_Data';
testFolder = 'Data/Speach_Data_2024/Test_Data';

[speechFilesFull, speechDataFull, speechData_normFull, freqDataFull] = loadSpeechData(trainFolder);

speechFiles = speechFilesFull(idx);
speechData = speechDataFull(idx);
speechData_norm = speechData_normFull(idx);
freqData = freqDataFull(idx);

speechData_trunc = truncateVectorByThreshold(speechData_norm, 0.2);
%% Test 2
figure;
tiledlayout('flow');
for i = 1:length(speechFiles)
    s = speechData{i};
    fs = freqData{i};
    t = (0:length(s)-1) / fs;
    nexttile
    plot(t, s);
    title(sprintf('Wave %s', speechFiles(i).name));
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-2,2]);
end
sgtitle('Time-Domain Speech Signals (Training Data)');

% Normalized signal
figure;
tiledlayout('flow');
for i = 1:length(speechFiles)
    s = speechData_norm{i};
    fs = freqData{i};
    t = (0:length(s)-1) / fs;
    nexttile
    plot(t, s);
    title(sprintf('Wave %s', speechFiles(i).name));
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-2,2]);
end
sgtitle('Normalized Time-Domain Speech Signals (Training Data)');

% Truncated signal
figure;
tiledlayout('flow');
for i = 1:length(speechFiles)
    s = speechData_trunc{i};
    fs = freqData{i};
    t = (0:length(s)-1) / fs;
    nexttile
    plot(t, s);
    title(sprintf('Wave %s', speechFiles(i).name));
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-2,2]);
end
% sgtitle('Truncated Time-Domain Speech Signals (Training Data)');

%% Use STFT to generate spectrogram
frameSizes = [128, 256, 512];

for k = 1:length(frameSizes)
    N = frameSizes(k);    % Window length
    M = round(N/3);       % Frame increment
    
    figure('Position', [50, 50, 1400, 800]);
    tiledlayout('flow');
    
    for i = 1:length(speechFiles)
        s = speechData_trunc{i};
        fs = freqData{i};
        numFrames = floor((length(s) - N) / M) + 1;
        nfft = N;  
        % Preallocate matrix for STFT magnitude (in dB)
        S = zeros(floor(nfft/2)+1, numFrames);
        w = hamming(N);
        % Compute STFT for each frame
        for j = 1:numFrames
            idx = (j-1)*M + (1:N);
            frame = s(idx) .* w;
            X = fft(frame, nfft);
            S(:, j) = 20*log10(abs(X(1:floor(nfft/2)+1)));
        end
        
        t = ((0:numFrames-1)*M + N/2) / fs;
        f = linspace(0, fs/2, floor(nfft/2)+1);
      
        nexttile
        imagesc(t, f, S);
        axis xy;
        cb = colorbar;
        title(cb, 'dB');  
        title(sprintf('w%d, N = %d', i, N));
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
    end
    sgtitle(sprintf('STFT with Window Length N = %d, Frame Increment M = %d', N, M));
end

%% Test 3 %%
p = 20;            % Number of mel filters
n = 256;           % FFT length
fs = 12500;        % Frequency for mel-spaced filterbank

f = linspace(0, fs/2, 1+floor(n/2));

m = melfb(p, n, fs);  % returns a sparse matrix (p x (1+floor(n/2)))

figure;
plot(f, full(m)');  % Convert sparse matrix to full for plotting
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Mel-Spaced Filter Bank Responses');
grid on;

%% Compute and Plot Spectrum Before and After Mel-Frequency Warping
figure('Position', [50, 50, 1600, 1000]);
tiledlayout('flow');
for i = 1:length(speechFiles)
    nexttile;;
    speech = speechData_trunc{i};
    
    % Compute the FFT using n points and obtain the power spectrum (only half + DC)
    S = fft(speech, n);
    S_mag = abs(S(1:1+floor(n/2))).^2;
    
    % Apply the mel filter bank to get the mel-spectrum (energy per mel band)
    mel_spectrum = m * S_mag;
    
    % Compute the approximate center frequency for each mel filter
    center_freqs = zeros(p,1);
    for j = 1:p
        center_freqs(j) = sum(f .* full(m(j,:))) / (sum(full(m(j,:))));
    end
    
    hold on;
    plot(f,  10 * log10(S_mag), 'b-', 'LineWidth', 1.2);
    plot(center_freqs, 10 * log10(mel_spectrum), 'ro-', 'LineWidth', 1.5);
    hold off;
    
    title(sprintf('%s', speechFiles(i).name), 'Interpreter', 'none');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;
    legend('Original Spectrum', 'Mel-Wrapped Spectrum', 'Location', 'best');
end

% subtitle('Before and After Mel-Frequency Warping Spectrum for All Training Speeches (1 frame)');

%% Test 4 %%
nc = 13;  % number of cepstral coefficients to keep
figure('Position', [50, 50, 1600, 1000]);

tiledlayout('flow')
for i = 1:length(speechFiles)
    nexttile;
    
    speech = speechData_trunc{i};
    fs_speech = freqData{i};
    c = mfcc(speech, fs_speech, fs, 20, 256, nc, true);

    stem(c, 'filled', 'LineWidth', 1.2);
    title(sprintf('MFCCs: %s', speechFiles(i).name), 'Interpreter', 'none');
    xlabel('Cepstral Coefficient Index');
    ylabel('Amplitude');
    grid on;
end
subtitle('MFCCs for Each Training Speech (1 frame)');


%% Test 5 %%

% Parameters for mel filter bank
fs_mel = 12500;    % Sampling rate for mel frequency banks
p = 20;            % Number of mel filters
n = 256;           % FFT length
nc = 20;           % Number of MFCC coefficients to keep
frameLen = 256;    % Length for each window
overlap = 128;     % Overlap between windows
keepfirst = false; % Wheter or not keep the first MFCC coefficient
distortionThreshold = 0.00001;
m = melfb(p, n, fs_mel);  
allMFCC = [];
speakerLabels = [];
speakerMFCCs = cell(length(speechFiles), 1);

for i = 1:length(speechData_trunc)
    speech = speechData_trunc{i};
    fs_speech = freqData{i};
    C = mfcc_frames(speech, fs_speech, fs_mel, p, n, nc, frameLen, overlap, keepfirst);
    C = C';
    allMFCC = [allMFCC; C];
    numFrames = size(C, 1);
    speakerLabels = [speakerLabels; repmat(i, numFrames, 1)];
    speakerMFCCs{i} = C;
end

% Plot MFCC coefficient 2 vs. MFCC coefficient 3
clr = hsv(length(speechFiles));
figure('Position', [50, 50, 1600, 1000]);
gscatter(allMFCC(:,1), allMFCC(:,2), speakerLabels, clr);
legend("Speaker "+unique(speakerLabels));
xlabel('MFCC Coefficient 2');
ylabel('MFCC Coefficient 3');
title('Acoustic Space', fontsize=30);
grid on;
hold on;

%% Test 6 %%
numCodewords = 8;   % desired number of VQ codewords
epsilon = 0.01;     % splitting factor
speakerCodebook = cell(length(speechFiles), 1);
for i = 1:length(speechFiles)
    spMFCC = speakerMFCCs{i};  % MFCC frames for speaker i
    if isempty(spMFCC)
        continue;
    end
    % Train the VQ codebook for this speaker's MFCC vectors.
    codebook = trainVQCodebook(spMFCC, numCodewords, epsilon, distortionThreshold);
    
    scatter(codebook(:,1), codebook(:,2), 1000, 'x', 'LineWidth', 1, 'MarkerEdgeColor', clr(i, :), 'DisplayName', sprintf('Codebook %d', i));
    speakerCodebook{i} = codebook;
end


hold off;

%% Test 7 and 8 %%

%% Parameters
fs_mel       = 12500;  % Sampling rate used for mel filter bank
p            = 50;     % Number of mel filters
n            = 512;    % FFT length
nc           = 40;     % Number of MFCC coefficients to keep
frameLen     = 256;    % Frame length in samples
overlap      = 128;    % Overlap between frames (in samples)
numCodewords = 8;      % Desired number of VQ codewords per speaker
epsilon      = 0.0001; % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001; % Convergence Threshold for the LBG algorithm
keepfirst = false; % Whether or not keep the first MFCC coefficient

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


%% Test 9 %%

fs_mel       = 12500;  % Sampling rate used for mel filter bank
p            = 50;     % Number of mel filters
n            = 512;    % FFT length
nc           = 40;     % Number of MFCC coefficients to keep
frameLen     = 256;    % Frame length in samples
overlap      = 128;    % Overlap between frames (in samples)
numCodewords = 8;      % Desired number of VQ codewords per speaker
epsilon      = 0.0001; % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001; % Convergence Threshold for the LBG algorithm
keepfirst = false; % Whether or not keep the first MFCC coefficient

speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst);

[predictedLabels, trueLabels, Accuracy] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst);


%% Test 10a %%

fs_mel       = 12500;  % Sampling rate used for mel filter bank
p            = 50;     % Number of mel filters
n            = 512;    % FFT length
nc           = 40;     % Number of MFCC coefficients to keep
frameLen     = 256;    % Frame length in samples
overlap      = 128;    % Overlap between frames (in samples)
numCodewords = 8;      % Desired number of VQ codewords per speaker
epsilon      = 0.0001; % Splitting factor for the LBG algorithm
distortionThreshold = 0.000001; % Convergence Threshold for the LBG algorithm
keepfirst = false; % Whether or not keep the first MFCC coefficient

rainFolder = 'Data/Speach_Data_2024/Training_Data';
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

