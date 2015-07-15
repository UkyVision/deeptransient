%
% what can you dooooo
%

addpath ~/matlab_root/
addpath ~/projects/research/caffe/matlab/

base_dir = '/u/vul-d1/scratch/ryan/';

% the data he is using
data = readtable([base_dir '00007371/attributes.csv'], 'ReadVariableNames', false);
data = sortrows(data, {'Var1'}, {'ascend'});

labels = table2cell(readtable('./fcn_fun/attributes.txt', 'ReadVariableNames', false));


%% setup caffe

model_base = './fcn_fun/';
model = [model_base 'deploy.net'];
weights = [model_base 'transientneth.caffemodel'];

caffe.set_mode_cpu();
net = caffe.Net(model, weights, 'test'); % create net and load weights

mean_pixel = [105 115 118];

caffe_sz = [227 227];


%% 

fid = fopen('ours.csv', 'w');

for ix = 1:size(data,1)
  
  ix
  
  im = imread([base_dir data.Var1{ix}]);
  
  % pass it through caffe
  caffe_input = im(:, :, [3, 2, 1]); % make bgr
  caffe_input = permute(caffe_input, [2, 1, 3]); % make width the fastest dimension
  caffe_input = single(caffe_input); % convert from uint8 to single
  caffe_input = imresize(caffe_input, caffe_sz, 'bilinear'); % resize to caffe
  caffe_input = bsxfun(@minus, caffe_input, reshape(mean_pixel, [1 1 3])); % subtract mean
  
  result = net.forward({caffe_input});
  atts = result{1}';
  
  %   figure(1); clf;
  %   subplot(131)
  %   image(im)
  %   axis image off
  %   subplot(132)
  %   barh(data{ix, 2:end})
  %   set(gca, 'XLim', [0 1])
  %   set(gca, 'YTick', 1:40)
  %   set(gca,'YTickLabel', labels)
  %   title('ryan')
  %   subplot(133)
  %   barh(atts)
  %   title('us') 
  %   set(gca, 'XLim', [0 1])
  %   set(gca, 'YTick', 1:40)
  %   set(gca,'YTickLabel', labels)
  %   
  %   pause
  
  fprintf(fid, '%s,', data.Var1{ix});
  fprintf(fid, [repmat('%f,', [1 39]) '%f\n'], atts);
  
end

fclose(fid);