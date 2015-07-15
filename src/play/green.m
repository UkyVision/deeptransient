%
% greenness l0l
%

addpath ~/matlab_root/

base_dir = '/u/vul-d1/scratch/ryan/';
camera = '00007371';

data = readtable([base_dir camera '/ours.csv'], 'ReadVariableNames', false);
data = sortrows(data, {'Var1'}, {'ascend'});
hays_data = readtable([base_dir camera '/hays_attributes.csv'], 'ReadVariableNames', false);
hays_data = sortrows(hays_data, {'Var1'}, {'ascend'});

labels = table2cell(readtable('/u/vul-d1/scratch/ryan/attributes.txt', 'ReadVariableNames', false));

loc = [47.367922, 8.539977];
altitude = 408;
utc_offset = - timezone(loc(2));

fNames = cellfun(@(x) [base_dir x], data{:, 1}, 'uni', 0);
[~, names] = cellfun(@(x) fileparts(x), table2cell(data(:, 1)), 'uni', 0);
date_numbers = cellfun(@(x) datenum(x, 'yyyymmdd_HHMMSS'), names);

features = cell2mat(table2cell(data(:, 2:end)));
hays_features = cell2mat(table2cell(hays_data(:, 2:end)));

if true
  % find daylight images (sun above the horizon)
  location = struct('latitude',  loc(1), ...
    'longitude', loc(2), ...
    'altitude',  altitude);
  
  sun_locations = cellfun(@(x) sun_position(datestr(x), location), num2cell(date_numbers));
  elevations = 90 - [sun_locations.zenith];
  
  fNames = fNames(elevations > 0);
  date_numbers = date_numbers(elevations > 0);
  features = features(elevations > 0, :);
  hays_features = hays_features(elevations > 0, :);
end

local_date_numbers = date_numbers + (utc_offset/24);


%% compute greenness for a patch

greenness = zeros(size(local_date_numbers,1), 1);

im = imread(fNames{1});

figure(1); clf;
image(im);
axis image
h = imrect;
pos = wait(h);
pos = round(pos);

parfor ix = 1:size(fNames,1)
  
  im = im2double(imread(fNames{ix}));
  patch = im(pos(2):pos(2)+pos(4), pos(1):pos(1)+pos(3), :);
  
  %     % G - (R + B)/2
  %     greenness(ix) = mean2(patch(:,:,2) - ((patch(:,:,1) + patch(:,:,3))/2));
  
  % 2G - R - B
  g1r = patch(:,:,1)./(patch(:,:,1)+patch(:,:,2)+patch(:,:,3));
  g1g = patch(:,:,2)./(patch(:,:,1)+patch(:,:,2)+patch(:,:,3));
  g1b = patch(:,:,3)./(patch(:,:,1)+patch(:,:,2)+patch(:,:,3));
  greenness(ix) = nanmean(nanmean(2.*g1g-g1r-g1b)); 
  
end


%% average greenness visualization

days = floor(local_date_numbers);

day_inds = arrayfun(@(x) find(days==x), unique(days), 'uni', false);
avg_g = cellfun(@(x) mean(greenness(x)), day_inds);

ab = quantile(unique(days),[0 1]);

figure(4); clf;
plot(unique(days), avg_g, 'r.')
set(gca, 'XTickLabel', datestr(linspace(ab(1), ab(2), 10),'mmm'), 'XTick', linspace(ab(1), ab(2), 10))
title('Average Greenness')


%% average greenness after filtering

iLabel = 9; thresh = .25;
good_inds = features(:, iLabel) < thresh;
good_inds_hays = hays_features(:, iLabel) < thresh;

good_dates = local_date_numbers(good_inds);
good_dates_hays = local_date_numbers(good_inds_hays);
good_green = greenness(good_inds);
good_green_hays = greenness(good_inds_hays);

days = floor(good_dates);
days_hays = floor(good_dates_hays);

day_inds = arrayfun(@(x) find(days==x), unique(days), 'uni', false);
day_inds_hays = arrayfun(@(x) find(days_hays==x), unique(days_hays), 'uni', false);

avg_g = cellfun(@(x) mean(good_green(x)), day_inds);
avg_g_hays = cellfun(@(x) mean(good_green_hays(x)), day_inds_hays);

ab = quantile(unique(days),[0 1]);

figure(5); clf;
subplot(121)
plot(unique(days), avg_g, 'r.')
set(gca, 'XTickLabel', datestr(linspace(ab(1), ab(2), 10),'mmm'), 'XTick', linspace(ab(1), ab(2), 10))
title('Average Greenness (filtered, Us)')
subplot(122)
plot(unique(days_hays), avg_g_hays, 'g.')
set(gca, 'XTickLabel', datestr(linspace(ab(1), ab(2), 10),'mmm'), 'XTick', linspace(ab(1), ab(2), 10))
title('Average Greenness (filtered, Hays)')


%% all images before/after

iLabel = 6; thresh = .5;
good_inds = features(:, iLabel) > thresh;

figure(1); clf;
plot(local_date_numbers, greenness, 'g.', 'MarkerSize', 20)
hold on
plot(local_date_numbers(good_inds), greenness(good_inds), 'r.')
hold off
