%% load known webcam locations
addpath ~/matlab_root/

% load data
amos_data = textscan(fopen('/u/amo-d0/grad/rbalten/research/deeptransient/src/visualize/data/amos_locs.csv'), '%d,%f,%f', 'headerlines', 1);

% split data into separate vars
ids = amos_data{1};
lats = amos_data{2};
lons = amos_data{3};


% scatter plot of all known webcam locations
scatter(lons, lats, '.');


%% find camera locations
% load amos camera ids
cams = textscan(fopen('data/cams.txt'), '%s');
cams = str2num(cell2mat(cams{1}));

% find amos cam ids in known location ids
cam_ids = [];
for ix=1:numel(cams)
   cam_ids = [cam_ids; find(ids == cams(ix))];
end

% get locations of my cams
cam_locs = [lats(cam_ids) lons(cam_ids)];

% plot my cams overtop of all cams
scatter(lons,lats,'blue','.')
hold on
scatter(cam_locs(:,2), cam_locs(:,1), 'red', '.')

%% load transient features
% load camera 1 features and image names
imageset = '00005020';
weightset = 'transientneth';
layer = 'fc8-t';
base_dir = sprintf('/u/eag-d1/scratch/ryan/webcams/%s/features/transientneth/', imageset);

f_weights = [base_dir weightset '_features_' layer '.h5'];
features1 = h5read(f_weights, '/features');
fNames1 = textscan(fopen(sprintf('/u/eag-d1/scratch/ryan/webcams/%s/features/transientneth/image_names.txt', imageset)), '%s');
fNames1 = fNames1{1};


% load camera 2 features and image names
imageset = '00005021';
weightset = 'transientneth';
layer = 'fc8-t';
base_dir = sprintf('/u/eag-d1/scratch/ryan/webcams/%s/features/transientneth/', imageset);

f_weights = [base_dir weightset '_features_' layer '.h5'];
features2 = h5read(f_weights, '/features');
fNames2 = textscan(fopen(sprintf('/u/eag-d1/scratch/ryan/webcams/%s/features/transientneth/image_names.txt', imageset)), '%s');
fNames2 = fNames2{1};

%% cca and other experiments

[A,B,r,U,V] = canoncorr(features1(:,1:9000)', features2(:,1:9000)');

plot(U(:,1),V(:,1),'.')

figure(1)
imagesc(features1(:,1:9000))
figure(2)
imagesc(features2(:,1:9000))
% figure(3)
% imagesc(features1(:,1:9000) - features2(:,1:9000))
