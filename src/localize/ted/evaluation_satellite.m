%
% validation of algorithm using satellite map (mesonet)
%

addpath ../util/ util ~/matlab_root
addpath ../dataset/util % sun_position.m
rng(1)

annotation_file = '/u/eag-d1/data/transient/transient/annotations/attributes.txt';
amos_info_file = 'amos_info.h5';

load mesonetSatMap

disp('reading amos info...')
imgNames = h5read(amos_info_file, '/names');
camIds = h5read(amos_info_file, '/camIds');
unixHours = h5read(amos_info_file, '/unixHours');
features = h5read(amos_info_file, '/features')';

locs = load('../dataset/locations.txt');
fid = fopen(annotation_file, 'r');
temp = textscan(fid, '%s'); attributes = temp{1};
fclose(fid);

%
% restore amos info to structure arrays
%
disp('storing amos info to structure...')
camIds_unq = unique(camIds);
webcams = [];
for ix = 1:numel(camIds_unq)
  s = struct();
  
  ids = camIds_unq(ix) == camIds;
  
  s.camId = camIds_unq(ix);
  s.imgNames = imgNames(ids);
  s.unixHours = unixHours(ids);
  s.features = features(ids,:);
  
  locid = find(locs(:,1)==s.camId);
  s.lat = locs(locid,2);
  s.lon = locs(locid,3);
  
  webcams = [webcams; s];
  
end



%% prepare satellite map

nMaps = numel(usSatMap);
mapSample = double(usSatMap(1).map);
map_sz = size(mapSample);

satMaps = reshape([usSatMap.map], [], nMaps);
satUnixHours = [usSatMap.unixHour]';

% register each pixel in satellite map
[satLonTable, satLatTable] = meshgrid(linspace(lonRange(1), lonRange(2), map_sz(2)),...
   linspace(latRange(2), latRange(1), map_sz(1)));

disp([num2cell(1:numel(attributes))', attributes])


%%

rng(2)
minSharedFrames = 500;

results = repmat(struct('camId', 0), numel(webcams), 1);

for ix = 1:numel(webcams)
  
  wc = webcams(ix);
  
  % TODO: filter out gth out of box
  if wc.lat < latRange(1) && wc.lat > latRange(2) ...
      && wc.lon < lonRange(1) && wc.lon > lonRange(2)
    disp('ground truth outside US')
    continue
  end
  
  
  % collecting data for correlation computation
  if true
    [Iids, Jids] = shared_frames(wc.unixHours, satUnixHours, .125);  % find share frames
    
    % filter daylight
    daytime = unixHourloc2sunpose(wc.unixHours(Iids), wc.lat, wc.lon);
    Iids = Iids(daytime); Jids = Jids(daytime);
    
    % at least minimum shared frames
    if numel(Iids) < minSharedFrames
      disp('no sufficient shared frames are found.')
      continue
    end
  end
  
  % signal preprocessing
  if true
    im = imread(wc.imgNames{Iids(1)});
    im_sz = size(im);
    rp = randperm(numel(im(:,:,1))); rp = rp(1:1000); % select 1000 pixels
    vals = zeros(numel(Iids), 1000);
    for iy = 1:numel(Iids)
      im = rgb2gray(imread(wc.imgNames{Iids(iy)}));
      if any(size(im) ~= im_sz(1:2))
        im = imresize(im, im_sz(1:2));
      end
      vals(iy,:) = im(rp);
    end
    [ceof, score] = pca(vals);
    pcaSignal = score(:,1:5);
    
    tranSignal = wc.features(Iids,:);
    
    satSignal = double(satMaps(:,Jids))';
  end
  
  % compute correlations
  if true
    corrTran = corr(tranSignal, satSignal);
    corrPCA = corr(pcaSignal, satSignal);
    
    corrTran = reshape(corrTran', prod(map_sz), []);
    corrPCA = reshape(corrPCA', prod(map_sz), []);
  end
  
  % transient correlation
  [~, ids] = min(corrTran);
  lat_preds = satLatTable(ids); lon_preds = satLonTable(ids);
  
  dists = distance(lat_preds, lon_preds, ones(size(lat_preds))*wc.lat, ones(size(lon_preds))*wc.lon, ...
    referenceSphere('earth', 'km'));
  [minDist, bestFeatId] = min(dists);
  bestCorrMap = reshape(corrTran(:,bestFeatId), map_sz);
  
  tranFeat = struct();
  tranFeat.dists = dists;
  tranFeat.minDist = minDist;
  tranFeat.bestFeatId = bestFeatId;
  tranFeat.bestFeatName = attributes{bestFeatId};
  tranFeat.bestCorrMap = bestCorrMap;
  results(ix).tranFeat = tranFeat;
  
  % pca correlations
  [~, ids] = min(corrPCA);
  lat_preds = satLatTable(ids); lon_preds = satLonTable(ids);
  
  dists = distance(lat_preds, lon_preds, ones(size(lat_preds))*wc.lat, ones(size(lon_preds))*wc.lon, ...
    referenceSphere('earth', 'km'));
  [minDist, bestFeatId] = min(dists);
  bestCorrMap = reshape(corrTran(:,bestFeatId), map_sz);
  
  pcaFeat = struct();
  pcaFeat.dists = dists;
  pcaFeat.minDist = minDist;
  pcaFeat.bestFeatId = bestFeatId;
  pcaFeat.bestFeatName = attributes{bestFeatId};
  pcaFeat.bestCorrMap = bestCorrMap;
  results(ix).pcaFeat = pcaFeat;
    
  % basic info
  results(ix).camId = wc.camId;
  results(ix).lat = wc.lat;
  results(ix).lon = wc.lon;
  results(ix).Iids = Iids;
  results(ix).Jids = Jids;
  
  fprintf('(%d / %d) webcam Id: %d,  min error (transient): %f km,  min error (pca): %f km\n', ...
    ix, numel(webcams), wc.camId, tranFeat.minDist, pcaFeat.minDist);
  
end

results = results([results.camId] ~= 0);


%% save results
save('sat_corr_result_neg.mat', 'results')