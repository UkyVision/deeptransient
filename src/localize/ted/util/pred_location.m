function preds = pred_location(paramVec, feats)

% input size:
%   -paramVec: M + 2*K
%   -feats: N x M (N observations, M variables)
%
% f = sum(c_k * exp(-labmda*sum(w*x_i)))

M = 40; % transient attribute

feat_weights = paramVec(1:M);
K = (numel(paramVec) - numel(feat_weights)) / 2;
lambda = paramVec(M+1:M+K);
c = paramVec(M+K+1:end);

% construct f(feat_corrs; paramVec) -> locDiffs
wx = bsxfun(@times, feats, feat_weights');
wx_sum = sum(wx,2);

exp_wx = exp(bsxfun(@times, wx_sum, -lambda'));
func_k = bsxfun(@times, c', exp_wx);
preds = sum(func_k, 2);