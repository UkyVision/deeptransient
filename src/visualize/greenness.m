addpath ~/matlab_root/
%% load images
files = rdir('/u/vul-d1/scratch/ryan/00007371/*/*.jpg');


%% compute greenness before filtering
% using visible vegetation index http://phl.upr.edu/projects/visible-vegetation-index-vvi
% reference green = [30 50 0]
w = 1;
greenness_index = zeros(size(files,1), 1);
for ix=1:size(files,1)
    if (strfind(files(ix).name, '_1117'))
        im = imread(files(ix).name);
    else
        continue
    end
    
%     figure(1)
%     imshow(im(end-300:end-100,400:600,:))
%     figure(2)
%     imshow(im)
    
    %red_component = 1 - abs((mean2(im(end-200:end,1:200,1)) - 40)/(mean2(im(end-200:end,1:200,1)) + 40));
    %green_component = 1 - abs((mean2(im(end-200:end,1:200,2)) - 60)/(mean2(im(end-200:end,1:200,2)) + 60));
    %blue_component = 1 - abs((mean2(im(end-200:end,1:200,3)) - 10)/(mean2(im(end-200:end,1:200,3)) + 10));
    
    %vvi = (red_component * green_component * blue_component)^(1/w);
    
    greenness = mean2(im(end-300:end-100,400:600,2)) / (mean2(im(end-300:end-100,400:600,1)) + mean2(im(end-300:end-100,400:600,2)) + mean2(im(end-300:end-100,400:600,3)));
    
    %greenness_index(ix) = vvi;
    greenness_index(ix) = greenness;
    
    if mod(ix, 100) == 0
       fprintf('Processed %d of %d\n', ix, size(files,1))
    end
end

figure(1);
plot(greenness_index(find(greenness_index)))
xlim([0, size(greenness_index(find(greenness_index)),1)])
xlabel('Image Number (Time starting at 01-01-2012 11:17AM)')
ylabel('Greenness')

%% load transient attributes
data = textscan(fopen('/u/vul-d1/scratch/ryan/00007371/attributes.csv'), strcat('%s',repmat('%f', 1, 40)), 'delimiter', ',');


%% filter images
time_filter_ims = [];
for ix=1:size(data{1},1)
    if (strfind(char(data{1}(ix)), '_1117'))
        time_filter_ims = [time_filter_ims; ix];
    else
        continue
    end
end

keepers = [];
for ix=1:size(time_filter_ims,1)
   if data{25 + 1}(time_filter_ims(ix)) <= 0.3
      keepers = [keepers; ix];
   else
      continue
   end
end

% keepers = data{7 + 1} <= 0.7;

% keeper_inds = find(keepers);

% for ind=1:size(data, 2)
%    data{ind}(keepers) = []; 
% end


%% compute greenness index after filtering
greenness_index = zeros(size(time_filter_ims,1), 1);
for ix=1:size(time_filter_ims,1)
    im = imread(strcat('/u/vul-d1/scratch/ryan/', char(data{1}(time_filter_ims(ix)))));
    
%     figure(1)
%     imshow(im(end-300:end-100,400:600,:))
%     figure(2)
%     imshow(im)
    
    %red_component = 1 - abs((mean2(im(end-200:end,1:200,1)) - 40)/(mean2(im(end-200:end,1:200,1)) + 40));
    %green_component = 1 - abs((mean2(im(end-200:end,1:200,2)) - 60)/(mean2(im(end-200:end,1:200,2)) + 60));
    %blue_component = 1 - abs((mean2(im(end-200:end,1:200,3)) - 10)/(mean2(im(end-200:end,1:200,3)) + 10));
    
    %vvi = (red_component * green_component * blue_component)^(1/w);
    
    greenness = mean2(im(end-300:end-100,400:600,2)) / (mean2(im(end-300:end-100,400:600,1)) + mean2(im(end-300:end-100,400:600,2)) + mean2(im(end-300:end-100,400:600,3)));
    
    %greenness_index(ix) = vvi;
    greenness_index(ix) = greenness;
    
    if mod(ix, 100) == 0
       fprintf('Processed %d of %d\n', ix, size(files,1))
    end
end

figure(2);
plot(keepers,greenness_index(keepers))
xlim([0, size(greenness_index,1)])
ylim([0.3, 0.44])
xlabel('Image Number (Time starting at 01-01-2012 11:17AM)')
ylabel('Greenness')