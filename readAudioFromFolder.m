function [allAudioData, allfs] = readAudioFromFolder(folderPath)
fileList = dir(fullfile(folderPath, '*.wav'));

% Initialize an empty array to store all audio data
allAudioData = {};

% Loop through each .wav file in the folder
for i = 1:length(fileList)
    % Get the full path of the current .wav file
    filePath = fullfile(folderPath, fileList(i).name);
    
    % Read the audio data from the current .wav file
    [audioData, fs] = audioread(filePath);
    
    allAudioData{i} = audioData;
    allfs(i) = fs;
    % Append the audio data to the allAudioData array
    
end

% The resulting 'allAudioData' array contains the data of all .wav files
disp('All .wav files have been read into the array.');
end