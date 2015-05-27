%
% generate siamese pairs. 
% Positive pairs: [transient image, close AMOS image at same time]
% Negative pairs: [transient image, distant transient image in label space]
%
% Positive pairs does not necessary cover all the transient images,
% but we guarrentee every transient images has at least one negative pair
%

amosImageDir = '/u/eag-d1/scratch/ted/deeptransient/AMOS_close/';

addpath ~/matlab_root
addpath util

load webcam_list

locs = load('locations.txt');

transientNames = {...
  'dirty','daylight','night','sunrisesunset','dawndusk',...
  'sunny','clouds','fog','storm','snow',...
  'warm','cold','busy','beautiful','flowers',...
  'spring','summer','autumn','winter','glowing',...
  'colorful','dull','rugged','midday','dark',...
  'bright','dry','moist','windy','rain','ice',...
  'cluttered','soothing','stressful','exciting',...
  'sentimental','mysterious','boring','gloomy','lush'
  };

% interest_transients = {'sunny', 'clouds', 'fog', 'rain', 'snow'};
interest_transients = transientNames; % use all 40 attributes

%% load AMOS image info (time consumming)

directories = dir(amosImageDir);
amosCam = [];
count = 1;
for ix = 1:numel(directories)
  camIdstr = directories(ix).name;
  if directories(ix).isdir && isempty(strfind(camIdstr, '.'))
    imgs = rdir([amosImageDir camIdstr '/**/*.jpg']);
    amosCam(count).camId = str2double(camIdstr);
    amosCam(count).imgNames = {imgs.name};
    
    [~, names] = cellfun(@fileparts, {imgs.name}, 'UniformOutput', false);
    amosCam(count).totalHours = cellfun(@(x) datenum(x, 'yyyymmdd_HHMMSS')*24, names);
    count = count + 1;
    disp(count)
  end
end


%% construct siamese pairs

% read splits
training_split_txt = '/u/eag-d1/data/transient/transient/holdout_split/training.txt';
test_split_txt = '/u/eag-d1/data/transient/transient/holdout_split/test.txt';

training_split = table2cell(readtable(training_split_txt, 'readvariablenames', false));
test_split = table2cell(readtable(test_split_txt, 'readvariablenames', false));

disp('generating pairs for training.')
training_pairs = construct_siamese_pairs(download_list, training_split, ...
  amosCam);

% the test set should not contain duplicate left images
disp('generating pairs for testing.')
test_pairs = construct_siamese_pairs(download_list, test_split, ...
  amosCam);
[~, uniqIds] = unique(test_pairs(:,1));
test_pairs = test_pairs(uniqIds,:);
test_pairs = test_pairs(randperm(size(test_pairs,1)),:);  % shuffling


%% saving
save_siamese_pairs(training_pairs, 'siamese_pairs/train_pairs.txt')
save_siamese_pairs(test_pairs, 'siamese_pairs/val_pairs.txt')
