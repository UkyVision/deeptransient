function unixHour = amosname2unixHour(amosname)

[~, name] = fileparts(amosname);

daysFromAC = datenum(name, 'yyyymmdd_HHMMSS');
daysToUnix = datenum('01-Jan-1970');

unixHour = 24 * (daysFromAC - daysToUnix);