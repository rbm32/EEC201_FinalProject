function C = mfcc_frames(signal, fs_signal, fs_mel, p, n, nc, frameLen, overlapLen, keepfirst)
% mfcc_frames  Compute MFCCs on each frame of a speech signal using the mfcc function.
%
%   C = mfcc_frames(signal, fs_signal, fs_mel, p, n, nc, frameLen, overlapLen)
%
%   Inputs:
%       signal     - 1D array of speech signal samples.
%       fs_signal  - Sampling rate (Hz) of the speech signal.
%       fs_mel     - Sampling rate (Hz) used by the mel filter bank.
%       p          - Number of filters in the mel filter bank.
%       n          - FFT length (e.g., 256).
%       nc         - Number of MFCC coefficients to keep per frame (e.g., 13).
%       frameLen   - Frame length in samples.
%       overlapLen - Overlap length in samples.
%       keepfirst - whether or not to keep the first coefficient.
%
%   Output:
%       C          - nc x numFrames matrix of MFCC coefficients.
%                    Each column is the MFCC vector for one frame.
%
%   Notes:
%       This function extracts all frames (zero-padding the last frame if needed)
%       and for each frame applies a Kaiser window before calling the mfcc function.
    
    % If necessary, resample the entire signal so that its sampling rate matches fs_mel.
    if fs_signal ~= fs_mel
        signal = resample(signal, fs_mel, fs_signal);
        fs_signal = fs_mel;
    end
    
    % Determine the step and the number of frames
    step = frameLen - overlapLen;
    numFrames = ceil((length(signal) - frameLen) / step) + 1;
    
    % Preallocate the output matrix (each column is an MFCC vector)
    if keepfirst == true
        C = zeros(nc, numFrames);
    else 
        C = zeros(nc-1, numFrames);
    end
    
    % Create a Kaiser window of length frameLen
    w = kaiser(frameLen, 2.5);
    
    % Process each frame
    for i = 1:numFrames
        startIdx = (i-1)*step + 1;
        endIdx   = startIdx + frameLen - 1;
        
        % Extract frame; if frame is incomplete, zero-pad it
        if endIdx > length(signal)
            frame = signal(startIdx:end);
            frame = [frame; zeros(endIdx - length(signal), 1)];
        else
            frame = signal(startIdx:endIdx);
        end
        
        % Apply the window
        frame = frame .* w;
        
        % Compute MFCC vector for the frame
        c = mfcc(frame, fs_signal, fs_mel, p, n, nc, keepfirst);
        
        C(:, i) = c;
    end
end
