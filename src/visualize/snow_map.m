addpath ~/matlab_root/
set(0,'Format','longg')


%% load data
base_dir = '/u/vul-d1/scratch/ryan/download_amos/AMOS_Data/';

% load amos locations
locs = textscan(fopen('data/amos_locs.csv'), '%s%f%f', 'Delimiter', ',');

% pad the camera ids
for j = 1:size(locs{1}, 1)
   locs{1}(j) = cellstr(sprintf('%08d', str2double(locs{1}(j)))); 
end

% list all of the downloaded cameras
dirs = dir(base_dir);
dir_names = {dirs([dirs.isdir]).name};
dir_names = dir_names(3:end);

% want image from 01/05 around 1415
% grab single image from every camera and
% its value for the snow attribute
all_cams_data = [];

for ix = 1:size(dir_names, 2)
    try
        fid = fopen(char(strcat(base_dir, dir_names(ix), '/2014.01/attributes.csv')));
        data_cam = textscan(fid, strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');
    catch
       continue 
    end
    
    ims = strfind([data_cam{1}], '20140105_14');
    ims_inds = find(not(cellfun('isempty', ims)));
    
    if not(isempty(ims_inds))
        all_cams_data = [all_cams_data; dir_names(ix), data_cam{10 +1}(ims_inds(1))];
    end
    
    fclose(fid);
end

% load the attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');


%% plot a single attribute map
% extract attribute values and make one big list
attr_val = all_cams_data(:,2);

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