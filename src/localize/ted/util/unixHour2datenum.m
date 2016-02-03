function date_num = unixHour2datenum(unixHour)

date_num = unixHour/24 + datenum('01-Jan-1970');