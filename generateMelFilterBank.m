function melFilterBank = generateMelFilterBank(numFilters, f, showPlot)
    % generateMelFilterBank generates a Mel filterbank matrix
    % Inputs:
    %   numFilters - Number of Mel filters (bins)
    %   f - Frequency vector (Hz) spanning the desired frequency range
    %   showPlot (optional) - Boolean to display the plot (default: false)
    % Output:
    %   melFilterBank - Matrix of size (numFilters x length(f))

    if nargin < 3
        showPlot = false; % Default value for showPlot if not provided
    end
    
    % Frequency range
    fMin = f(1);
    fMax = f(end);
    
    % Convert frequency limits to Mel scale
    melMin = hz2mel(fMin);
    melMax = hz2mel(fMax);
    
    % Generate Mel scale points
    melPoints = linspace(melMin, melMax, numFilters + 2);
    
    % Convert Mel points back to Hz
    hzPoints = mel2hz(melPoints);
    
    % Initialize the Mel filterbank matrix
    melFilterBank = zeros(numFilters, length(f));
    
    % Create triangular filters
    for i = 1:numFilters
        % Left, center, and right frequencies of the triangular filter
        fLeft = hzPoints(i);
        fCenter = hzPoints(i+1);
        fRight = hzPoints(i+2);
        
        % Create the rising edge of the triangular filter
        melFilterBank(i, f >= fLeft & f <= fCenter) = ...
            (f(f >= fLeft & f <= fCenter) - fLeft) / (fCenter - fLeft);
        
        % Create the falling edge of the triangular filter
        melFilterBank(i, f >= fCenter & f <= fRight) = ...
            (fRight - f(f >= fCenter & f <= fRight)) / (fRight - fCenter);
    end
    
    % Plot the filterbank if requested
    if showPlot
        figure;
        plot(f, melFilterBank');
        title('Mel Filterbank');
        xlabel('Frequency (Hz)');
        ylabel('Amplitude');
        grid on;
    end
end

% Helper function to convert Hz to Mel
function mel = hz2mel(hz)
    mel = 2595 * log10(1 + hz / 700);
end

% Helper function to convert Mel to Hz
function hz = mel2hz(mel)
    hz = 700 * (10.^(mel / 2595) - 1);
end