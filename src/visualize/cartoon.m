addpath ~/matlab_root/

%% load data

% load attributes
base_dir = '/u/vul-d1/scratch/ryan/stable_cam_data/00008953/';
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');

fid = fopen(char(strcat(base_dir, '2013_attributes.csv')));
data_cam = textscan(fid, strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');

% pull out selected attributes
attrs_to_plot = [0 2 3 7 10 40]; % 0 to keep the file names
attrs_to_plot = attrs_to_plot + 1;
data_to_plot = data_cam(attrs_to_plot);

%% plot data
im_id = 750;
clf;

% display image
% subplot(2,3, [1:2,4:5])
axes('Position', [0.01 0.15 0.75 0.75])
image(imread(char(data_to_plot{1}(im_id))))
axis image ij off


% make attribute 'stoplight'
% subplot(2,3, [3,6])
axes('Position', [0.45 0.15 0.75 0.75])
hold on;
plot([0 1 1 0 0 0 1 1 0 0 1 1 0],[0 0 5 5 0 1 1 2 2 3 3 4 4], 'k'); 

% text(1.1,4.5,'\itDaylight', 'FontSize', 18)
fill([0 1 1 0],[4 4 5 5], data_to_plot{2}(im_id));

% text(1.1,3.5,'\itNight', 'FontSize', 18)
fill([0 1 1 0],[3 3 4 4], data_to_plot{3}(im_id));

% text(1.1,2.5,'\itClouds', 'FontSize', 18)
fill([0 1 1 0],[2 2 3 3], data_to_plot{4}(im_id));

% text(1.1,1.5,'\itSnow', 'FontSize', 18)
fill([0 1 1 0],[1 1 2 2], data_to_plot{5}(im_id));

% text(1.1,0.5,'\itLush', 'FontSize', 18)
fill([0 1 1 0],[0 0 1 1], data_to_plot{6}(im_id));

set(gca, 'Clim', [0 1])
colormap(jet(100))
axis equal tight off;
hold off;

% export_fig('19106_3730.pdf', '-transparent')

