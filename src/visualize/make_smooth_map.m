function [smooth_map, lon_centers, lat_centers, alpha] = make_smooth_map(value, map_locations)
extreme = quantile(map_locations, [0 1]);

lon_centers = linspace((extreme(3)),(extreme(4)),108);
lat_centers = linspace((extreme(1)),(extreme(2)),54);
map_size = [numel(lat_centers), numel(lon_centers)];
lon_bins = round(interp1(lon_centers, 1:numel(lon_centers), map_locations(:,2)));
lat_bins = round(interp1(lat_centers, 1:numel(lat_centers), map_locations(:,1)));
raw_map = accumarray([lat_bins lon_bins],value',map_size,@mean);

h = fspecial('Gaussian', [13 13], 3);
smooth_map = imfilter(raw_map,h);
alpha = double(smooth_map ~= 0);

% normalize so coasts don't look bad
has_data = double(logical(raw_map));
has_data = imfilter(has_data, h);
has_data(has_data == 0) = 2; % avoid NaNs
smooth_map = smooth_map ./ has_data;
