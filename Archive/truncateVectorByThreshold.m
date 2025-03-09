function truncatedVec = truncateVectorByThreshold(vec, energyFraction)
    % truncateVectorByThreshold truncates the front and back of a vector or cell array of vectors
    % such that the total energy is a certain fraction of the original signal's energy.
    %
    % Inputs:
    %   vec - Input vector (signal) or cell array of vectors
    %   energyFraction - Desired fraction of total energy to retain (0 to 1)
    %
    % Output:
    %   truncatedVec - Truncated vector(s) with desired energy retention

    % Ensure the energyFraction is between 0 and 1
    energyFraction = max(0, min(energyFraction, 1));

    % Handle a cell array of vectors
    if iscell(vec)
        truncatedVec = cell(size(vec));
        for i = 1:length(vec)
            truncatedVec{i} = truncateSingleVector(vec{i}, energyFraction);
        end
    else
        % Handle a single vector
        truncatedVec = truncateSingleVector(vec, energyFraction);
    end
end

function truncatedVec = truncateSingleVector(vec, energyFraction)
    % Compute the energy of the original signal
    totalEnergy = sum(vec.^2);
    targetEnergy = totalEnergy * energyFraction;

    % Cumulative energy from both sides
    cumulativeEnergy = cumsum(vec.^2);
    cumulativeEnergyBack = cumsum(vec(end:-1:1).^2);

    % Find front and back indices to truncate
    frontIndex = find(cumulativeEnergy >= (1 - energyFraction) * totalEnergy / 2, 1);
    backIndex = find(cumulativeEnergyBack >= (1 - energyFraction) * totalEnergy / 2, 1);

    % Generate the truncated vector
    truncatedVec = vec(frontIndex:end-backIndex+1);
end