function [melCepstrum] = generateMFCC(TestData, K, Win, N_frame, Nover, Fs, varargin) 
    % generateMFCC computes the Mel-frequency cepstral coefficients (MFCCs) 
    % for a given audio signal, optionally including the first MFCC.
    %
    % Inputs:
    %   TestData     - The input audio signal (time-domain signal)
    %   Win          - Windowing function used in spectrogram calculation
    %   N_frame      - Number of frames for analysis
    %   Fs           - Sampling frequency of the input signal
    %   varargin     - Name-value pairs for plotting control
    %     'PlotSpectrogram'   - Boolean (default false), if true, plots the spectrogram.
    %     'PlotMelFilterBank' - Boolean (default false), if true, plots the mel filter bank.
    %     'ReturnFirstMFCC'    - Boolean (default false), if true, includes the first MFCC.
    %
    % Outputs:
    %   melCepstrum   - The resulting mel-frequency cepstrum (MFCCs)
    
    % Parse optional inputs for plotting and returning the first MFCC
    p = inputParser;
    addParameter(p, 'PlotSpectrogram', false, @islogical);
    addParameter(p, 'PlotMelFilterBank', false, @islogical);
    addParameter(p, 'ReturnFirstMFCC', false, @islogical);  % Option to include first MFCC
    parse(p, varargin{:});
    
    % Step 1: Create the spectrogram of the input signal
    [s, f, tf] = Create_Spectrogram(TestData, Win, N_frame, Nover, Fs, p.Results.PlotSpectrogram);
    
    
    % Step 3: Generate the mel filter bank
    melFilterBank = generateMelFilterBank(K, f, p.Results.PlotMelFilterBank);
    
    % Step 4: Apply the mel filter bank to the spectrogram
    melSpectrum = melFilterBank * abs(s);
    
    % Step 5: Convert the mel spectrum to mel cepstrum
    melCepstrum = melSpectrumToCepstrum(melSpectrum);
    
    % Conditionally remove the first MFCC (if 'ReturnFirstMFCC' is false)
    if ~p.Results.ReturnFirstMFCC
        melCepstrum = melCepstrum(2:end, :);  % Exclude the first row (MFCC0)
    end
end
