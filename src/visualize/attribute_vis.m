attrs = csvread('data/9112_attributes.csv',0,1);
attr_names = textscan(fopen('/u/eag-d1/scratch/ryan/transient/annotations/attributes.txt'), '%s\n');
attr_names = attr_names{1};

figure(1);
subplot(3,1,1);
plot(attrs(:,2));
ylim([0,1]);
xlim([0,size(attrs,1)]);
ylabel(attr_names(2));
hold on;

subplot(3,1,2);
plot(attrs(:,3));
ylim([0,1]);
xlim([0,size(attrs,1)]);
ylabel(attr_names(3));

subplot(3,1,3);
plot(attrs(:,10));
ylim([0,1]);
xlim([0,size(attrs,1)]);
ylabel(attr_names(10));
