addpath ~/matlab_root

attrs_file = 'data/4795_attributes.csv';

attrs = csvread(attrs_file,0,1);
attr_names = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');
attr_names = attr_names{1};
im_names = textscan(fopen(attrs_file), strcat('%s', repmat('%*f',1,40), '\n'), 'Delimiter', ',');
im_names = im_names{1};

for ix=1:size(attrs,1)
    [~,im_date] = fileparts(im_names{ix});
    im_dates{ix} = im_date;
end
xData = datenum(im_dates, 'yyyymmdd_HHMMSS');

inds = find(xData >= datenum('02-16-2013') & xData <= datenum('02-24-2013'));

figure(1);
subplot(3,1,1);
plot(xData(inds), attrs(inds,2));
ylim([0,1]);
xlim([xData(inds(1)),xData(inds(end))]);
ylabel(attr_names(2));
set(get(gca,'ylabel'), 'fontsize', 15);
set(gca, 'XTick', xData(inds(30:40:end)));
datetick('x', 'mmm-dd-yyyy HH:MM:SS', 'keepticks', 'keeplimits');
hold on;

subplot(3,1,2);
plot(xData(inds), attrs(inds,3));
ylim([0,1]);
xlim([xData(inds(1)),xData(inds(end))]);
ylabel(attr_names(3));
set(get(gca,'ylabel'), 'fontsize', 15);
set(gca, 'XTick', xData(inds(30:40:end)));
datetick('x', 'mmm-dd-yyyy HH:MM:SS', 'keepticks', 'keeplimits');

subplot(3,1,3);
plot(xData(inds), attrs(inds,10));
ylim([0,1]);
xlim([xData(inds(1)),xData(inds(end))]);
ylabel(attr_names(10));
set(get(gca,'ylabel'), 'fontsize', 15);
set(gca, 'XTick', xData(inds(30:40:end)));
datetick('x', 'mmm-dd-yyyy HH:MM:SS', 'keepticks', 'keeplimits');
