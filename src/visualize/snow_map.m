addpath ~/matlab_root/
set(0,'Format','longg')


%% load data
base_dir = '/u/vul-d1/scratch/ryan/download_amos/AMOS_Data/';

locs = textscan(fopen('data/amos_locs.csv'), '%f%f%f', 'Delimiter', ',');

dirs = dir(base_dir);
dir_names = {dirs([dirs.isdir]).name};
dir_names = dir_names(3:end);

% want image from 01/05 around 1415

data_flickr = textscan(fopen('/u/amo-d0/grad/rbalten/research/scenic_labeling/data/flickr_transient_pred.csv'), strcat('%s%f%f%s',repmat('%f', 1, 40)), 'delimiter', ',');




% load the attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');


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