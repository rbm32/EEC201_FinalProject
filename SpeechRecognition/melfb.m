function m = melfb(p, n, fs)
%
%   m = melfb_own(p, n, fs) returns a sparse matrix m of size 
%   [p, 1+floor(n/2)] containing the amplitudes for a mel-spaced filterbank.
%
%   Inputs:
%       p  - Number of filters in the filterbank.
%       n  - FFT length.
%       fs - Sampling rate in Hz.
%
%   Output:
%       m  - A sparse matrix of dimensions p x (1+floor(n/2)). Each row 
%            represents one triangular filter in the mel filterbank.
%
%   Usage example:
%       % Compute the mel-scale spectrum of a speech signal:
%       s = audioread('speech.wav');
%       s = s(:,1); % use one channel if stereo
%       n = 256;
%       p = 20;
%       f = fft(s, n);
%       m = melfb_own(p, n, fs);
%       n2 = 1 + floor(n/2);
%       z = m * abs(f(1:n2)).^2;
%
%   To plot the filterbank responses:
%       plot(linspace(0, fs/2, 1+floor(n/2)), melfb_own(p, n, fs)');
%       title('Mel-spaced filterbank');
%       xlabel('Frequency (Hz)');

% Define the reference frequency for mel conversion.
f0 = 700 / fs;  
fn2 = floor(n/2);

% Compute the logarithmic spacing constant.
Lr = log(1 + 0.5/f0) / (p+1);

% Determine the FFT bin numbers corresponding to the mel-scale boundaries.
Bv = n * (f0 * (exp([0 1 p p+1] * Lr) - 1));

% Determine boundary indices for the filters (with 0 for DC term).
b1 = floor(Bv(1)) + 1;
b2 = ceil(Bv(2));
b3 = floor(Bv(3));
b4 = min(fn2, ceil(Bv(4))) - 1;

% Compute the position of FFT bins (from b1 to b4) on the mel scale.
pf = log(1 + (b1:b4) / n / f0) / Lr;
fp = floor(pf);
pm = pf - fp;

% Construct the row (r) and column (c) indices for the nonzero filterbank entries.
% The first part (rising slope) uses bins b2 to b4, and the second part (falling slope)
% uses bins 1 to b3.
r = [fp(b2:b4)  1 + fp(1:b3)];
c = [b2:b4  1:b3] + 1;

% Construct the filter coefficients. The rising part uses 1 - pm and the falling part uses pm.
v = 2 * [1 - pm(b2:b4)  pm(1:b3)];

% Build the sparse mel filterbank matrix.
m = sparse(r, c, v, p, 1 + fn2);
end
