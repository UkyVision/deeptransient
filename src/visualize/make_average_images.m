
%
% make average images following the method from the places paper
%
% - For each node, average the images with the top 100 activations
% - Sort the average images many different ways and make montages and save
% the output 
%

%
% TODO eliminate the need to use the montage command and export_fig
%

function make_average_images(imageset,weightset,layer,Naverage)

base_dir = sprintf('/u/eag-d1/scratch/ryan/webcams/%s/features/transientneth/', imageset);

addpath ~/matlab_root/
addpath ~/matlab_root/export_fig/

sz = [100 100]; % output image size;

% choose a subset of this many nodes
% (set it to <= 0 to compute averages for all)
MAX_ACTIVATIONS = 0;

output_base = './activation_averages/';

outdir = sprintf('%s%s_on_%s_%s_%i/',output_base,imageset,weightset,layer,Naverage);
if ~exist(outdir, 'dir')
  mkdir(outdir)
end

% load image names (for current set and the ground set, so we can filter
% out streetview)

% f_images = [base_dir imageset '_features.h5'];
% fNames = h5read(f_images, '/image_names');
fNames = textscan(fopen(sprintf('/u/eag-d1/scratch/ryan/webcams/%s/features/transientneth/image_names.txt', imageset)), '%s');


% load weights
f_weights = [base_dir weightset '_features_' layer '.h5'];

features = h5read(f_weights, '/features');

%
% find top K images for each node
%

switch layer(1)
  case {'c','p'} % convolutional layers
    % extract the middle
    features_extract = squeeze(features(round(end/2),round(end/2),:,:))';
  case 'f' % fully connected layers
    features_extract = features';
end

% pick a subset of nodes
if 0 < MAX_ACTIVATIONS && MAX_ACTIVATIONS < size(features_extract,2)
  disp('Randomly shuffling.')
  rng(0); rp = randperm(size(features_extract,2));
  features_extract = features_extract(:,rp(1:min(MAX_ACTIVATIONS,end)));
end

% randomize the activations (an interesting baseline for comparison)
% features_extract = rand(size(features_extract));

[~, inds] = sort(features_extract, 'descend');
inds_K = inds(1:Naverage,:);

Nnodes = size(inds,2);

% make a matrix that is zero except for the top K
valid_matrix = false(size(inds));
valid_matrix(sub2ind(size(inds),inds_K,repmat(1:size(inds_K,2), [Naverage 1]))) = 1;
valid_matrix = reshape(valid_matrix,size(inds,1),1,1,size(inds,2));

% only open the images we have to
valid_ids = unique(inds_K);

%
% accumulate a running sum and the count for each node
%
% keeping a count per image is nice so we can make average images
% incrementally during computation
%

ims_accum = zeros(sz(1),sz(2),3,size(inds,2));
count_accum = zeros(size(valid_matrix(1,1,1,:)));

for ix = 1:numel(valid_ids)
  
  fprintf('progress: %d of %d\n', ix, numel(valid_ids));
  
  id = valid_ids(ix);
  
  im = imread(char(fNames{1}(id)));
  im = imresize(im, sz);
  im = im2double(im);
  
  in_top_k = valid_matrix(id,:,:,:);
  
  %   where_to_add = find(in_top_k)';
  %   for jx = where_to_add
  %     ims_accum(:,:,:,jx) = ims_accum(:,:,:,jx) + im;
  %   end
  
  ims_accum(:,:,:,in_top_k) = bsxfun(@plus,ims_accum(:,:,:,in_top_k), im);
  
  if false && mod(ix,30) == 0
    im_means = max(min(bsxfun(@rdivide,ims_accum,count_accum),1),0);
    figure(1); clf;
    montage(im_means)
    pause(.5);
  end
  
  count_accum = count_accum + in_top_k;
  
end

% compute mean images
im_means = max(min(bsxfun(@rdivide,ims_accum, count_accum),1),0);

%% montage with attribute names

% load up attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');

