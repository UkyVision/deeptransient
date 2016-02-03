%[ims lats lons] = make_sun_images(date_nums, lats, lons, opt)
%
% Function: Generate images of amount of sunlight at each lat/lon
%    for a set of times and a fixed lat/lon grid.
%
% Input:
%   date_nums: an image is generated for each time specified
%       in this n x 1 vector of datenums
%   lats: vector of latitudes to sample
%   lons: vector of longitudes to sample
%
% See also SUN_POSITION.
function [ims, lats, lons] = make_sun_images(unixHours, lats, lons)

n_lat = numel(lats);
n_lon = numel(lons);

date_nums = unixHour2datenum(unixHours);
n = length(date_nums);
ims = zeros(n_lat, n_lon, n);

dates = datevec(date_nums);

time.UTC = 0;

for imx = 1:n
  for lat_x = 1:n_lat

    for lon_x = 1:n_lon

      location.longitude = lons(lon_x);
      location.latitude = lats(lat_x);
      location.altitude = 200; % arbitrary

      time.year = dates(imx, 1);
      time.month = dates(imx, 2);
      time.day = dates(imx, 3);
      time.hour = dates(imx, 4);
      time.min = dates(imx,5);
      time.sec = dates(imx,6);

      sun = sun_position(time, location);

      ims(lat_x,lon_x,imx) = sun.zenith;

    end
  end
end

ims = 1 - (max(min(ims, 100), 90) - 90)/10;