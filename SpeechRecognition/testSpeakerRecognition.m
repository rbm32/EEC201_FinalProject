function [predictedLabels, trueLabels, Accuracy] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, frameLen, overlap, speakerCodebook, keepfirst)
% testSpeakerRecognition Tests speaker recognition using trained VQ codebooks.
%
%   [origAccuracy, notchAccuracies] = testSpeakerRecognition(testFolder, fs_mel, p, n, nc, ...
%                                          frameLen, overlap, speakerCodebook, keepfirst)
%
%   Inputs:
%       testFolder     - Folder containing test speech files.
%       fs_mel         - Sampling rate (Hz) for the mel filter bank.
%       p              - Number of mel filters.
%       n              - FFT length.
%       nc             - Number of MFCC coefficients to keep.
%       frameLen       - Frame length in samples.
%       overlap        - Overlap between frames (in samples).
%       speakerCodebook- Cell array of trained VQ codebooks (one per speaker).
%       keepfirst      - Boolean flag; if false, discard the first MFCC coefficient.
%
%   Outputs:
%       origAccuracy    - Recognition accuracy on the original (unfiltered) test set.
%       notchAccuracies - Recognition accuracies for each notch filter condition.


    % Load test data.
    [speechFiles_test, speechData_test, speechData_norm_test, freqData_test] = loadSpeechData(testFolder);
    speechData_trunc_test = truncateVectorByThreshold(speechData_norm_test, 0.2);
    numTest = length(speechFiles_test);
    numSpeakers = length(speakerCodebook);
    
    predictedLabels = zeros(numTest, 1);
    trueLabels = zeros(numTest, 1);
    
    % Testing on unfiltered data.
    for i = 1:numTest
        speech = speechData_trunc_test{i};
        fs_speech = freqData_test{i};
        
        % Compute MFCC frames for test utterance (transpose so rows are feature vectors).
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
    
    Accuracy = sum(predictedLabels == trueLabels) / numTest;
    fprintf('Test Accuracy: %.2f%%\n', Accuracy*100);
end
