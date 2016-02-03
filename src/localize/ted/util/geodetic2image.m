function [r, c, id] = geodetic2image(latlon, im_sz, latRange, lonRange)

c = round((latlon(1)-latRange(1)) / range(latRange) * im_sz(2));
r = round((latlon(2)-lonRange(1)) / range(lonRange) * im_sz(1));

id = sub2ind(im_sz, r, c);