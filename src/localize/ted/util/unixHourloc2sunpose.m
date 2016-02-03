function [daytime, zenith] = unixHourloc2sunpose(unixHour, lat, lon)

% Input: 
%  unixHour: hours from Jan 01 1970


% Output: 
%  daytime = 1 if zenith > 0 (sun above horizon line)

if isempty(unixHour)
  daytime = [];
  zenith = [];
  return
end

date_numbers = unixHour/24 + datenum('01-Jan-1970');
date_strs = arrayfun(@datestr, date_numbers, 'uniformoutput', false);

loc_struct = struct('latitude',lat, 'longitude',lon, 'altitude',0);
sun_locations = cellfun(@(x) sun_position(x, loc_struct), date_strs);

zenith = 90 - [sun_locations.zenith];
daytime = zenith > 0;
  