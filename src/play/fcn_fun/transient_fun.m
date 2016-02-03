addpath ~/matlab_root
addpath ~/software/caffe/matlab/
addpath ~/matlab_root/export_fig/


%% setup caffe

model_base = './';
model = [model_base 'deploy_fcn.net'];
weights = [model_base 'fcn.caffemodel'];

caffe.set_mode_cpu();
net = caffe.Net(model, weights, 'test'); % create net and load weights

mean_pixel = [105 115 118];


%% process each image

% fname = 'farm.jpg';
fname = '82.jpg';
% fname = 'gloomy.jpg';

im = imread(fname); 
sz = size(im); sz = sz(1:2);

% reshape the data blob to fit input size
net.blobs('data').reshape([sz(2), sz(1), 3, 1]);

% pass it through caffe
caffe_input = im(:, :, [3, 2, 1]); % make bgr
caffe_input = permute(caffe_input, [2, 1, 3]); % make width the fastest dimension
caffe_input = single(caffe_input); % convert from uint8 to single
caffe_input = bsxfun(@minus, caffe_input, reshape(mean_pixel, [1 1 3])); % subtract mean

result = net.forward({caffe_input});
result_im = result{1};
result_im = permute(result_im, [2, 1, 3]); % make height the fastest dimension
result_im_smooth = imfilter(result_im, fspecial('Gaussian', [11 11], 2), 'replicate');


%% visualize each transient label separately 
 
labels = readtable('attributes.txt', 'ReadVariableNames', false);

for ix = 1:40
  
  figure(1); clf; 
  subplot(121)
  image(im); 
  axis image off
  
  subplot(122)
  imagesc(result_im(:,:,ix), [0 1])
  axis image off
  title(labels.Var1{ix})
  
  pause
  
end


%% composite image

[~, ind_im] = max(result_im, [], 3);

unique_inds = unique(ind_im);
aa = zeros(1,numel(labels)); 
aa(unique_inds) = 1:numel(unique_inds);

cmap = distinguishable_colors(numel(unique_inds));

figure(2); clf;
subplot(121)
image(im)
axis image off

subplot(122)
imshow(aa(ind_im), cmap)
axis image off
h = colorbar;
set(h, 'YTick', linspace(1, numel(unique_inds), numel(unique_inds)))
set(h,'YTickLabel', table2cell(labels(unique_inds,:)))


%% false color image from specific classes

good_inds = [6 9 10]; 

figure(2); clf;
% subplot(221)
pos1 = [0.13, 0.485, 0.33, 0.33];
subplot('Position',pos1)
image(im)
title('Original Image')
axis image off

channels = scale2rgb(result_im(:,:,good_inds));
channels = imresize(channels, [size(im,1) size(im,2)]);
channels(channels < 0) = 0;
channels(channels > 1) = 1;

channels_colo = [];
channels_colo(:,:,1) = [channels(:,:,1), zeros(size(channels, 1), size(channels, 2)), zeros(size(channels, 1), size(channels, 2))];
channels_colo(:,:,2) = [zeros(size(channels, 1), size(channels, 2)), channels(:,:,2), zeros(size(channels, 1), size(channels, 2))];
channels_colo(:,:,3) = [zeros(size(channels, 1), size(channels, 2)), zeros(size(channels, 1), size(channels, 2)), channels(:,:,3)];


channels = reshape(permute(channels, [1 2 3]), [size(channels, 1) 3 * size(channels,2)]);
subplot(2,2,[3,4])
imagesc(channels_colo)
title('Color Channels')
axis image off

composite = imresize(scale2rgb(result_im(:,:,good_inds)), [size(im,1) size(im,2)]);
composite(composite< 0) = 0;
composite(composite > 1) = 1;

% subplot(222)
pos1 = [0.575, 0.485, 0.33, 0.33];
subplot('Position',pos1)
imagesc(composite)
title('Composite Image')
axis image off

% export_fig('false_color_82.pdf', '-transparent', '-m1,5')
