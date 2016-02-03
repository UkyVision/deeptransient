%
% prepare satellite map data (visible satellite map)
%
addpath ~/matlab_root util

satDir = '/u/eag-d1/data/satellite/mesonet/2013/';
satmapList = glob([satDir '**/*.tif']);


%% crop a region and store

N = numel(satmapList);
sca = .2;

info = geotiffinfo(satmapList{1});
map_sz = round([info.Height, info.Width] * sca);
latRange = info.BoundingBox(:,2);
lonRange = info.BoundingBox(:,1);

usSatMap = repmat(struct('mapName',0, 'unixHour', nan, 'map', 0), N, 1);

for ix = 1:N
  satMap = satmapList{ix};
  try
    info = geotiffinfo(satMap);
    usmap = geotiffread(satMap);
    usmap = imresize(usmap, sca);
  catch
    continue
  end
  
  % skip bad images
  if nnz(usmap == 0) > 1000
    disp('bad images')
    continue
  end
  
  % get time stampe from file name
  parts = strsplit(info.Filename, '/');
  year = str2double(parts{end-3});
  month = str2double(parts{end-2});
  day = str2double(parts{end-1});
  hour = str2double(parts{end}(end-7:end-6));
  minute = str2double(parts{end}(end-5:end-4));
    
  % collect info
  usSatMap(ix).mapName = satmapList{ix};
  usSatMap(ix).unixHour = 24 * (datenum(year, month, day, hour, minute, 0) - datenum('01-Jan-1970'));
  usSatMap(ix).map = usmap;

  if mod(ix, 100) == 0
    fprintf('%d / %d\n', ix, N)
  end
  %   figure(34);clf
  %   colormap(gray)
  %   imagesc(usmap)
  %   pause
end

goodIds = ~isnan([usSatMap.unixHour]);
usSatMap = usSatMap(goodIds);

%% save map
save('mesonetSatMap.mat', 'usSatMap', 'latRange', 'lonRange')

% %% visualize
% corrMat = reshape(maps, [], size(maps,3));
% shareIds = randperm(size(corrMat,2),1000);
% c = corr(corrMat(1000,shareIds)', corrMat(:,shareIds)')';
% figure(1); clf
% imagesc(reshape(c, size(edgeMask)), [0.8,1])