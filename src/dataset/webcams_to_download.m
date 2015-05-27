%
% find webcams from AMOS close to the locations of cameras in transient
% dataset
%

addpath util

locs = load('locations.txt');
maxDist = 20;   % km
maxCloseCamsPerCam = 30;

image_dir = '/u/eag-d1/data/transient/transient/imageAlignedLD/';
image_label_file = '/u/eag-d1/scratch/ted/webcamattri/transient/annotations.csv';


%% find distance from transient cameras to AMOS cameras

% get all camera ids in transient dataset
tab = readtable(image_label_file, 'delimiter', ',', 'readrownames', true, 'readvariablenames', false);
camIds = unique(cellfun(@(x) str2double(fileparts(x)), tab.Properties.RowNames));

% get located camera ids
transient_locs = [];
for ic = 1:numel(camIds)
  id = find(locs(:,1) == camIds(ic));
  if ~isempty(id)
    transient_locs = [transient_locs; locs(id,:)];
  end
end

% select camera ids not from transient dataset
[exclusiveIds, idids] = setdiff(locs(:,1), transient_locs(:,1));

% compute the distance matrix then select the close ones
distMat = loclocdistmat(transient_locs(:,2:3), locs(idids,2:3));


%% select close cameras

[distMat_sorted, sortIds] = sort(distMat, 2);
[I, J] = find(distMat_sorted < maxDist);

% limit the number of close cameras
allowids = J <= maxCloseCamsPerCam;
I = I(allowids);
J = J(allowids);

camHasCloseCams = unique(I);
download_list = repmat(struct('camId', [], 'imgNames', [], 'closeCamIds', [], 'dist2closeCams', [], 'yyyymm', []), numel(camHasCloseCams), 1);

for ix = 1:numel(download_list)
  ids = camHasCloseCams(ix);
  download_list(ix).camId = transient_locs(ids,1);
  download_list(ix).closeCamIds = exclusiveIds(sortIds(ids, J(I == ids)));
  download_list(ix).dist2closeCams = distMat(ids, sortIds(ids, J(I == ids)));
end


%% go through transient dataset, decide which months should be downloaded

allImageNames = tab.Properties.RowNames;
allTransientCamIds = cellfun(@(x) str2double(fileparts(x)), allImageNames);

for ix = 1:numel(download_list)
  ids = find(download_list(ix).camId == allTransientCamIds);
  timestamps = {};
  for iy = 1:numel(ids)
    ts = amosname2timestamp(allImageNames{ids(iy)});
    timestamps = union(timestamps, ts);
  end
  download_list(ix).yyyymm = timestamps;
  download_list(ix).imgNames = allImageNames(ids);
end


%% generate a unique download list [AMOScamId, yyyy-mm]

id_yyyy_mm = {};
for ix = 1:numel(download_list)
  closecamids = download_list(ix).closeCamIds;
  for id = closecamids(:)'
    code = cellfun(@(x) [num2str(id) '/' x], download_list(ix).yyyymm, 'uniformoutput', false);
    id_yyyy_mm = union(id_yyyy_mm, code);
  end
end

AMOScamIds = cellfun(@(x) str2double(fileparts(x)), id_yyyy_mm);
yyyy_mm = cellfun(@(x) x(end-6:end), id_yyyy_mm, 'uniformOutput', false);

%% save results
save('webcam_list.mat', 'AMOScamIds', 'yyyy_mm', 'download_list')