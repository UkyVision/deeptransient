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


%% plot everything

example_ims = [2 40 80];

for iLabel = 1:40

    days = floor(date_numbers);

    day_inds = arrayfun(@(x) find(days==x), unique(days), 'uni', false);
    avg_att = cellfun(@(x) mean(features(x, iLabel)), day_inds);
    avg_hays_att = cellfun(@(x) mean(hays_features(x, iLabel)), day_inds);

    ab = quantile(unique(days),[0 1]);

    days_to_plot = unique(days);
    
    figure(4); clf;
    hold on

    % plot the full data
    plot(days_to_plot, avg_att, 'r.')
    plot(unique(days), avg_hays_att, 'g.')

    % highlight the example images
    plot(days_to_plot(example_ims(1)), avg_att(example_ims(1)), 'bo', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(1)), avg_hays_att(example_ims(1)), 'bo', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(2)), avg_att(example_ims(2)), 'mo', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(2)), avg_hays_att(example_ims(2)), 'mo', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(3)), avg_att(example_ims(3)), 'ko', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(3)), avg_hays_att(example_ims(3)), 'ko', 'MarkerSize', 10);

    hold off
    set(gca, 'YLim', [0 1])
    set(gca, 'YTick', [0 1])
    ylabel('Attribute Value')
    xlabel('Date')
    set(gca, 'XTickLabel', datestr(linspace(ab(1), ab(2), 10),'mmm'), 'XTick', linspace(ab(1), ab(2), 10))
    title(labels.Var1(iLabel))

    pause

end