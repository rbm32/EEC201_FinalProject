%% EEC 201 Final Project

%% Part 1: Download the speach files

playAudioRecording = false; % Set to TRUE if you want to hear all audio recordings played

% Get a list of all .wav files in the folder
[TrainData FsTrain] = readAudioFromFolder('Speach_Data_2024\Training_Data');
[TestData FsTest] = readAudioFromFolder('Speach_Data_2024\Test_Data');

% play Training Data
if playAudioRecording
    for i = 1:length(TrainData)
        audioPlayer = audioplayer(TrainData{i},FsTrain(i));
        playblocking(audioPlayer)
    end
    
    % play Test Data
    for i = 1:length(TestData)
        audioPlayer = audioplayer(TestData{i},FsTest(i));
        playblocking(audioPlayer)
    end
end
%% Calculate MFCC
for i = 1:length(TrainData)
    MFCC{i} = mfcc(TrainData{i}, FsTrain(i));
end

% plot one MFCC 

mfcc(TrainData{1}, FsTrain(1));
