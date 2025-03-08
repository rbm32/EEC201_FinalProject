function speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst)
% trainSpeakerRecognition Trains speaker-specific VQ codebooks.
%
%   speakerCodebook = trainSpeakerRecognition(trainFolder, fs_mel, p, n, nc, ...
%                        frameLen, overlap, numCodewords, epsilon, distortionThreshold, keepfirst)
%
%   Inputs:
%       trainFolder         - Folder containing training speech files.
%       fs_mel              - Sampling rate (Hz) for the mel filter bank.
%       p                   - Number of mel filters.
%       n                   - FFT length.
%       nc                  - Number of MFCC coefficients to keep.
%       frameLen            - Frame length in samples.
%       overlap             - Overlap between frames (in samples).
%       numCodewords        - Desired number of VQ codewords per speaker.
%       epsilon             - Splitting factor for the LBG algorithm.
%       distortionThreshold - Convergence threshold for VQ training.
%       keepfirst           - Boolean flag; if false, discard the first MFCC coefficient.
%
%   Output:
%       speakerCodebook - A cell array where each cell contains the trained VQ codebook
%                         (each codebook is a matrix whose rows are codewords) for one speaker.

    % Load training data (expects loadSpeechData to return file names, signals, normalized signals, and sampling rates)
    [speechFiles_train, speechData_train, speechData_norm_train, freqData_train] = loadSpeechData(trainFolder);
    % Truncate signals (using threshold 0.2; adjust as needed)
    speechData_trunc_train = truncateVectorByThreshold(speechData_norm_train, 0.2);
    numSpeakers = length(speechFiles_train);
    
    speakerCodebook = cell(numSpeakers, 1);
    
    for i = 1:numSpeakers
        % Get speaker i's (truncated) normalized speech and sampling rate.
        speech = speechData_trunc_train{i};
        fs_speech = freqData_train{i};
        
        % Compute MFCC frames (mfcc_frames returns an nc x numFrames matrix).
        % Transpose so that each row is a feature vector.
        C = mfcc_frames(speech, fs_speech, fs_mel, p, n, nc, frameLen, overlap, keepfirst)';
        
        % Train the VQ codebook for speaker i using the LBG algorithm.
        codebook = trainVQCodebook(C, numCodewords, epsilon, distortionThreshold);
        
        % Save the speaker's codebook.
        speakerCodebook{i} = codebook;
    end
end
