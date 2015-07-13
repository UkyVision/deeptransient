%
% what can you dooooo
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

if true
  % find daylight images (sun above the horizon) 
  location = struct('latitude',  loc(1), ...
    'longitude', loc(2), ...
    'altitude',  altitude);
  
  sun_locations = cellfun(@(x) sun_position(datestr(x), location), num2cell(date_numbers));
  elevations = 90 - [sun_locations.zenith];
  
  date_numbers = date_numbers(elevations > 0);
  features = features(elevations > 0, :);
  hays_features = hays_features(elevations > 0, :);
end

local_date_numbers = date_numbers + (utc_offset/24);


%%

iLabel = 40;

figure(1); clf;
plot(local_date_numbers, features(:, iLabel), 'r.')
hold on
plot(local_date_numbers, hays_features(:, iLabel), 'g.')
hold off
set(gca, 'XTickLabel', linspace(0,24,25), 'XTick', linspace(0,1,25))
title(labels.Var1(iLabel))

figure(2); clf;
plot(mod(local_date_numbers, 1), features(:, iLabel), 'r.')
hold on
plot(mod(local_date_numbers, 1), hays_features(:, iLabel), 'g.')
hold off
set(gca, 'XTickLabel', linspace(0,24,25), 'XTick', linspace(0,1,25))
title(labels.Var1(iLabel))


%%

iLabel = 17;

ab = quantile(local_date_numbers,[0 1]);

figure(3); clf;
plot(local_date_numbers, features(:, iLabel), 'r.')
hold on
plot(local_date_numbers, hays_features(:, iLabel), 'g.')
hold off
set(gca, 'XTickLabel', datestr(linspace(ab(1) ,ab(2),10),'mmm'), 'XTick', linspace(ab(1) ,ab(2),10))
title(labels.Var1(iLabel))


%% average attribute per day

for iLabel = 1:40

days = floor(date_numbers);

day_inds = arrayfun(@(x) find(days==x), unique(days), 'uni', false);
avg_att = cellfun(@(x) mean(features(x, iLabel)), day_inds);
avg_hays_att = cellfun(@(x) mean(hays_features(x, iLabel)), day_inds);

ab = quantile(unique(days),[0 1]);

figure(4); clf;
plot(unique(days), avg_att, 'r.')
hold on
plot(unique(days), avg_hays_att, 'g.')
hold off
set(gca, 'YLim', [0 1])
set(gca, 'XTickLabel', datestr(linspace(ab(1), ab(2), 10),'mmm'), 'XTick', linspace(ab(1), ab(2), 10))
title(labels.Var1(iLabel))

pause

end