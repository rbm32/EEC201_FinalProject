function [audioData, fileNames] = readAudioFromFolder(folderPath)
    % readAudioFromFolder reads all the audio files in a folder and returns their data
    % along with the filenames. The function ensures that the audio is always mono.
    %
    % Inputs:
    %   folderPath  - Path to the folder containing the audio files.
    %
    % Outputs:
    %   audioData   - A cell array containing mono audio data of each file.
    %   fileNames   - A cell array containing the filenames of each audio file.

    % Get a list of all .wav files in the folder
    audioFiles = dir(fullfile(folderPath, '*.wav'));  
    numFiles = length(audioFiles);
    
    % Initialize cell arrays to store the audio data and filenames
    audioData = cell(numFiles, 1);
    fileNames = cell(numFiles, 1);
    
    % Loop through each audio file
    for i = 1:numFiles
        % Get the full path of the current audio file
        filePath = fullfile(folderPath, audioFiles(i).name);
        
        % Read the audio file (assuming you want to use the standard `audioread` function)
        [audio, Fs] = audioread(filePath);
        
        % Ensure the audio is mono by selecting only the first channel if it's stereo
        if size(audio, 2) > 1
            audio = audio(:, 1);  % Select the first channel (left channel in stereo)
        end
        
        % Store the audio data and filename
        audioData{i} = audio;
        fileNames{i} = audioFiles(i).name;
    end
end
