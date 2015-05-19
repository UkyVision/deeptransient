%
% How are the aerial features and ground features related to each other?
%

labels = load_places_labels();

label_ids = output{2};
Nc = max(label_ids);

%% How good are the predictions?

%
% Answer: not very good.
%

file1 = '/u/eag-d1/scratch/scott/temp/aerial_features.h5';
file2 = '/u/eag-d1/scratch/scott/temp/ground_features.h5';

fNames = h5read(file2, '/image_names');
features2 = h5read(file1, '/fc8_a')';
features1 = h5read(file2, '/fc8_g')';

% softmax
ap = exp(features2); ap = bsxfun(@rdivide,ap,sum(ap,2));
gp = exp(features1); gp = bsxfun(@rdivide,gp,sum(gp,2));

% assign label
[~,gl] = max(gp,[],2);
[~,al] = max(ap,[],2);

confusion_matrix = accumarray([gl, al], ones(size(gl)), [Nc Nc]);

imagesc(confusion_matrix)
xlabel('Predicted "Ground" Label')
ylabel('"Ground" Truth')

%% what labels tend to be confused?

disp('====================================')

Nclusters = 0; % set to zero to make each category have its own node

% NOTE: there is some code below that will provide the list of names of
% labels in clusters

%
% currently this performs a hierarchichal clustering and then reorders by
% the leaf index (put then in order of similarity)
%

gg = double( ...
  h5read( ...
  '/u/eag-d1/scratch/scott/temp/ground_features.h5', '/fc8_g'))';
ga = double( ...
  h5read( ...
  '/u/eag-d1/scratch/scott/temp/ground_a_features.h5', '/fc8_a'))';
aa = double( ...
  h5read( ...
  '/u/eag-d1/scratch/scott/temp/aerial_features.h5', '/fc8_a'))';
ag = double( ...
  h5read( ...
  '/u/eag-d1/scratch/scott/temp/aerial_g_features.h5', '/fc8_g'))';

rho_gg = corr(gg,gg);
rho_ga = corr(ga,ga);
rho_ag = corr(ag,ag);
rho_aa = corr(aa,aa);

% determine a good sort order based on joint activation of the places
% network applied to ground image

T = linkage(rho_aa, 'ward');
figure(10);
[~,assignment,ind] = dendrogram(T,Nclusters, 'Orientation', 'left', 'Label', labels);
ind = fliplr(ind);

% apply to all correlations
rho_gg = rho_gg(ind,ind);
rho_ga = rho_ga(ind,ind);
rho_ag = rho_ag(ind,ind);
rho_aa = rho_aa(ind,ind);

% if 0 < Nclusters
%   % show cluster sets
%   for ix = 1:Nclusters
%     labels_local(assignment == ind(ix))
%   end
% else
% show the correlation matrix
figure(3); clf;
subplot(131)
imagesc(rho_gg, [0 1])
axis image
% set(gca,'YTick',1:Nc,'YTickLabel', labels(ind))
label_skip = 5;
set(gca,'YTick',1:label_skip:Nc,'YTickLabel', labels(ind(1:label_skip:end)))
set(gca,'XTick', []);
title('Ground Images; Ground-Level Network')
% title('gg')
% export_fig(gcf,'activation_correlation_gg.png');

% figure(4); clf;
% imagesc(rho_ga, [0 1])
% set(gca,'YTick',1:Nc,'YTickLabel', labels(ind))
% axis image
% title('ga')

% figure(5); clf;
subplot(132)
imagesc(rho_ag, [0 1])
set(gca,'XTick', [], 'YTick', []);
axis image
title('Aerial Images; Ground-Level Network')
% title('ag')
% export_fig(gcf,'activation_correlation_ag.png');

% figure(6); clf;
subplot(133)
imagesc(rho_aa, [0 1])
axis image
set(gca,'XTick', [], 'YTick', []);
% set(gca,'YTick',1:Nc,'YTickLabel', labels(ind))
title('Aerial Images; Aerial Network')
exportfigure(gcf,'activation_correlations.pdf', 2.4*[8.8 2.4], 300);

%% how correlated are the different layers?

%
% Idea: later in the network it should be more correlated
%

file1 = '/u/eag-d1/scratch/scott/temp/ground_features.h5';
file2 = '/u/eag-d1/scratch/scott/temp/ground_a_features.h5';

layers = {'fc8','fc7','pool5','pool2','conv1'};

for ix = 1:numel(layers)
  layer = layers{ix};
  features1 = double(h5read(file1, ['/' layer '_g']));
  features2 = double(h5read(file2, ['/' layer '_a']));
  
  if layer(1) == 'f'
    features1 = features1';
    features2 = features2';
  else
    features1 = squeeze(features1(round(end/2),round(end/2),:,:))';
    features2 = squeeze(features2(round(end/2),round(end/2),:,:))';
  end
  
  % find the most similar node in the other network, compute the correlation,
  % average this for all nodes
  
  rho_gg = corr(features1,features2);
  fprintf('%s average correlation = %0.4f\n', layer, mean(rho_gg(:)));
  fprintf('%s average maximum correlation = %0.4f\n', layer, mean(max(rho_gg)));
  
end