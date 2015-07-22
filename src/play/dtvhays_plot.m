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

if false && true
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

example_ims = [48 171 305];
example_im_colors = ['r', 'g', 'b'];

% recover image names from datenums
im_names = datestr(date_numbers(example_ims * 20), 'yyyymmdd_HHMMSS');
folder_names = datestr(date_numbers(example_ims * 20), 'yyyy.mm');

% display the example images with a border corresponding
% to the highlight color in the plot
for ix = 1:3
   figure(ix*3); clf;
   example_image = imread(strcat(base_dir, folder_names(ix,:), '/', im_names(ix,:), '.jpg')); 
   imagesc(example_image)
   axis image
   set(gca, 'TickLength', [0,0])
   set(gca, 'Color', example_im_colors(ix))
   set(gca, 'XColor', example_im_colors(ix))
   set(gca, 'YColor', example_im_colors(ix))
   set(gca, 'LineWidth', 6)
   set(gca, 'XTick', 0)
   set(gca, 'YTick', 0)
end

for iLabel = 1:40

    days = floor(date_numbers);

    day_inds = arrayfun(@(x) find(days==x), unique(days), 'uni', false);
    avg_att = cellfun(@(x) mean(features(x, iLabel)), day_inds);
    avg_hays_att = cellfun(@(x) mean(hays_features(x, iLabel)), day_inds);

    ab = quantile(unique(days),[0 1]);

    days_to_plot = unique(days);
    
    figure(1004); clf;
    subplot(211)
    imagesc(avg_att', [0 1])
    subplot(212)
    imagesc(avg_hays_att', [0 1])
    
    figure(1005); clf;
    subplot(121)
    % + .005*randn(size(date_numbers))
    scatter(mod(date_numbers,1),floor(date_numbers), 20,features(:, iLabel), 'filled')
    set(gca, 'CLim', [0 1])
    subplot(122)
    scatter(mod(date_numbers,1),floor(date_numbers), 20,hays_features(:, iLabel), 'filled')   
    set(gca, 'CLim', [0 1])
    
    figure(4); clf;
    hold on

    % plot the full data
    plot(days_to_plot, avg_att, 'kx')
    plot(days_to_plot, avg_hays_att, 'k.')

    % highlight the example images
    plot(days_to_plot(example_ims(1)), avg_att(example_ims(1)), 'ro', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(1)), avg_hays_att(example_ims(1)), 'ro', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(2)), avg_att(example_ims(2)), 'go', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(2)), avg_hays_att(example_ims(2)), 'go', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(3)), avg_att(example_ims(3)), 'bo', 'MarkerSize', 10);
    plot(days_to_plot(example_ims(3)), avg_hays_att(example_ims(3)), 'bo', 'MarkerSize', 10);

    hold off
    set(gca, 'YLim', [0 1])
    set(gca, 'YTick', [0 1])
    ylabel('Attribute Value')
    xlabel('Date')
    set(gca, 'XTickLabel', datestr(linspace(ab(1), ab(2), 10),'mmm'), 'XTick', linspace(ab(1), ab(2), 10))
    title(labels.Var1(iLabel))

    pause

end