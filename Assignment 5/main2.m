dir_training = 'training/';
dir_testing = 'testing/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
files = dir([dir_training '*.jpg']);
X = []; y_train = [];
for ii = 1:size(files,1)
    filename = files(ii).name;
    y_train = [y_train; str2double(filename(1:4))];
    im = imread([dir_training filename]);
    im = im(:,:,1);
    im=imresize(im,0.5);
    X = [X im(:)];
end
X = double(X); %every column in X is one vectorized input image
X_train = [ones(1,size(X,2)); X];
%%
files = dir([dir_testing '*.jpg']);
X = []; y_test = [];
for ii = 1:size(files,1)
    filename = files(ii).name;
    y_test = [y_test; str2double(filename(1:4))];
    im = imread([dir_testing filename]);
    im = im(:,:,1);
    im=imresize(im,0.5);
    X = [X im(:)];
end
X = double(X); %every column in X is one vectorized input image
X_test = [ones(1,size(X,2)); X];


%% original
w_train=y_train;
w_test=y_test;

X_train_zc=X_train-repmat(mean(X_train,2),1,size(X_train,2));
X_train_mat_zc=PD_mat(X_train_zc*X_train_zc');
X_train_mat=PD_mat(X_train*X_train');
phi_hat_zc=(X_train_mat_zc)\(X_train_zc*w_train);
phi_hat=(X_train_mat)\(X_train*w_train);

w_train_hat_zc=X_train_zc'*phi_hat_zc;
w_train_hat=X_train'*phi_hat;
w_test_hat=X_test'*phi_hat;

w_train_hat_gt=w_train_hat./(pi*pi);
w_test_hat_gt=w_test_hat./(pi*pi);
w_train_gt=w_train/(pi*pi);
w_test_gt=w_test/(pi*pi);

train_error=norm(w_train_hat_gt-w_train_gt,2)
test_error=norm(w_test_hat_gt-w_test_gt,2)
deviation=abs((train_error-test_error)/size(X_test,2))

figure('Name','Original');
plot(w_test_hat_gt)
hold on
title(sprintf('Original : error = %s', test_error));
plot(w_test_gt)
legend('Inference','Ground Truth')

%% regularized
X_train_mat=PD_mat(X_train*X_train'+100*eye(length(X_train)));
phi_hat=(X_train_mat)\(X_train*w_train);

w_train_hat=X_train'*phi_hat;
w_test_hat=X_test'*phi_hat;

w_train_hat_gt=w_train_hat./(pi*pi);
w_test_hat_gt=w_test_hat./(pi*pi);
w_train_gt=w_train/(pi*pi);
w_test_gt=w_test/(pi*pi);

train_error=norm(w_train_hat_gt-w_train_gt,2)
test_error=norm(w_test_hat_gt-w_test_gt,2)
deviation=abs((train_error-test_error)/size(X_test,2))

figure('Name','Regularized');

plot(w_test_hat_gt)
hold on
title(sprintf('Regularized : error = %s', test_error));
plot(w_test_gt)
legend('Inference','Ground Truth')

%% Polynomial
lambda=100;
X_train_poly=[];
for i=1:size(X_train,2)
   X_train_poly=[X_train_poly;ones(length(X_train),1)';X_train(:,i)';X_train(:,i)'.^2]; 
end

w_train_poly=[];
w_test_poly=[];
for i=1:length(w_train)
   w_train_poly=[w_train;w_train;w_train];
   w_test_poly=[w_test;w_test;w_test];
end

phi_hat_poly=(X_train_poly'*X_train_poly+0.8*eye(length(X_train)));
phi_hat_poly=phi_hat_poly\(X_train_poly'*w_train_poly);

w_train_hat=X_train'*phi_hat_poly;
w_test_hat=X_test'*phi_hat_poly;

w_train_hat_gt=w_train_hat./(pi*pi);
w_test_hat_gt=w_test_hat./(pi*pi);
w_train_gt=w_train/(pi*pi);
w_test_gt=w_test/(pi*pi);

train_error=norm(w_train_hat_gt-w_train_gt,2)
test_error=norm(w_test_hat_gt-w_test_gt,2)
deviation=abs((train_error-test_error)/size(X_test,2))

figure('Name','Polynomial Regression');

plot(w_test_hat_gt)
hold on
title(sprintf('Polynomial Regression : error = %s', test_error));
plot(w_test_gt)
legend('Inference','Ground Truth')

%% Dual Non-linear Reg
i=find(var(X') > 0);
X=[ones(1,size(X,2)); X(i,:)];
lambda=100;

X_train_mat=PD_mat(X_train'*X_train*X_train'*X_train+lambda*eye(size(X_train,2)));
psi=(X_train_mat)\(X_train'*X_train*w_train);
psi_reg=X_train*psi;
w_train_hat=X_train'*psi_reg;
w_test_hat=X_test'*psi_reg;

w_train_hat_gt=w_train_hat./(pi*pi);
w_test_hat_gt=w_test_hat./(pi*pi);
w_train_gt=w_train/(pi*pi);
w_test_gt=w_test/(pi*pi);

train_error=norm(w_train_hat_gt-w_train_gt,2)
test_error=norm(w_test_hat_gt-w_test_gt,2)
deviation=abs((train_error-test_error)/size(X_test,2))

figure('Name','Duel linear');

plot(w_test_hat_gt)
hold on
title(sprintf('Duel Non linear : error = %s', test_error));
plot(w_test_gt)
legend('Inference','Ground Truth')
%%

