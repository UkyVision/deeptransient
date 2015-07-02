addpath ~/matlab_root/
%% load images
files = rdir('/u/vul-d1/scratch/ryan/00007371/*/*.jpg');

% select images taken at 11:17 every morning
time_filter_ims = [];
for ix=1:size(files,1)
    if (strfind(files(ix).name, '_1117'))
        time_filter_ims = [time_filter_ims; ix];
    else
        continue
    end
end


%% compute greenness before filtering
% pre-allocate space for greenness index values
greenness_index = zeros(size(time_filter_ims,1), 1);

% loop over each of the images and compute greenness of an 
% extracted patch
for ix=1:size(time_filter_ims,1)
    % read the image
    im = imread(files(time_filter_ims(ix)).name);
    
    % compute greenness on a selected patch
    greenness_val = mean2(im(end-300:end-100,400:600,2)) / (mean2(im(end-300:end-100,400:600,1)) + mean2(im(end-300:end-100,400:600,2)) + mean2(im(end-300:end-100,400:600,3)));
    
    % add greenness value to the matrix of greenness indices
    greenness_index(ix) = greenness_val;
    
    % progress
    if mod(ix, 10) == 0
       fprintf('Processed %d of %d\n', ix, size(time_filter_ims,1))
    end
           
    % display the current image and the selected patch
    %figure(1)
    %imshow(im(end-300:end-100,400:600,:))
    %figure(2)
    %imshow(im)
end

% plot the greenness indices
figure(1);
scatter(linspace(1, size(greenness_index, 1), size(greenness_index, 1)),greenness_index, '.')
xlim([0, size(greenness_index,1)])
xlabel('Image Number (Time starting at 01-01-2012 11:17AM)')
ylabel('Greenness')

%% load transient attributes
data = textscan(fopen('/u/vul-d1/scratch/ryan/00007371/attributes.csv'), strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');


%% filter images
% filter out all of the images with an attribute value greater
% than a given threshold.  finds the indices of the images with
% an attribute value less than the given threshold.
keepers = [];
for ix=1:size(time_filter_ims,1)
   % check attribute value is less than selected threshold
   if data{25 + 1}(time_filter_ims(ix)) <= 0.3
      keepers = [keepers; ix];
   else
      continue
   end
end


%% plot greenness indices after filtering
figure(2);
scatter(keepers,greenness_index(keepers), '.')
xlim([0, size(greenness_index,1)])
ylim([0.3, 0.44])
xlabel('Image Number (Time starting at 01-01-2012 11:17AM)')
ylabel('Greenness')