im_prune = cat(4, im_means(:,:,:,2), im_means(:,:,:,3), im_means(:,:,:,4), im_means(:,:,:,8), ...
            im_means(:,:,:,10), im_means(:,:,:,11), im_means(:,:,:,17), im_means(:,:,:,18), ...
            im_means(:,:,:,19));

% montage means and overlay attribute name
attr_num = 0;
montage(im_means)
for y=6:100:606
   for x=3:100:603
       attr_num = attr_num + 1;
       if attr_num < 41
          text(x,y,attr{1}(attr_num), 'Color', [.7 0 0]) 
       end
   end
end

% save out montage
exportfigure(gcf, sprintf('%smontage_cam_%s.pdf',outdir, imageset), [10 10], 300)


%% pruned montage

% load up attribute names
attr = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');
attr = cat(2, attr{1}(2), attr{1}(3), attr{1}(4), attr{1}(8), attr{1}(40), attr{1}(11), attr{1}(17), ...
           attr{1}(18), attr{1}(19));

im_prune = cat(4, im_means(:,:,:,2), im_means(:,:,:,3), im_means(:,:,:,4), im_means(:,:,:,8), ...
            im_means(:,:,:,40), im_means(:,:,:,11), im_means(:,:,:,17), im_means(:,:,:,18), ...
            im_means(:,:,:,19));

        
% montage means and overlay attribute name
attr_num = 0;
montage(im_prune)
for y=6:100:206
   for x=3:100:203
       attr_num = attr_num + 1;
       text(x,y,attr(attr_num), 'Color', [.7 0 0]) 
   end
end
        
% save out montage
exportfigure(gcf, sprintf('%smontage_pruned_cam_%s.pdf',outdir, imageset), [10 10], 300)
        
%% output all images

for ix = 1:Nnodes
  imwrite(im_means(:,:,:,ix),...
    sprintf('%s/z_%05.0f_%s.jpg',outdir,ix,char(attr{1}(ix))));
end

% make the montages sorted a few different ways

sorts = {'image-pca','activation-pca',...
  'activation-average','activation-max'};

for ix = 1:numel(sorts)
  
  %
  % sort the montages a few different ways (sorted by some property of the
  % node, either the activations or the associated montage image)
  %
  
  sort_by = sorts{ix};
  
  switch sort_by
    case 'image-pca'
      [~, ~, V] = svd(cov(reshape(im_means,[],Nnodes)));
      val = V(:,1);
    case 'activation-pca'
      [~, ~, V] = svd(cov(features_extract));
      val = V(:,1);
    case 'activation-average'
      val = mean(features_extract,1);
    case 'activation-max'
      val = max(features_extract,[],1);
  end
  [~,im_mean_order] = sort(val);
  
  
  % choose a subset of nodes to show
  switch layer
    case 'fc7'
      N_to_show = 96;
    case 'pool2'
      N_to_show = 32;
    otherwise
      N_to_show = Nnodes;
  end
  
  im_mean_order = im_mean_order(round(linspace(1,end,N_to_show)));
  
  %% output some montages
  
  figure(1); clf;
  switch layer
    case {'fc8-t','pool5'}
      output_size = [16 NaN];
    case {'conv1','pool2'}
      output_size = [8 NaN];
  end
  montage(im_means(:,:,:,im_mean_order),'Size', output_size);
  export_fig(gcf,sprintf('%smontage_all_%s.jpg', outdir,sort_by));
  
  figure(2); clf;
  montage(im_means(:,:,:,im_mean_order([1:5 end-4:end])), 'Size', [2 5]);
  export_fig(gcf,sprintf('%smontage_extremes_%s.jpg', outdir,sort_by));
  
  
  %% show imscatter
  
  %if strcmp(sort_by, 'activation-pca')
  %  figure(60); clf;
  %  axes('Position', [0 0 1 1]);
  %  hold on
  %  imscatter(V(:,1), V(:,2), im_means, .0002)
  %  hold off
  %  axis ij off
  %  export_fig(gcf,sprintf('%smontage_scatter.jpg', outdir), '-m2');
  %end
  
end


