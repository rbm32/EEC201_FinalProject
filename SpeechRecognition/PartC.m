clear; clc; close all;

%% Test 5 %%
trainFolder = 'GivenSpeech_Data/Training_Data';  
testFolder  = 'GivenSpeech_Data/Test_Data';   

[speechFiles, speechData,speechData_norm, freqData] = loadSpeechData(trainFolder);
speechData_trunc = truncateVectorByThreshold(speechData_norm, 0.2);

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

for i = 1:length(speechFiles)
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
numSpeakersToPlot = min(4, length(speechFiles));
clr = hsv(numSpeakersToPlot);
% clr = hsv(length(speechFiles));
figure('Position', [50, 50, 1600, 1000]);
hold on; grid on;

for i = 1:numSpeakersToPlot
    idx = (speakerLabels == i);
    scatter(allMFCC(idx, 1), allMFCC(idx, 2), 50, clr(i, :), 'filled');
end

% Labels and title
xlabel('MFCC Coefficient 2');
ylabel('MFCC Coefficient 3');
title('Acoustic Space for First 4 Speakers');
legend(arrayfun(@(x) sprintf('Speaker %d', x), 1:numSpeakersToPlot, 'UniformOutput', false));
hold off;

%% Test 6 %%
numCodewords = 8;   % desired number of VQ codewords
epsilon = 0.01;     % splitting factor
speakerCodebook = cell(length(speechFiles), 1);
figure('Position', [50, 50, 1600, 1000]);
hold on; grid on;

for i = 1:numSpeakersToPlot
    idx = (speakerLabels == i);
    scatter(allMFCC(idx, 1), allMFCC(idx, 2), 50, clr(i, :), 'filled');
end

% Labels and title
xlabel('MFCC Coefficient 2');
ylabel('MFCC Coefficient 3');
title('Acoustic Space for First 4 Speakers');
legend(arrayfun(@(x) sprintf('Speaker %d', x), 1:numSpeakersToPlot, 'UniformOutput', false));

for i = 1:numSpeakersToPlot
    spMFCC = speakerMFCCs{i};  % MFCC frames for speaker i
    if isempty(spMFCC)
        continue;
    end
    
    % Train the VQ codebook for this speaker's MFCC vectors.
    codebook = trainVQCodebook(spMFCC, numCodewords, epsilon, distortionThreshold);
    speakerCodebook{i} = codebook;
    
    % Scatter plot for codebook centroids
    scatter(codebook(:,1), codebook(:,2), 100, 'x', 'LineWidth', 1.5, ...
        'MarkerEdgeColor', clr(i, :), 'DisplayName', sprintf('Codebook %d', i));
end

% Labels and title
xlabel('MFCC Coefficient 2');
ylabel('MFCC Coefficient 3');
title('VQ Codebook for First 4 Speakers');
legend show;
hold off;


hold off;