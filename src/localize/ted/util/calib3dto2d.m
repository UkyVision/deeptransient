function M = calib3dto2d(imagePoints, worldPoints)
%
% goal: s*[u v 1]' = M * [x y z 1]'
% 
% imagePoints: nx2 [u v]
% worldPoints: nx3 [x y z]
%
% M: 3x4
%
% this algorithm refers to: http://citeseerx.ist.psu.edu/viewdoc/download;jsessionid=49D4C586641B67C6D1AB473BACDBF04D?doi=10.1.1.7.4843&rep=rep1&type=pdf
%

n = size(imagePoints,1);
G1 = zeros(n, 11);
G2 = zeros(n, 11);

G1(:, 1:4) = [worldPoints, zeros(n,1)];
G1(:, 9:end) = -bsxfun(@times, worldPoints, imagePoints(:,1));

G2(:, 5:8) = [worldPoints, zeros(n,1)];
G2(:, 9:end) = -bsxfun(@times, worldPoints, imagePoints(:,2));

G = [G1; G2];
u = imagePoints(:);

% least square
m = G \ u;

% reconstruct M
M = reshape([m; 1], 4, 3)';
