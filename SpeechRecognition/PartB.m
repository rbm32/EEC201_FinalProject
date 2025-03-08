clear; clc; close all;

%% Test2 %%
trainFolder = 'GivenSpeech_Data/Training_Data';  
testFolder  = 'GivenSpeech_Data/Test_Data';   

%% Load training data
[speechFiles, speechData, speechData_norm, freqData] = loadSpeechData(trainFolder);
speechData_trunc = truncateVectorByThreshold(speechData_norm, 0.2);
%% Time-domain plotting
figure;
for i = 1:length(speechFiles)
    s = speechData{i};
    fs = freqData{i};
    t = (0:length(s)-1) / fs;
    subplot(3, 4, i);
    plot(t, s);
    title(sprintf('Wave %s', speechFiles(i).name));
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-2,2]);
end
sgtitle('Time-Domain Speech Signals (Training Data)');

% Normalized signal
figure;
for i = 1:length(speechFiles)
    s = speechData_norm{i};
    fs = freqData{i};
    t = (0:length(s)-1) / fs;
    subplot(3, 4, i);
    plot(t, s);
    title(sprintf('Wave %s', speechFiles(i).name));
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-2,2]);
end
sgtitle('Normalized Time-Domain Speech Signals (Training Data)');

% Truncated signal
figure;
for i = 1:length(speechFiles)
    s = speechData_trunc{i};
    fs = freqData{i};
    t = (0:length(s)-1) / fs;
    subplot(3, 4, i);
    plot(t, s);
    title(sprintf('Wave %s', speechFiles(i).name));
    xlabel('Time (s)');
    ylabel('Amplitude');
    ylim([-2,2]);
end
sgtitle('Truncated Time-Domain Speech Signals (Training Data)');

%% Use STFT to generate spectrogram
frameSizes = [128, 256, 512];

for k = 1:length(frameSizes)
    N = frameSizes(k);    % Window length
    M = round(N/3);       % Frame increment
    
    figure('Position', [50, 50, 1400, 800]);
    
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
      
        subplot(3, 4, i);
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

for i = 1:length(speechFiles)
    subplot(4, 3, i);
    speech = speechData_trunc{i};
    fs_speech = freqData{i};
    
    % Resample if the speech file's sampling rate differs from fs_mel
    if fs_speech ~= fs
        speech = resample(speech, fs_mel, fs);
    end
    
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

suptitle('Before and After Mel-Frequency Warping Spectrum for All Training Speeches (1 frame)');

%% Test 4 %%
nc = 13;  % number of cepstral coefficients to keep
figure('Position', [50, 50, 1600, 1000]);

for i = 1:length(speechFiles)
    subplot(4, 3, i);
    
    speech = speechData_trunc{i};
    fs_speech = freqData{i};
    c = mfcc(speech, fs_speech, fs, 20, 256, nc, true);

    stem(c, 'filled', 'LineWidth', 1.2);
    title(sprintf('MFCCs: %s', speechFiles(i).name), 'Interpreter', 'none');
    xlabel('Cepstral Coefficient Index');
    ylabel('Amplitude');
    grid on;
end
suptitle('MFCCs for Each Training Speech (1 frame)');
