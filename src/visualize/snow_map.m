addpath ~/matlab_root/
set(0,'Format','longg')


%% load data
base_dir = '/u/vul-d1/scratch/ryan/download_amos/AMOS_Data/';

% load the attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');

% load amos locations
locs = textscan(fopen('/u/vul-d1/scratch/ryan/download_amos/amos_locs.csv'), '%s%f%f', 'Delimiter', ',');

% pad the camera ids
for j = 1:size(locs{1}, 1)
  locs{1}(j) = cellstr(sprintf('%08d', str2double(locs{1}(j))));
end

% list all of the downloaded cameras
dirs = dir(base_dir);
dir_names = {dirs([dirs.isdir]).name};
dir_names = dir_names(3:end);

attribute = 10;
% vars in paper: 1, 15, 29
var = 29;

% for attribute = 1:40

mkdir(sprintf('maps/%s_maps_month/', attr{1}{attribute}));

% for var = 1:30

% day of month
if var < 10
  time = sprintf('2014010%d_18', var);
else
  time = sprintf('201401%d_18', var);
end

% % time of day
% if var < 10
%     time = sprintf('20140102_0%d', var);
% else
%     time = sprintf('20140102_%d', var);
% end

all_cams_data = [];

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
camid = str2double(locs{1}(cam_loc_inds));
data_lat = locs{2}(cam_loc_inds);
data_lon = locs{3}(cam_loc_inds);


%% plot a single attribute map
% extract attribute values and make one big list
attr_val = cell2mat(all_cams_data(:,2));

data_full = cat(2, data_lat, data_lon, attr_val, camid);
% remove alaska
data_full(data_full(:,2) < -125,:) = [];
% remove nova scotia/canada
data_full(data_full(:,2) > -66.9,:) = [];
data_full(data_full(:,1) > 49,:) = [];
% remove everything below florida
data_full(data_full(:,1) < 25,:) = [];

data_full(data_full(:,4) == 4786,:) = []; % this camera is on a white sand beach
data_full(data_full(:,4) == 18881,:) = []; % white roof tops
data_full(data_full(:,4) == 18997,:) = []; % white overlay on camera images
data_full(data_full(:,4) == 19816,:) = []; % not texas
data_full(data_full(:,4) == 17392,:) = []; % dried up river

% example_cams = [];
% example_cams = [example_cams; data_full(data_full(:,4) == 1110, 2), data_full(data_full(:,4) == 1110, 1)];
% example_cams = [example_cams; data_full(data_full(:,4) == 12369, 2), data_full(data_full(:,4) == 12369, 1)];
% example_cams = [example_cams; data_full(data_full(:,4) == 17952, 2), data_full(data_full(:,4) == 17952, 1)];

% make smooth map
[smooth_map, lon_centers, lat_centers, alpha] = make_smooth_map(data_full(:,3), [data_full(:,1) data_full(:,2)]);

% plot map
% close all
figure(1); clf;
image(imread('~/matlab_root/bmng.jpg'), 'XData', [-180 180], 'YData', [90 -90])
hold on
shp = shaperead('usastatelo', 'UseGeoCoords', true, 'Selector',...
  {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
imagesc(smooth_map, 'XData', lon_centers, 'YData', lat_centers, 'AlphaData', smooth_map, [.2 .4]);
plot([shp.Lon], [shp.Lat], 'k')
% text(data_full(:,2),data_full(:,1), num2str(data_full(:,4)), 'FontSize', 10)
% scatter(example_cams(:,1), example_cams(:,2), 100, 'b.')
load coast
geoshow(flipud(lat),flipud(long),'DisplayType','polygon','FaceColor',[0 0 .3])

% hold off
set(gca, 'XTick', [], 'YTick', [])
axis image xy
colormap(gray(50))
xlim([-125 -67])
ylim([25 49])

% title(strcat(attr{1}{attribute}, '_', time, '0000'), 'interpreter', 'none')

export_fig(sprintf('maps/%s_maps_month/%s_%d.png', attr{1}{attribute}, attr{1}{attribute}, var))

% end
% end

%% good cameras

D = L2_distance(data_full(:,[1 2])', data_full(:,[1,2])');
