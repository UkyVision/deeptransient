addpath ~/matlab_root
addpath ~/projects/research/caffe/matlab/


%% setup caffe

model_base = './';
model = [model_base 'deploy_fcn.net'];
weights = [model_base 'fcn.caffemodel'];

caffe.set_mode_cpu();
net = caffe.Net(model, weights, 'test'); % create net and load weights

mean_pixel = [105 115 118];


%% process each image

% fname = 'farm.jpg';
fname = 'lush.png';
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

good_inds = [6 40 10]; 

figure(2); clf;
subplot(121)
image(im)
axis image off

subplot(122)
imagesc(scale2rgb(result_im(:,:,good_inds)))
axis image off

