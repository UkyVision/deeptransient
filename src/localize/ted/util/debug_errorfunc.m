
K = 5;
rng(1)

%% fake model
model = rand(40+2*K, 1);


%% fake data
N = 10000;
data = rand(N,40);
gt = pred_location(model, data);
labels = gt + randn(N,1)*mean(gt)/50;

figure(1);clf
plot(gt,labels,'.')
axis equal
xlabel('before noise'); ylabel('after noise')
title('label')


%% train
err_local = @(X) error_function(X(:), data, labels);
options = struct();
options.Method = 'cg';
options.optTol = 1e-10;
options.progTol = 1e-10;

X_init = [ones(40,1)/40; rand(K,1); rand(K,1)];
[X,~,~,~] = minFunc(err_local, X_init, options);


%% visual

labels_before = pred_location(X_init, data); % before training
labels_after = pred_location(X, data); % after training

figure(12);clf
subplot(121)
plot(labels, labels_before, 'r.')
axis equal
title('before training')
xlabel('gt'); ylabel('preds')
subplot(122)
plot(labels, labels_after, 'g.')
xlabel('gt'); ylabel('preds')
title('after training')
axis equal