addpath ~/matlab_root

attrs_file = 'data/4795_new_attributes.csv';

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

figure(1);clf;
axes('Position', [.1 .38 .85 .27])
plot(xData(inds), attrs(inds,2));
ylim([0,1]);
xlim([xData(inds(1)),xData(inds(end))]);
ylabel(attr_names(2));
set(get(gca,'ylabel'), 'fontsize', 12);
set(gca, 'XTick', []);
set(gca, 'YTick', [0:0.5:1]);
set(gca, 'TickLength', [0 0])

axes('Position', [.1 .67 .85 .27])
plot(xData(inds), attrs(inds,3));
ylim([0,1]);
xlim([xData(inds(1)),xData(inds(end))]);
ylabel(attr_names(3));
set(get(gca,'ylabel'), 'fontsize', 12);
set(gca, 'XTick', []);
set(gca, 'YTick', [0:0.5:1]);
set(gca, 'TickLength', [0 0])

axes('Position', [.1 .09 .85 .27])
plot(xData(inds), attrs(inds,10));
ylim([0,1]);
xlim([xData(inds(1)),xData(inds(end))]);
ylabel(attr_names(10));
set(get(gca,'ylabel'), 'fontsize', 12);
set(gca, 'XTick', xData(inds(30:45:end)));
set(gca, 'YTick', [0:0.5:1]);
set(gca, 'TickLength', [0 0])
datetick('x', 'mmm dd yyyy', 'keepticks', 'keeplimits');
