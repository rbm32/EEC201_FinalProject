function c = mfcc(signal, fs_signal, fs_mel, p, n, nc, keepfirst)
%  Compute MFCCs from a speech signal.
%
%   Inputs:
%       signal    - 1D array of speech signal's amplitude.
%       fs_signal - sampling rate (Hz) of speech signal.
%       fs_mel    - sampling rate (Hz) of the mel filter bank.
%       p         - Number of filters in the filterbank.
%       n         - FFT length.
%       nc        - number of MFCC coefficients to keep.
%       keepfirst - whether or not to keep the first coefficient.
%
%   Output:
%       c         - a 1D array of MFCC coefficients (length = nc).
%

    if fs_signal ~= fs_mel
        signal = resample(signal, fs_mel, fs_signal);
    end

    m = melfb(p, n, fs_mel);
    S = fft(signal, n);
    S_mag = abs(S(1:floor(n/2)+1)).^2;
    mel_spectrum = m * S_mag;
    c = dct(log(mel_spectrum));
    if keepfirst == true
        c = c(1:nc);
    else
        c = c(2:nc);
    end
end

