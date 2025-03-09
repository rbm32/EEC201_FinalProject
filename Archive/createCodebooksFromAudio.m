function codebooks = createCodebooksFromAudio(TrainDataRaw, truncThresh, K, Win, N_frame, Nover, Fs, M, iter, eps)
    % Normalize and truncate the training data
    TrainData = normalizeVectors(TrainDataRaw);
    TrainData = truncateVectorByThreshold(TrainData, truncThresh);

    % Generate MFCC features for each training data sample
    MFCCtrain = cell(1, length(TrainData));
    for i = 1:length(TrainData)
        MFCCtrain{i} = generateMFCC(TrainData{i}, K, Win, N_frame, Nover, Fs, ...
                                    'PlotSpectrogram', false, 'PlotMelFilterBank', false);
    end

    % Train codebooks using the LBG algorithm
    codebooks = cell(1, length(MFCCtrain));
    for i = 1:length(MFCCtrain)
        codebooks{i} = trainVQ_LBG(MFCCtrain{i}, M, iter, eps);
    end
end