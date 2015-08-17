addpath ~/matlab_root/
set(0,'Format','longg')


%% load data
base_dir = '/u/vul-d1/scratch/ryan/download_amos/AMOS_Data/';

% load the attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');

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

for attribute = 1:40

mkdir(sprintf('maps/%s_maps_month/', attr{1}{attribute}));

for var = 1:30

if var < 10
    time = sprintf('2014010%d_18', var);
else
    time = sprintf('201401%d_18', var);
end
    
all_cams_data = [];

% attribute = 10;

for ix = 1:size(dir_names, 2)
    try
        fid = fopen(char(strcat(base_dir, dir_names(ix), '/2014.01/attributes.csv')));
        data_cam = textscan(fid, strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');
    catch
       continue 
    end
    
    if var < 10
        ims = strfind([data_cam{1}], time);
    else
        ims = strfind([data_cam{1}], time);
    end
    ims_inds = find(not(cellfun('isempty', ims)));
    
    if not(isempty(ims_inds))
        all_cams_data = [all_cams_data; dir_names(ix), data_cam{attribute + 1}(ims_inds(1))];
    end
    
    fclose(fid);
    
    if mod(ix, 100) == 0
       fprintf(sprintf('Day: %d, Processed %d of %d\n', var, ix, size(dir_names, 2))) 
    end
end

if not(isempty(all_cams_data))
    cam_loc_inds = [];
    for k = 1:size(all_cams_data, 1)
        [m, i] = ismember(all_cams_data(k,1), locs{1});

        if m
            cam_loc_inds = [cam_loc_inds; i];
        end
        
        if mod(k, 100) == 0
            fprintf(sprintf('Day: %d, Processed %d of %d\n', var, k, size(all_cams_data, 1))) 
        end
    end
else
    continue
end

% get the lat and lon of cams
data_lat = locs{2}(cam_loc_inds);
data_lon = locs{3}(cam_loc_inds);


%% plot a single attribute map
% extract attribute values and make one big list
attr_val = cell2mat(all_cams_data(:,2));

data_full = cat(2, data_lat, data_lon, attr_val);
% remove alaska
data_full(data_full(:,2) < -125,:) = [];
% remove nova scotia/canada
data_full(data_full(:,2) > -66.9,:) = [];
data_full(data_full(:,1) > 49,:) = [];
% remove everything below florida
data_full(data_full(:,1) < 25,:) = [];

% make smooth map
[smooth_map, lon_centers, lat_centers, alpha] = make_smooth_map(data_full(:,3), [data_full(:,1) data_full(:,2)]);

% plot map
shp = shaperead('usastatelo', 'UseGeoCoords', true, 'Selector',...
  {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});   
close all
figure(1); clf;
axes('Position', [0 0 1 1]);
imagesc(smooth_map, 'XData', lon_centers, 'YData', lat_centers, 'AlphaData', alpha, [0 1]);
axis image xy off
hold on
plot([shp.Lon], [shp.Lat], 'k')
hold off
axis image xy off
colormap(jet(256))
title(strcat(attr{1}{attribute}, '_', time, '0000'), 'interpreter', 'none')

exportfigure(gcf, sprintf('maps/%s_maps_month/%s_%d.pdf', attr{1}{attribute}, attr{1}{attribute}, var), [9 6], 400)

end
end