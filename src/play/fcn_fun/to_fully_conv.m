addpath ~/projects/research/caffe/matlab/

fc_layers = {'fc6', 'fc7', 'fc8-t'};
fcn_layers = {'fcn6', 'fcn7', 'fcn8'};

assert(numel(fc_layers) == numel(fcn_layers));

% caffe input files
deploy_file = 'deploy.net';
deploy_file_new = 'deploy_fcn.net';
weights = 'transientneth.caffemodel';
weights_new = 'fcn.caffemodel';

% initialize network
caffe.set_mode_cpu()
net = caffe.Net(deploy_file, weights, 'test');
net_new = caffe.Net(deploy_file_new, weights, 'test'); % initialize 


%% net surgery (fcx -> fcnx)

for ix = 1:numel(fc_layers)
  % set weights
  weight = net.params(fc_layers{ix}, 1).get_data();
  weight = reshape(weight, size(net_new.params(fcn_layers{ix}, 1).get_data()));
  net_new.params(fcn_layers{ix}, 1).set_data(weight);
  
  % set bias
  bias = net.params(fc_layers{ix}, 2).get_data();
  bias = reshape(bias, size(net_new.params(fcn_layers{ix}, 2).get_data()));  
  net_new.params(fcn_layers{ix}, 2).set_data(bias);
end


%% save new model

net_new.save(weights_new);
