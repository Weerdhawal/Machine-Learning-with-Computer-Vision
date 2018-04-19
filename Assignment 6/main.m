clc; clear all; close all;

facedir_training = 'trainingImages\';
facedir_testing = 'testingImages\';

colorSpace = 'RGB'; %RGB, Gray, HSV, YCbCr, HSVYCbCr, Gradient
nSubject = 2; %There are 33 persons in the training dataset. There are only 27 in the testing dataset


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in all the images
allFaceIms_training = [];
labels = []; %each row represents [folder, image in the folder] i.e., [person, which image of the person].
orig_im_all=[];
    temp=dir(facedir_training);
    [FaceIms,nrows,ncols,np,orig_im] = getAllIms(strcat(facedir_training,temp(3).name,'\'),colorSpace);
   %% if isempty(FaceIms), continue; end
    orig_im_all=[orig_im_all;orig_im];
    allFaceIms_training = [allFaceIms_training; FaceIms];    
    labels = [labels; [1*ones(size(FaceIms,1),1)]]; 
    [FaceIms,nrows,ncols,np,orig_im] = getAllIms(strcat(facedir_training,temp(4).name,'\'),colorSpace);
   %% if isempty(FaceIms), continue; end
    orig_im_all=[orig_im_all;orig_im];
    allFaceIms_training = [allFaceIms_training; FaceIms];    
    labels = [labels; [0*ones(size(FaceIms,1),1)]]; 
allFaceIms_training = allFaceIms_training'; %every column in allFaceIms_training is one face
%%
allFaceIms_testing = [];
labels_test = []; %each row represents [folder, image in the folder] i.e., [person, which image of the person].
orig_im_all_test=[];
    temp=dir(facedir_testing);
    [FaceIms,nrows,ncols,np,orig_im] = getAllIms(strcat(facedir_testing,temp(3).name,'\'),colorSpace);
   %% if isempty(FaceIms), continue; end
    allFaceIms_testing = [allFaceIms_testing; FaceIms];    
    orig_im_all_test=[orig_im_all_test;orig_im];
    labels_test = [labels_test; [1*ones(size(FaceIms,1),1)]]; 
    [FaceIms,nrows,ncols,np,orig_im] = getAllIms(strcat(facedir_testing,temp(4).name,'\'),colorSpace);
   %% if isempty(FaceIms), continue; end
    allFaceIms_testing = [allFaceIms_testing; FaceIms];    
    orig_im_all_test=[orig_im_all_test;orig_im];
    labels_test = [labels_test; [0*ones(size(FaceIms,1),1)]]; 
allFaceIms_testing = allFaceIms_testing'; %every column in allFaceIms_training is one face

%%

%% logistic reg
[predictions, phi] = fit_logr ([ones(1,433);allFaceIms_training], labels, 3.5, [ones(1,796);allFaceIms_testing],zeros(241,1));
missd_detection=abs(sum(labels_test(1:564)-predictions(1:564)')/564)

false_alarm=abs(sum((~labels_test(565:end))-(~predictions(565:end))')/(length(labels)-565))

out=randperm(200);
temppath=strcat(facedir_testing,temp(4).name,'\');
for_use=out(1:5);
for f=for_use
temp=dir(facedir_testing);


temp_ims=dir(temppath);
im = imread(strcat(temppath,temp_ims(f).name));
figure;imshow(im)
title(sprintf('%f',predictions(f)))
end

out=randperm(200);

temppath=strcat(facedir_testing,temp(3).name,'\');
for f=for_use
temp=dir(facedir_testing);

 
temp_ims=dir(temppath);
im = imread(strcat(temppath,temp_ims(f).name));
figure;imshow(im)
title(sprintf('%f',predictions(564+f)))
end
%% baysian
[predictions, phi] = fit_blogr ([ones(1,433);allFaceIms_training], labels, 3.5, [ones(1,796);allFaceIms_testing],zeros(241,1));
missd_detection=abs(sum(labels_test(1:564)-abs(predictions(1:564)'))/564)

false_alarm=abs(sum((labels_test(565:end))-(abs(predictions(565:end))'))/(length(labels)-565))

% out=randperm(200);
% temppath=strcat(facedir_testing,temp(4).name,'\')
% for_use=out(1:5);
% for f=for_use
% temp=dir(facedir_testing);
% 
% 
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(f)))
% end
% 
% out=randperm(200);
% 
% temppath=strcat(facedir_testing,temp(3).name,'\')
% for f=for_use
% temp=dir(facedir_testing);
% 
%  
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(564+f)))
% end
%% Dual Bayesian Logistic
[predictions, phi] = fit_dblogr ([ones(1,433);allFaceIms_training], labels, 3.5, [ones(1,796);allFaceIms_testing],zeros(433,1));

missd_detection=abs(sum(labels_test(1:564)-abs(predictions(1:564)'))/564)

false_alarm=abs(sum((labels_test(565:end))-(abs(predictions(565:end))'))/(length(labels)-565))

% out=randperm(200);
% temppath=strcat(facedir_testing,temp(4).name,'\')
% for_use=out(1:5);
% for f=for_use
% temp=dir(facedir_testing);
% 
% 
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(f)))
% end
% 
% out=randperm(200);
% 
% temppath=strcat(facedir_testing,temp(3).name,'\')
% for f=for_use
% temp=dir(facedir_testing);
% 
%  
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(564+f)))
% end

%% Dual Logistic

[predictions, phi] = fit_dlogr ([ones(1,433);allFaceIms_training], labels, 3.5, [ones(1,796);allFaceIms_testing],zeros(433,1));

missd_detection=abs(sum(labels_test(1:564)-abs(predictions(1:564)'))/564)

false_alarm=abs(sum((labels_test(565:end))-(abs(predictions(565:end))'))/(length(labels)-565))

% out=randperm(200);
% temppath=strcat(facedir_testing,temp(4).name,'\')
% for_use=out(1:5);
% for f=for_use
% temp=dir(facedir_testing);
% 
% 
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(f)))
% end
% 
% out=randperm(200);
% 
% temppath=strcat(facedir_testing,temp(3).name,'\')
% for f=for_use
% temp=dir(facedir_testing);
% 
%  
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(564+f)))
% end

%% Kernal Logistic

[predictions, phi] = fit_klogr ([ones(1,433);allFaceIms_training], labels, 3.5, [ones(1,796);allFaceIms_testing],zeros(433,1),@kernel_gauss,1);

missd_detection=abs(sum(labels_test(1:564)-abs(predictions(1:564)'))/564)

false_alarm=abs(sum((labels_test(565:end))-(abs(predictions(565:end))'))/(length(labels)-565))
% out=randperm(200);
% temppath=strcat(facedir_testing,temp(4).name,'\')
% for_use=out(1:5);
% for f=for_use
% temp=dir(facedir_testing);
% 
% 
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(f)))
% end
% 
% out=randperm(200);
% 
% temppath=strcat(facedir_testing,temp(3).name,'\')
% for f=for_use
% temp=dir(facedir_testing);
% 
%  
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(564+f)))
% end

%% Revelence Vector

[predictions, phi] = fit_rvc ([ones(1,433);allFaceIms_training], labels, 3.5, [ones(1,796);allFaceIms_testing],zeros(433,1),@kernel_gauss,1);

missd_detection=abs(sum(labels_test(1:564)-abs(predictions(1:564)'))/564)

false_alarm=abs(sum((labels_test(565:end))-(abs(predictions(565:end))'))/(length(labels)-565))

% out=randperm(200);
% temppath=strcat(facedir_testing,temp(4).name,'\')
% for_use=out(1:5);
% for f=for_use
% temp=dir(facedir_testing);
% 
% 
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(f)))
% end
% 
% out=randperm(200);
% 
% temppath=strcat(facedir_testing,temp(3).name,'\')
% for f=for_use
% temp=dir(facedir_testing);
% 
%  
% temp_ims=dir(temppath);
% im = imread(strcat(temppath,temp_ims(f).name));
% figure;imshow(im)
% title(sprintf('%f',predictions(564+f)))
% end


