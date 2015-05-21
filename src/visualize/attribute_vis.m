attrs = csvread('data/9112_attributes.csv',0,1);
attr_names = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');
attr_names = attr_names{1};
im_names = textscan(fopen('data/9112_attributes.csv'), strcat('%s', repmat('%*f',1,40), '\n'), 'Delimiter', ',');
im_names = im_names{1};

startDate = datenum('11-01-2013');
endDate = datenum('11-30-2013');
xData = linspace(startDate,endDate,size(attrs,1));

figure(1);
subplot(3,1,1);
plot(xData, attrs(:,2));
ylim([0,1]);
xlim([xData(1),xData(end)]);
ylabel(attr_names(2));
set(gca, 'XTick', xData(85:85:end));
datetick('x', 1, 'keepticks', 'keeplimits');
hold on;

subplot(3,1,2);
plot(xData, attrs(:,3));
ylim([0,1]);
xlim([xData(1),xData(end)]);
ylabel(attr_names(3));
set(gca, 'XTick', xData(85:85:end));
datetick('x', 1, 'keepticks', 'keeplimits');

subplot(3,1,3);
plot(xData, attrs(:,10));
ylim([0,1]);
xlim([xData(1),xData(end)]);
ylabel(attr_names(10));
set(gca, 'XTick', xData(85:85:end));
datetick('x', 1, 'keepticks', 'keeplimits');
