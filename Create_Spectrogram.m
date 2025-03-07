function [s, f, tf] = Create_Spectrogram(TestData, W, N, Nover, Fs, show_plt)
    % Create_Spectrogram generates a spectrogram and optionally plots it.
    % Inputs:
    %   TestData - Input signal data
    %   W - Window function
    %   N - Window length
    %   Fs - Sampling frequency
    %   show_plt (optional) - Boolean to display the plot (default: false)
    % Outputs:
    %   s - Spectrogram matrix
    %   f - Frequency vector
    %   tf - Time vector

    if nargin < 5 || isempty(show_plt)
        show_plt = false; % Default value for show_plt if not provided
    end

    data = TestData;
    nfft = length(data);
    [s, f, tf] = spectrogram(data, W, Nover, nfft, Fs);
    t = (0:length(data)-1) / Fs;

    if show_plt
        figure
        tiledlayout("vertical");

        % Time Domain Plot
        nexttile;
        plot(t, data, 'LineWidth', 1.5);
        xlabel("Time (s)", 'FontSize', 16);
        ylabel("Amplitude", 'FontSize', 16);
        title("Time Domain Data", 'FontSize', 25);
        xlim([t(1), t(end)]);
        grid on;

        % Spectrogram Plot
        nexttile;
        imagesc(tf, f, 20 * log10(abs(s) + eps)); % Added eps to avoid log of zero
        axis xy;
        colormap(jet);
        colorbar;
        xlabel('Time (s)', 'FontSize', 16);
        ylabel('Frequency (Hz)', 'FontSize', 16);
        title('Spectrogram', 'FontSize', 25);
        xlim([t(1), t(end)]);
        caxis([max(20 * log10(abs(s(:)))) - 80, max(20 * log10(abs(s(:))))]);
    end
end
