addpath ~/matlab_root/
%% load images
% greenness_index = green / (red + green + blue)

files = rdir('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/00007371/*/*.jpg');

%% compute greenness before filtering
greenness_index = zeros(size(files,1), 1);
for ix=1:size(files,1)
    im = imread(files(ix).name);
   
    greenness = mean2(im(end-200:end,1:200,2)) / (mean2(im(end-200:end,1:200,1)) + mean2(im(end-200:end,1:200,2)) + mean2(im(end-200:end,1:200,3)));
    
    greenness_index(ix) = greenness;
    
    if mod(ix, 100) == 0
       fprintf('Processed %d of %d\n', ix, size(files,1))
    end
end

%% load transient attributes
data = textscan(fopen('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/00007371/attributes.csv'), strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');


%% filter images
to_clear = data{3 + 1} > 0.3;

for ind=1:size(data, 2)
   data{ind}(to_clear) = []; 
end


%% compute greenness index after filtering
greenness_index = zeros(size(data{1},1), 1);
for ix=1:size(files,1)
    im = imread(strcat('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/', data{1}{ix}));
   
    greenness = mean2(im(end-200:end,1:200,2)) / (mean2(im(end-200:end,1:200,1)) + mean2(im(end-200:end,1:200,2)) + mean2(im(end-200:end,1:200,3)));
    
    greenness_index(ix) = greenness;
    
    if mod(ix, 100) == 0
       fprintf('Processed %d of %d\n', ix, size(data{1},1))
    end
end