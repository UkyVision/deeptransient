%
% are some attributes more important than others?
%

fid = fopen('/u/eag-d1/scratch/ryan/transient/annotations/annotations.tsv');
C = textscan(fid, ['%s ' repmat('%f,%d ',1,40)]);
fclose(fid);

names = C{1};
feats = cell2mat(C(2:2:end));
confidence = cell2mat(C(3:2:end));

labels = importdata('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt');
train_set = importdata('/u/eag-d1/scratch/ryan/transient/holdout_split/training.txt');
test_set = importdata('/u/eag-d1/scratch/ryan/transient/holdout_split/test.txt');

% train/test split
[~, iTrain] = intersect(names, train_set);
[~, iTest] = intersect(names, test_set);

train_names = names(iTrain);
train_feats = feats(iTrain, :);
train_confidence = confidence(iTrain, :);

test_names = names(iTest);
test_feats = feats(iTest, :);
test_confidence = confidence(iTest, :);


%% 

figure(1); clf;
imagesc(feats)

figure(2); clf;
subplot(121)
bar(mean(feats))
title('average')
subplot(122)
bar(var(feats))
title('variance')