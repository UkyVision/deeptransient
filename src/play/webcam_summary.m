%
% what can you dooooo
% scotts code for loading and filtering
%

addpath ~/matlab_root/

base_dir = '/u/vul-d1/scratch/ryan/00007371/';

data = readtable([base_dir 'attributes.csv'], 'ReadVariableNames', false);
data = sortrows(data, {'Var1'}, {'ascend'});
hays_data = readtable([base_dir 'hays_attributes.csv'], 'ReadVariableNames', false);
hays_data = sortrows(hays_data, {'Var1'}, {'ascend'});

labels = readtable('/u/vul-d1/scratch/ryan/attributes.txt', 'ReadVariableNames', false);

loc = [47.367922, 8.539977];
altitude = 408;
utc_offset = - timezone(loc(2));

[~, names] = cellfun(@(x) fileparts(x), table2cell(data(:, 1)), 'uni', 0);
date_numbers = cellfun(@(x) datenum(x, 'yyyymmdd_HHMMSS'), names);

features = cell2mat(table2cell(data(:, 2:end)));
hays_features = cell2mat(table2cell(hays_data(:, 2:end)));

local_date_numbers = date_numbers + (utc_offset/24);

%% create the summary images
sz = [48 365];

soy = datevec(date_numbers(1));
soy(2:6) = [1 1 1,0,0];
soy = datenum(soy);

% date nums to x value
x_inds = floor(((date_numbers - soy) / 365) * 365) + 1;

% date nums to y value
y_inds = floor(mod(date_numbers, 1) * 48);

% sub2ind
locs = sub2ind(sz, y_inds, x_inds);

% composite image
sr = zeros(sz);
sg = zeros(sz);
sb = zeros(sz);
sr(locs) = features(:,10);
sg(locs) = features(:,2);
sb(locs) = features(:,9);
summary = cat(3,sr,sg,sb);
allofthem = cell(1,40);
for ix = 1:40
    tmp  = zeros(sz);
    tmp(locs) = features(:,ix);
    allofthem{ix} = tmp;
end

% all of the attributes
attrs = textscan(fopen('attributes.txt'), '%s'); attrs = attrs{1};

figure(1); clf
title('camera')
subplot(121)
imagesc(cat(1,allofthem{1:20}), [0 1]); axis image
set(gca, 'YTick', linspace(sz(1)/2,20*sz(1)-sz(1)/2,20), 'YTickLabel',attrs(1:20));
axis image xy
set(gca, 'XTick', []);
set(gca, 'TickLength', [0 0]);
subplot(122)
imagesc(cat(1,allofthem{21:40}), [0 1]); axis image
set(gca, 'YTick', linspace(sz(1)/2,20*sz(1)-sz(1)/2,20), 'YTickLabel',attrs(21:40),'YAxisLocation','right');
set(gca, 'XTick', []);
set(gca, 'TickLength', [0 0]);
axis image xy

% summary = max(min(summary,1),0);
% image(summary)
% axis image off

%% plot summaries as a scatter plot

for iLabel = 1:40
    
    figure(2); clf;
    subplot(211)
    % + .005*randn(size(date_numbers))
    scatter(floor(date_numbers), mod(date_numbers,1), 20, features(:, iLabel), 'filled')
    set(gca, 'CLim', [0 1])
    subplot(212)
    scatter(floor(date_numbers), mod(date_numbers,1), 20, hays_features(:, iLabel), 'filled')   
    set(gca, 'CLim', [0 1])
    
    pause

end