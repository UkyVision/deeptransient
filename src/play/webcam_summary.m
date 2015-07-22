%
% what can you dooooo
% scotts code for loading and filtering
%

addpath ~/matlab_root/

base_dir = '/u/vul-d1/scratch/ryan/00007371/';

data = readtable([base_dir 'attributes.csv'], 'ReadVariableNames', false);
data = sortrows(data, {'Var1'}, {'ascend'});
hays_data = readtable([base_dir 'hays_attributes.csv'], 'ReadVariableNames', false);
hays_data = sortrows(hays_data, {'Var1'}, {'ascend'});

labels = readtable('/u/vul-d1/scratch/ryan/attributes.txt', 'ReadVariableNames', false);

loc = [47.367922, 8.539977];
altitude = 408;
utc_offset = - timezone(loc(2));

[~, names] = cellfun(@(x) fileparts(x), table2cell(data(:, 1)), 'uni', 0);
date_numbers = cellfun(@(x) datenum(x, 'yyyymmdd_HHMMSS'), names);

features = cell2mat(table2cell(data(:, 2:end)));
hays_features = cell2mat(table2cell(hays_data(:, 2:end)));

local_date_numbers = date_numbers + (utc_offset/24);


%% plot everything

for iLabel = 1:40
    
    figure(2); clf;
    subplot(211)
    % + .005*randn(size(date_numbers))
    scatter(floor(date_numbers), mod(date_numbers,1), 20, features(:, iLabel), 'filled')
    set(gca, 'CLim', [0 1])
    subplot(212)
    scatter(floor(date_numbers), mod(date_numbers,1), 20, hays_features(:, iLabel), 'filled')   
    set(gca, 'CLim', [0 1])
    
    pause

end