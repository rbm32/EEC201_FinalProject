function [identifiedSpeakers, trueSpeakers, accuracy] = SpeakerDetection(TrainDataFn, TestDataFn, truncThresh, K, Win, N_frame, Nover, Fs, M, iter, eps)
[TrainDataRaw, trainSpeakers] = readAudioFromFolder(TrainDataFn);
[TestDataRaw, testSpeakers] = readAudioFromFolder(TestDataFn);

codebooks = createCodebooksFromAudio(TrainDataRaw, truncThresh, K, Win, N_frame, Nover, Fs, M, iter, eps);

identifiedSpeakerIdx = identifySpeakers(TestDataRaw, truncThresh, K, Win, N_frame, Nover, Fs, codebooks);

accuracy = calculateAccuracy(identifiedSpeakerIdx, testSpeakers, trainSpeakers);
identifiedSpeakers = testSpeakers(identifiedSpeakerIdx);
trueSpeakers = trainSpeakers;
end