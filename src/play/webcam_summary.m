%
% create the webcam summary images
%

addpath ~/matlab_root/
addpath ~/matlab_root/export_fig/

% load up cam data
cams = dir('/u/vul-d1/scratch/ryan/stable_cam_data/');

for id = 3:size(cams, 1)

% make dir for each cam
cam_id = cams(id).name;
mkdir(sprintf('attr_summary/%s/', cam_id));

base_dir = sprintf('/u/vul-d1/scratch/ryan/stable_cam_data/%s/', cam_id);

% read in cams attr data for the year
data = readtable([base_dir '2013_attributes.csv'], 'ReadVariableNames', false);
if mean(size(data) == 0) == 1
   continue 
end

data = unique(data);
data = sortrows(data, {'Var1'}, {'ascend'});
labels = readtable('/u/vul-d1/scratch/ryan/attributes.txt', 'ReadVariableNames', false);

data(cellfun(@(x) length(x) < 15, table2cell(data(:,1))),:) = [];
data(cellfun(@(x) ~floor(mean(x(1:4) == base_dir(1:4))), table2cell(data(:,1))),:) = [];

[~, names] = cellfun(@(x) fileparts(x), table2cell(data(:, 1)), 'uni', 0);
date_numbers = cellfun(@(x) datenum(x, 'yyyymmdd_HHMMSS'), names);

features = cell2mat(table2cell(data(:, 2:end)));

for attr_id = 1:40
%% create the summary images
sz = [48 365];

soy = datevec(date_numbers(1));
soy(2:6) = [1 1 0,0,0];
soy = datenum(soy);

% date nums to x value
x_inds = floor(((date_numbers - soy) / 365) * 365) + 1;

% date nums to y value
y_inds = floor(mod(date_numbers, 1) * 48) + 1;

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
attrs = textscan(fopen('fcn_fun/attributes.txt'), '%s'); attrs = attrs{1};

% figure(1); clf
% title('camera')
% subplot(121)
% imagesc(cat(1,allofthem{1:20}), [0 1]); axis image
% set(gca, 'YTick', linspace(sz(1)/2,20*sz(1)-sz(1)/2,20), 'YTickLabel',attrs(1:20));
% axis image xy
% set(gca, 'XTick', []);
% set(gca, 'TickLength', [0 0]);
% subplot(122)
% imagesc(cat(1,allofthem{21:40}), [0 1]); axis image
% set(gca, 'YTick', linspace(sz(1)/2,20*sz(1)-sz(1)/2,20), 'YTickLabel',attrs(21:40),'YAxisLocation','right');
% set(gca, 'XTick', []);
% set(gca, 'TickLength', [0 0]);
% axis image xy

figure(2); clf
imagesc(cat(1,allofthem{[attr_id]}), [0 1]); axis image
set(gca, 'YTick', []);
colormap([1 1 1; interp1(linspace(0,1,3), [0.65 0 0; 0.7 0.7 0.7; 0 0.8 0], linspace(0,1,100))])
axis image xy
set(gca, 'XTick', []);
set(gca, 'TickLength', [0 0]);


export_fig(sprintf('attr_summary/%s/%s_%s.pdf', cam_id, cam_id, char(attrs(attr_id))), '-transparent', '-m1.5')

end
end

%%
summary = max(min(summary,1),0);
image(summary)
axis image off

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
