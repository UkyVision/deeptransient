function Y = fftFilter(X, type, freq)
% usage:
%
%   X: signal NxM, M variables
%   type: 'low' or 'high'
%   freq: 'frequency coverage radius'
%

switch type
  case 'high'
    rectangle = ones(size(X,1), 1);
    rectangle(1:freq+1) = 0;
    rectangle(end-freq+1:end) = 0;
  case 'low'
    rectangle = zeros(size(X,1), 1);
    rectangle(1:freq+1) = 1;
    rectangle(end-freq+1:end) = 1;
  otherwise
    disp('wrong filter type')
end

Xfft = fft(X);
Y = ifft(bsxfun(@times, Xfft, rectangle));