function plotMelCepstrumWithVQ(melCepstrum1, melCepstrum2, codebook1, codebook2, coefIdx1, coefIdx2)
    % plotMelCepstrumWithVQ creates a 2D scatter plot for mel cepstrum coefficients
    % and overlays the VQ codebook for two speakers (codebook1, codebook2).
    %
    % Inputs:
    %   melCepstrum1  - Mel cepstrum coefficients for speaker 1
    %   melCepstrum2  - Mel cepstrum coefficients for speaker 2
    %   codebook1      - VQ codebook for speaker 1
    %   codebook2      - VQ codebook for speaker 2
    %   coefIdx1       - Index of the first coefficient to plot
    %   coefIdx2       - Index of the second coefficient to plot
    %
    % Outputs:
    %   A 2D scatter plot with mel cepstrum coefficients and the VQ codebook.

    % Check if the coefficients' indices are valid
    if coefIdx1 <= 0 || coefIdx2 <= 0
        error('Coefficient indices must be positive integers.');
    end
    
    % Extract the specified coefficients from the mel cepstrum and codebooks
    % Assuming the melCepstrum matrix has time across the columns and coefficients across the rows
    coefData1 = melCepstrum1([coefIdx1, coefIdx2], :); % For speaker 1
    coefData2 = melCepstrum2([coefIdx1, coefIdx2], :); % For speaker 2
    codebookData1 = codebook1([coefIdx1, coefIdx2], :); % Codebook for speaker 1
    codebookData2 = codebook2([coefIdx1, coefIdx2], :); % Codebook for speaker 2
    
    % Create a new figure for the plot
    clf;
    hold on;
    
    % Plot the mel cepstrum coefficients for speaker 1
    scatter(coefData1(1, :), coefData1(2, :), 50, 'b', 'filled', 'DisplayName', 'Speaker 1 - Cepstrum');
    
    % Plot the mel cepstrum coefficients for speaker 2
    scatter(coefData2(1, :), coefData2(2, :), 50, 'r', 'filled', 'DisplayName', 'Speaker 2 - Cepstrum');
    
    % Plot the VQ codebook for speaker 1 (larger markers and 'x' shape)
    scatter(codebookData1(1, :), codebookData1(2, :), 500, 'bx', 'LineWidth', 2, 'DisplayName', 'Speaker 1 - Codebook');
    
    % Plot the VQ codebook for speaker 2 (larger markers and 'x' shape)
    scatter(codebookData2(1, :), codebookData2(2, :), 500, 'rx', 'LineWidth', 2, 'DisplayName', 'Speaker 2 - Codebook');
    
    % Add labels, legend, and title
    xlabel(['Cepstrum Coefficient ' num2str(coefIdx1)]);
    ylabel(['Cepstrum Coefficient ' num2str(coefIdx2)]);
    title('Mel Cepstrum Coefficients and VQ Codebook');
    grid on;
    legend;
    
    hold off;
end
