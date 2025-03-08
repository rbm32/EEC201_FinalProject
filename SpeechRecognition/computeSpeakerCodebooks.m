function speakerCodebook = computeSpeakerCodebooks(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon)
% computeSpeakerCodebooks  Compute speaker-specific VQ codebooks using MFCC features.
%
%   speakerCodebook = computeSpeakerCodebooks(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon)
%
%   Inputs:
%       trainFolder  - Folder containing training speech files.
%       fs_mel       - Sampling rate (Hz) for the mel filter bank.
%       p            - Number of mel filters.
%       n            - FFT length.
%       nc           - Number of MFCC coefficients to keep.
%       frameLen     - Frame length in samples.
%       overlap      - Overlap between frames in samples.
%       numCodewords - Desired number of VQ codewords per speaker.
%       epsilon      - Splitting factor for VQ training (LBG algorithm).
%
%   Output:
%       speakerCodebook - Cell array, where each cell contains the VQ codebook 
%                         for one speaker.
%
%   This function loads training data, truncates the speech signals using a threshold,
%   computes MFCC frames for each speaker (using mfcc_frames, which internally calls mfcc),
%   and then trains a VQ codebook for each speaker using the LBG algorithm.

    % Load training data (assumes loadSpeechData exists)
    [speechFiles, speechData, speechData_norm, freqData] = loadSpeechData(trainFolder);
    
    % Truncate the signals based on a threshold (assumes truncateVectorByThreshold exists)
    speechData_trunc = truncateVectorByThreshold(speechData_norm, 0.2);
    
    % Initialize the cell array to store each speaker's MFCC frames and codebook
    speakerCodebook = cell(length(speechFiles), 1);
    
    for i = 1:length(speechFiles)
        speech = speechData_trunc{i};
        fs_speech = freqData{i};
        
        % Compute MFCC frames for the current speaker.
        % The function mfcc_frames uses the mfcc function internally.
        C = mfcc_frames(speech, fs_speech, fs_mel, p, n, nc, frameLen, overlap);
        
        % Transpose C so that each row is a frame (i.e., a feature vector)
        C = C';
        
        % Train the VQ codebook for this speaker's MFCC frames
        codebook = trainVQCodebook(C, numCodewords, epsilon);
        
        % Save the codebook for this speaker in the cell array
        speakerCodebook{i} = codebook;
    end
end
