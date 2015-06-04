addpath ~/matlab_root/

% greenness_index = green / (red + green + blue)

files = rdir('/u/eag-d1/scratch/ryan/amos_labeling/AMOS_Data/00007371/*/*.jpg');

greenness_index = zeros(size(files,1), 1);
for ix=1:size(files,1)
    im = imread(files(ix).name);
   
    greenness = mean2(im(end-200:end,1:200,2)) / (mean2(im(end-200:end,1:200,1)) + mean2(im(end-200:end,1:200,2)) + mean2(im(end-200:end,1:200,3)));
    
    greenness_index(ix) = greenness;
    
    if mod(ix, 100) == 0
       fprintf('Processed %d of %d\n', ix, size(files,1))
    end
end
