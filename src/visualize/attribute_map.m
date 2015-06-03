addpath ~/matlab_root/
set(0,'Format','longg')

%% street view images
%% load data
data_nonscenic = textscan(fopen('/u/amo-d0/grad/rbalten/research/scenic_labeling/data/non-scenic_transient_pred.csv'), strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');
data_scenic = textscan(fopen('/u/amo-d0/grad/rbalten/research/scenic_labeling/data/scenic_transient_pred.csv'), strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');

% extract file names and make one big list
fNames_nonscenic = data_nonscenic{1};
fNames_scenic = data_scenic{1};
fNames = cat(1, fNames_scenic, fNames_nonscenic);

% set up matrices to hold lat and lon coords
data_lat = zeros(size(fNames, 1), 1);
data_lon = zeros(size(fNames, 1), 1);

% loop over each image and extract the lat lon coords
% from the file name
for ix=1:size(fNames, 1)
    [~, coords, ~] = fileparts(fNames{ix});
    splits = strsplit(coords, '_');
    lat = str2double(splits(1));
    lon = str2double(splits(2));
        
    data_lat(ix) = lat;
    data_lon(ix) = lon;
    
    if mod(ix, 1000) == 0
       fprintf('Processed %d of %d\n', ix, size(fNames,1)) 
    end
end

% load the attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');

%% loop through all attribute maps
for j=2:41
    % extract the attribute values and make one big list
    attr_to_plot = j;
    attr_val = cat(1, data_scenic{attr_to_plot}, data_nonscenic{attr_to_plot});

    % remove alaska images
    data_full = cat(2, data_lat, data_lon, attr_val);
    data_full(data_full(:,2) < -130,:) = [];
    
    % make smooth map
    [smooth_map, lon_centers, lat_centers, alpha] = make_smooth_map(data_full(:,3), [data_full(:,1) data_full(:,2)]);

    % plot the smooth map
    figure(1); clf;
    axes('Position', [0 0 1 1]);
    imagesc(smooth_map, 'XData', lon_centers, 'YData', lat_centers, 'AlphaData', alpha);
    axis image xy off
    %colorbar('SouthOutside')
    colormap(jet(256))
    title(attr{1}{j - 1})
    pause
end

%% plot a single attribute map
% extract attribute values and make one big list
attr_to_plot = 40 + 1;
attr_val = cat(1, data_scenic{attr_to_plot}, data_nonscenic{attr_to_plot});

% remove alaska images
data_full = cat(2, data_lat, data_lon, attr_val);
data_full(data_full(:,2) < -130,:) = [];

% make smooth map
[smooth_map, lon_centers, lat_centers, alpha] = make_smooth_map(data_full(:,3), [data_full(:,1) data_full(:,2)]);

% plot smooth map
figure(1); clf;
axes('Position', [0 0 1 1]);
imagesc(smooth_map, 'XData', lon_centers, 'YData', lat_centers, 'AlphaData', alpha);
axis image xy off
%colorbar('SouthOutside')
colormap(jet(256))
title(attr{1}{attr_to_plot - 1})

%% flickr images
%% load data
data_flickr = textscan(fopen('/u/amo-d0/grad/rbalten/research/scenic_labeling/data/flickr_transient_pred.csv'), strcat('%s%f%f%s',repmat('%f', 1, 40)), 'delimiter', ',');

to_clear = isnan(data_flickr{end});

for ind=1:size(data_flickr, 2)
   data_flickr{ind}(to_clear) = []; 
end

% extract file names and make one big list
fNames = data_flickr{4};

% set up matrices to hold lat and lon coords
data_lat = zeros(size(fNames, 1), 1);
data_lon = zeros(size(fNames, 1), 1);

% loop over each image and extract the lat lon coords
% from the file name
for ix=1:size(fNames, 1)
    [~, coords, ~] = fileparts(fNames{ix});
    splits = strsplit(coords, '_');
    lat = str2double(splits(3));
    lon = str2double(splits(4));
        
    data_lat(ix) = lat;
    data_lon(ix) = lon;
    
    if mod(ix, 1000) == 0
       fprintf('Processed %d of %d\n', ix, size(fNames,1)) 
    end
end

% load the attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');

%% loop through all attribute maps
for j=5:44
    % extract the attribute values and make one big list
    attr_to_plot = j;
    attr_val = data_flickr{attr_to_plot};

    % remove alaska images
    data_full = cat(2, data_lat, data_lon, attr_val);
    data_full(data_full(:,2) < -130,:) = [];
    
    % make smooth map
    [smooth_map, lon_centers, lat_centers, alpha] = make_smooth_map(data_full(:,3), [data_full(:,1) data_full(:,2)]);

    % plot the smooth map
    figure(1); clf;
    axes('Position', [0 0 1 1]);
    imagesc(smooth_map, 'XData', lon_centers, 'YData', lat_centers, 'AlphaData', alpha);
    axis image xy off
    %colorbar('SouthOutside')
    colormap(jet(256))
    title(attr{1}{j - 4})
    pause
end

%% plot a single attribute map
% extract attribute values and make one big list
attr_to_plot = 40 + 4;
attr_val = data_flickr{attr_to_plot};

% remove alaska images
data_full = cat(2, data_lat, data_lon, attr_val);
data_full(data_full(:,2) < -130,:) = [];

% make smooth map
[smooth_map, lon_centers, lat_centers, alpha] = make_smooth_map(data_full(:,3), [data_full(:,1) data_full(:,2)]);

% plot smooth map
figure(1); clf;
axes('Position', [0 0 1 1]);
imagesc(smooth_map, 'XData', lon_centers, 'YData', lat_centers, 'AlphaData', alpha);
axis image xy off
%colorbar('SouthOutside')
colormap(jet(256))
title(attr{1}{attr_to_plot - 4})