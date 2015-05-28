%
% image embedings
%

addpath ~/matlab_root/drtoolbox/techniques

predictions = h5read('predictions.h5', '/feat');
imageNames = h5read('predictions.h5', '/name');

ids = randperm(size(predictions,1), min(size(predictions,1),1000));
predictions = predictions(ids,:);
imageNames = imageNames(ids);

Nimages = numel(ids);

%% dimension reduction
%
% tsne
%
xy = tsne(predictions);


%% fit to grid

%
% define grid
%

% try different grid size, choose the one with x occupancy-rate
for Ngrids = 10:1000
  
  x_range = [min(xy(:,1)), max(xy(:,1))];
  y_range = [min(xy(:,2)), max(xy(:,2))];
  Xs = linspace(x_range(1), x_range(2), Ngrids);
  Ys = linspace(y_range(1), y_range(2), Ngrids);
  
  %
  % register images to grid
  %
  xids = arrayfun(@(x) find(histc(x, Xs)), xy(:,1));
  yids = arrayfun(@(y) find(histc(y, Ys)), xy(:,2));
  
  inds = sub2ind([Ngrids, Ngrids], xids, yids);
  occupancy_rate = numel(unique(inds)) / Ngrids / Ngrids;
  
  if occupancy_rate < .4
    break
  end
  
end


%
% prepair visualization
%
res = size(imread('imgs/0.jpg'));
xres = res(2); yres = res(1);

% image coordinate when plot to grid
xs = xids * xres;
ys = yids * yres;

embeddings = repmat(struct('name',[], 'x', [], 'y', []), Nimages, 1);
for ix = 1:Nimages
  embeddings(ix).name = imageNames{ix};
  embeddings(ix).x = xs(ix);
  embeddings(ix).y = ys(ix);
end

% shuffle the order
embeddings = embeddings(randperm(numel(embeddings)));


%% visualization

figure(12);clf
set(gca, 'position', [0 0 1 1])
for ix = 1:numel(embeddings)
  img = imread(embeddings(ix).name);
  image(embeddings(ix).x, embeddings(ix).y, img)
  hold on
end

hold off
axis equal tight off


%% export figure

addpath ~/matlab_root
exportfigure(gcf, '~/embeddings.png', [5 5], 400)