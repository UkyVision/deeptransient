%
% generate plots for deep transient paper
%
addpath ~/matlab_root

latRange = [24, 50];
lonRange = [-126 -66];
usShape = shaperead('usastatelo', 'usegeocoords', true);
load coast

load sat_corr_result_neg % *_neg: correlation map with reverse satellite imagerey

% register each pixel in satellite map
map_sz = size(results(1).tranFeat.bestCorrMap); 
[satLonTable, satLatTable] = meshgrid(linspace(lonRange(1), lonRange(2), map_sz(2)),...
   linspace(latRange(2), latRange(1), map_sz(1)));

tranFeats = [results.tranFeat];
pcaFeats = [results.pcaFeat];

% get prediction (silly me forgot to storing them in the first place)
for ix = 1:numel(tranFeats)
  [~, id] = min(tranFeats(ix).bestCorrMap(:));
  tranFeats(ix).lat_pred = satLatTable(id); 
  tranFeats(ix).lon_pred = satLonTable(id);
end

%% webcam distribution
im_bmng = imread('bmng.jpg');
figure(121);clf
hold on;
set(gca, 'position', [0 0 1 1])
image(im_bmng, 'XData', [-180 180], 'YData', [90 -90]); hold on
plot([usShape.Lon], [usShape.Lat], 'white')
load coast
geoshow(flipud(lat),flipud(long),'DisplayType','polygon','FaceColor',[0 0 .3])
axis image
plot([results.lon], [results.lat], 'or','MarkerFaceColor','r','MarkerEdgeColor','none')
xlim(lonRange); ylim(latRange)
axis off xy
hold off;
exportfigure(gcf, '~/webcam_dist.pdf', [4, 2], 100)


%% good correlation map with given feature

% featureId = 6; % 7: clouds 6: sunny
% errs = cat(1, tranFeats.dists); errs = errs(:,featureId);
% goodInds = find(errs < 20)';

goodInds = [8 24 45 130 152];
for ix = goodInds
  
  lat_pred = tranFeats(ix).lat_pred;
  lon_pred = tranFeats(ix).lon_pred;
  
  figure(111);clf
  set(gca, 'position', [0 0 1 1])
  colormap(jet)
  imagesc(-flipud(tranFeats(ix).bestCorrMap), 'xdata', lonRange, 'ydata', latRange); hold on
  plot([usShape.Lon], [usShape.Lat], 'black')
  xlim(lonRange); ylim(latRange)
  plot(results(ix).lon, results(ix).lat, 'g.', 'markersize', 60); 
  plot(lon_pred, lat_pred, 'bs', 'markersize', 15, 'markerfacecolor', 'b');
  axis xy off
  fprintf('id: %d, error: %f km\n', ix, tranFeats(ix).minDist);  
  exportfigure(gcf, sprintf('~/geoloc_%d_%d.png', ix, results(ix).camId), [10, 5], 100)
%   pause
end


%% error report

% transient
featureId = 6; % 7: clouds 6: sunny
errs = cat(1, tranFeats.dists);
errDists = errs(:,featureId); 
errDists = errDists(errDists < 250);
fprintf('%f of test cases with errors within 250 km\n', nnz(errDists) / numel(tranFeats))

figure(121);clf
hist(errDists, linspace(0,250, 25));
xlim([0,250]); ylim([0,20])
xlabel('Error in Distance (km)', 'fontsize', 20); ylabel('Number of Cameras', 'fontsize', 20)
exportfigure(gcf, '~/tran_errors.png', [8, 5], 100)

% pca
component = 1;
errs = cat(1, pcaFeats.dists);
errDists = errs(:,component); 
errDists = errDists(errDists < 250);
fprintf('%f of test cases with errors within 250 km\n', nnz(errDists) / numel(pcaFeats))

figure(122);clf
hist(errDists, linspace(0,250, 25));
xlim([0,250]); ylim([0,20])
xlabel('Error in Distance (km)', 'fontsize', 20); ylabel('Number of Cameras', 'fontsize', 20)
exportfigure(gcf, '~/pca_errors.png', [8, 5], 100)


%% ground truth and prediction

errs = cat(1, tranFeats.dists);
links = nan(3*numel(tranFeats), 2);
links(1:3:end, 1) = [results.lon]; links(1:3:end, 2) = [results.lat];
links(2:3:end, 1) = [tranFeats.lon_pred]; links(2:3:end, 2) = [tranFeats.lat_pred];

figure(121);clf
set(gca, 'position', [0 0 1 1])
plot(long, lat, 'black')
hold on
scatter([results.lon], [results.lat], 50, 'go', 'filled')
scatter([tranFeats.lon_pred], [tranFeats.lat_pred], 50, 'ro', 'filled')
plot(links(:,1), links(:,2), 'b')
xlim(lonRange); ylim(latRange)
axis off