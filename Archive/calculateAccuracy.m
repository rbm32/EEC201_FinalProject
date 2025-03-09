function [accuracy] = calculateAccuracy(identifiedSpeakerIdx, testSpeakers, trainSpeakers)
correctGuesses = [];
identifiedSpeakers = [];
for i=1:length(identifiedSpeakerIdx)
    identifiedSpeaker = testSpeakers(identifiedSpeakerIdx(i));
    correctGuesses(i, 1) = string(identifiedSpeaker) == string(trainSpeakers{i});
end

accuracy = sum(correctGuesses) ./ length(correctGuesses);
end