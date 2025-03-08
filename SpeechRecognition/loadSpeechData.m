function [speechFiles, speechData, speechData_norm, freqData] = loadSpeechData(Folder)
% loadSpeechData loads .wav files from the specified folder.
%
%   [speechData, speechData_norm, freqData] = loadSpeechData(Folder)
%
% Inputs:
%   trainFolder - path to the folder containing .wav files.
%
% Outputs:
%   speechData      - cell array containing raw audio signals.
%   speechData_norm - cell array containing normalized audio signals.
%   freqData        - cell array of sampling frequencies for each file.
%

    speechFiles = dir(fullfile(Folder, '*.wav'));
    speechFiles = natsortfiles(speechFiles); 

    numFiles = length(speechFiles);
    speechData      = cell(numFiles, 1);
    speechData_norm = cell(numFiles, 1);
    freqData        = cell(numFiles, 1);
    N = 256;

    for i = 1:numFiles
        filename = fullfile(Folder, speechFiles(i).name);
        [s, fs] = audioread(filename);

        % If stereo, convert to mono by averaging the channels
        if size(s, 2) == 2
            s = mean(s, 2);
           % s = s(:, 1);
        end
        
        duration_ms = (N / fs) * 1000;
        % fprintf('File: %s - Sampling rate: %d Hz, %d samples = %.2f ms\n', ...
        %         speechFiles(i).name, fs, N, duration_ms);

        speechData{i} = s;
        s = s - mean(s);
        speechData_norm{i} = s / max(s);
        freqData{i} = fs;
    end
end
