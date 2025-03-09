function identifiedSpeakers = identifySpeakers(AudioData, truncThresh, K, Win, N_frame, Nover, Fs, codebooks)
    % Normalize and truncate the test data
    TestData = normalizeVectors(AudioData);
    TestData = truncateVectorByThreshold(TestData, truncThresh);

    % Generate MFCC features for each test data sample
    MFCCtest = cell(1, length(TestData));
    for i = 1:length(TestData)
        MFCCtest{i} = generateMFCC(TestData{i}, K, Win, N_frame, Nover, Fs, ...
                                   'PlotSpectrogram', false, 'PlotMelFilterBank', false);
    end

    % Identify speakers using the codebooks
    identifiedSpeakers = zeros(1, length(TestData));
    for i = 1:length(TestData)
        identifiedSpeakers(i) = findBestCodebook(MFCCtest{i}, codebooks);
    end
end
