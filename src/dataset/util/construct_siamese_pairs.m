function siamese_pairs = construct_siamese_pairs(download_list, split_list, amosCam)

transientDir = '/u/eag-d1/data/transient/transient/imageAlignedLD/';
image_label_file = '/u/eag-d1/scratch/ted/webcamattri/transient/annotations.csv';
tab = readtable(image_label_file, 'delimiter', ',', 'readrownames', true, 'readvariablenames', false);

maxHourApart = .5;  % AMOS images with timestamp less than this treated as positive pair
maxNegativePairPerImage = 5; % top distant image in label space


%% find images with close time and close location (positive pairs)
positive_pairs = [];
for ix = 1:numel(download_list)
  
  % image names should be from split_list
  imgNames = intersect(download_list(ix).imgNames, split_list);
  [~, names] = cellfun(@fileparts, imgNames, 'UniformOutput', false);
  
  try
    totalHours = cellfun(@(x) datenum(x, 'yyyymmdd_HHMMSS')*24, names);
  catch
    continue
  end
  
  for camid = reshape(download_list(ix).closeCamIds, 1, [])
    idx = camid == [amosCam.camId];
    if any(idx)
      deltaHours = bsxfun(@(x, y) abs(x-y), totalHours(:), reshape(amosCam(idx).totalHours, 1, []));
      [I, J] = find(deltaHours < maxHourApart);
      transientImageNames = reshape(cellfun(@(x) [transientDir x], imgNames(I), 'uniformoutput', false), [], 1);
      amosImageNames = reshape(amosCam(idx).imgNames(J), [], 1);
      positive_pairs = [positive_pairs; transientImageNames amosImageNames];
    end
  end
  disp(ix)
end

% %
% % test code
% %
% figure(1324);clf
% for ix = randperm(size(positive_pairs,1))
%   positive_pairs{ix,:}
%   im1 = imread(positive_pairs{ix,1});
%   im2 = imread(positive_pairs{ix,2});
%   subplot(121)
%   image(im1)
%   subplot(122)
%   image(im2)
%   pause
% end
  


%% find negative pairs in AMOS dataset (randomly select images, avoid close webcams as well as possible)

% turn off negative_pairs
negative_pairs = [];

% interest_name = intersect(tab.Properties.RowNames, split_list);
% interest_images = cellfun(@(x) struct('name', [transientDir, x], 'camId', str2double(fileparts(x))), interest_name);
% 
% negative_pairs = [];
% for ix = 1:numel(interest_images)
%   
%   name = interest_images(ix).name;
%   camId = interest_images(ix).camId;
%   
%   % exclude close webcams from the negative image pool
%   camInfo = download_list(camId == [download_list.camId]);
%   if numel(camInfo) > 0
%     [~, distantCamIdIds] = setdiff([amosCam.camId], camInfo.closeCamIds);
%   else
%     distantCamIdIds = 1:numel(amosCam);
%   end
%   
%   
%   % randomly select images 
%   % (uniformly select webcams in exclusive pool, then uniformly select images from the selected webcams) 
%   
%   negcamids = distantCamIdIds(randperm(numel(distantCamIdIds), maxNegativePairPerImage));
%   imagePool = {amosCam(negcamids).imgNames};
%   
%   transientImageNames1 = repmat({name}, maxNegativePairPerImage, 1);
%   transientImageNames2 = reshape(cellfun(@(x) x(randi([1, numel(x)])), imagePool), [], 1);
%   
%   negative_pairs = [negative_pairs; transientImageNames1 transientImageNames2];
%   
% end

% %
% % test code
% %
% figure(1324);clf
% for ix = randperm(size(negative_pairs,1))
%   negative_pairs{ix,:}
%   im1 = imread(negative_pairs{ix,1});
%   im2 = imread(negative_pairs{ix,2});
%   subplot(121)
%   image(im1)
%   subplot(122)
%   image(im2)
%   pause
% end

%% concatenate positive and negative pairs
siamese_pairs = [
  positive_pairs repmat({1}, size(positive_pairs,1),1)
  negative_pairs repmat({0}, size(negative_pairs,1),1)
  ];
siamese_pairs = siamese_pairs(randperm(size(siamese_pairs,1)),:); % shuffling