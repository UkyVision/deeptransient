addpath ~/matlab_root/
%% load images
files = rdir('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/00007371/*/*.jpg');


%% compute greenness before filtering
% using visible vegetation index http://phl.upr.edu/projects/visible-vegetation-index-vvi
% reference green = [30 50 0]
w = 2;
greenness_index = zeros(size(files,1), 1);
for ix=1:size(files,1)
    im = imread(files(ix).name);
    
    red_component = 1 - (mean2(im(end-200:end,1:200,1)) - 40)/(mean2(im(end-200:end,1:200,1)) + 40);
    green_component = 1 - (mean2(im(end-200:end,1:200,2)) - 60)/(mean2(im(end-200:end,1:200,2)) + 60);
    blue_component = 1 - (mean2(im(end-200:end,1:200,3)) - 10)/(mean2(im(end-200:end,1:200,3)) + 10);
    
    vvi = (red_component * green_component * blue_component)^(1/w);
    
    greenness_index(ix) = vvi;
    
    if mod(ix, 100) == 0
       fprintf('Processed %d of %d\n', ix, size(files,1))
    end
end

%% load transient attributes
data = textscan(fopen('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/00007371/attributes.csv'), strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');


%% filter images
to_clear = data{25 + 1} > 0.3;

for ind=1:size(data, 2)
   data{ind}(to_clear) = []; 
end


%% compute greenness index after filtering
greenness_index = zeros(size(data{1},1), 1);
for ix=1:size(files,1)
    im = imread(strcat('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/', data{1}{ix}));
   
    red_component = 1 - (mean2(im(end-200:end,1:200,1)) - 40)/(mean2(im(end-200:end,1:200,1)) + 40);
    green_component = 1 - (mean2(im(end-200:end,1:200,2)) - 60)/(mean2(im(end-200:end,1:200,2)) + 60);
    blue_component = 1 - (mean2(im(end-200:end,1:200,3)) - 10)/(mean2(im(end-200:end,1:200,3)) + 10);
    
    vvi = (red_component * green_component * blue_component)^(1/w);
    
    greenness_index(ix) = vvi;
    
    if mod(ix, 100) == 0
       fprintf('Processed %d of %d\n', ix, size(data{1},1))
    end
end