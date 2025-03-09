function cepstrum = melSpectrumToCepstrum(melSpectrum)
    % melSpectrum: Input mel spectrum (assumed to be in linear scale)
    
    % Compute the log spectrum (log of the linear spectrum)
    logSpectrum = log(melSpectrum);  % eps is added to avoid log(0)
    
    % Compute the Discrete Cosine Transform (DCT) to obtain the cepstrum
    cepstrum = dct(logSpectrum);
end

