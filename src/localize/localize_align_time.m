%[D_interp X_V_interp X_dV_interp Y_V_interp Y_dV_interp] = ...
%    localize_mutual_interp(X_date, X_V, Y_date, Y_V)
%
% X_V : observations in columns
%
% Here is a reasonable set of bins:
%  dates = [X_date; Y_date];
%  D_min = min(dates(:));
%  D_max = max(dates(:));
%  minStep = 10 / 60 / 25;
%  Date_bins = (minStep/2 + D_min) : minStep : (D_max - minStep/2);
function [time_bins, X_V_interp, Y_V_interp] = ...
    localize_align_time(X_date, X_V, Y_date, Y_V, bin_size)

  % bin_size was (20/60/24)

% remove duplicate times (this should be done earlier in the processing
% pipeline)
[X_date, Y_date, X_V, Y_V] = remove_dups(X_date, Y_date, X_V, Y_V);

time_bins = min(X_date):bin_size:max(X_date);

X_hist = hist(X_date, time_bins);
Y_hist = hist(Y_date, time_bins);

% at least one of each in a supported bin
both_hit = (X_hist > 0) & (Y_hist > 0);

time_bins = time_bins(both_hit);

% estimate signal
X_V_interp = interp1(X_date, X_V, time_bins, 'cubic');
Y_V_interp = interp1(Y_date, Y_V, time_bins, 'cubic');

function [X_date, Y_date, X_V, Y_V] = remove_dups(X_date, Y_date, X_V, Y_V)

X_keep = diff(X_date) ~= 0;
Y_keep = diff(Y_date) ~= 0;

X_date = X_date(X_keep);
Y_date = Y_date(Y_keep);

X_V = X_V(X_keep, :);
Y_V = Y_V(Y_keep, :);

% figure(1); clf
% plot(X_V_all, '.')
% 
% figure(2); clf
% plot(...
%     D_interp, X_V_interp(:, 1) - mean(X_V_interp(:, 1)), '.b',...
%     D_interp, X_dV_interp(:, 1), 'r-',...
%     D_interp, X_dV_interp(:, 1), 'r.',...
%     X_ddate, X_dV(:,1), '.k',...
%     X_ddate, X_dV(:,1), '-k',...
%     X_date, X_V(:,1) - mean(X_V(:,1)), '.b',...
%     X_date, X_V(:,1) - mean(X_V(:,1)), '-b');