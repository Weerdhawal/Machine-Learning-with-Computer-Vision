disp('Which colorspace do you want?')
disp('1. RGB')
disp('2. HSV')
disp('3. YCbCr')
disp('4. HSVYCbCr')
disp('5. Gradient')
disp('6. R')
disp('7. G')
disp('8. B')
disp('9. Gray')
colors=input('Enter number : ')
switch(colors)
    case 1
       colorspace= 'RGB'
        reshape_factor=[40,30,3];
    case 2
       colorspace= 'HSV'
        reshape_factor=[40,30,3];
    case 3
       colorspace= 'YCbCr'
       reshape_factor=[40,30,3];
    case 4
       colorspace= 'HSVYCbCr'
       reshape_factor=[40,30,6];
    case 5
       colorspace= 'Gradient'
       reshape_factor=[40,30,2];
    case 6
       colorspace= 'R'
       reshape_factor=[40,30,1];
    case 7
       colorspace= 'G'
       reshape_factor=[40,30,1];
    case 8
       colorspace= 'B'
       reshape_factor=[40,30,1];
    case 9
       colorspace= 'Gray'
       reshape_factor=[40,30,1];
       
    otherwise
        reshape_factor=[40,30,3];
end

files=dir('face_resized');
allIms = [];
[allIms,nrows,ncols,np] = getAllIms('face_resized/',colorspace);
faces=allIms;
%%
%normalised_face=normalizeIm(all_im);
mean_face_row=mean(faces,1);
cov_face_row=var(faces);
    mean_face=reshape(mean_face_row,reshape_factor);
    cov_face=reshape(cov_face_row,reshape_factor);

%imshow(mean_face)
%total_cov=zeros(3600,3600);
% for i=1:size(all_im,2)
%     a=all_im(:,i)-mean_face_row;
%     temp=a*a';
%     total_cov=total_cov+temp;
% end
%mean_cov=total_cov/length(all_im);
%mean_sqrt_cov=(mean_cov);
%mean_d_cov=diag(mean_sqrt_cov);
%mean_d_cov=uint8(round(mean_d_cov));
%cov_face=reshape(mean_d_cov,[40,30,3]);
%figure;
%subplot(2,1,1);imshow(cov_face)
%subplot(2,1,2);imshow(mean_face)


%%
files=dir('background_resized');
allIms = [];
[allIms,nrows,ncols,np] = getAllIms('background_resized/',colorspace);
backgrounds=allIms;
%%
%normalised_face=normalizeIm(all_im);
mean_background_row=mean(backgrounds,1);
mean_background=reshape(mean_background_row,reshape_factor);

cov_background_row=var(backgrounds);
cov_background=reshape(cov_background_row,reshape_factor);
if (strcmp(colorspace,'HSVYCbCr'))
    
elseif (strcmp(colorspace,'Gradient'))

    
else
    
figure;
imagesc(normalizeIm(cov_background))
figure;
imagesc(normalizeIm(mean_background))
figure;
imagesc(normalizeIm(mean_face))
figure;
imagesc(normalizeIm(cov_face))
end


tot=0;
for i=1:size(faces,2)
    tot = tot + 0.5*log(cov_background_row(i))-0.5*log(cov_face_row(i));
end
c = tot;

ll = zeros(size(faces,1),1);
for i = 1:size(faces,1)
    tot=0;
    for j=1:size(faces,2)
        tot = tot + 0.5*(faces(i,j)-mean_face_row(j))^2/cov_face_row(j) - 0.5*(faces(i,j)-mean_background_row(j))^2/cov_background_row(j);
    end
    ll(i) = c - tot;
end

accuracy_faces= length(find(ll >0))/length(ll);


% 
% normalised_face=normalizeIm(all_im);
% mean_face_row=mean(normalised_face,2);
% mean_face=reshape(mean_face_row,[40,30,3]);
% %%imshow(mean_face)
% total_cov=zeros(3600,3600);
% for i=1:size(all_im,2)
%     a=all_im(:,i)-mean_face_row;
%     temp=a*a';
%     total_cov=total_cov+temp;
% end
% mean_cov=total_cov/length(all_im);
% mean_sqrt_cov=(mean_cov);
% mean_d_cov=diag(mean_sqrt_cov);
% mean_d_cov=uint8(round(mean_d_cov));
% cov_face=reshape(mean_d_cov,[40,30,3]);
% figure;
% subplot(2,1,1);imshow(cov_face)
% subplot(2,1,2);imshow(mean_face)
tot=0;
for i=1:size(backgrounds,2)
    tot = tot + 0.5*log(cov_background_row(i))-0.5*log(cov_face_row(i));
end
c = tot;

ll = zeros(size(backgrounds,1),1);
for i = 1:size(backgrounds,1)
    tot=0;
    for j=1:size(faces,2)
        tot = tot + 0.5*(backgrounds(i,j)-mean_face_row(j))^2/cov_face_row(j) - 0.5*(backgrounds(i,j)-mean_background_row(j))^2/cov_background_row(j);
    end
    ll(i) = c - tot;
end

accuracy_background= 1-length(find(ll >0))/length(ll);
%%
files=dir('testing/background_resized');
allIms = [];
[allIms,nrows,ncols,np] = getAllIms('testing/background_resized/',colorspace);
backgrounds_test=allIms;
tot=0;
for i=1:size(backgrounds_test,2)
    tot = tot + 0.5*log(cov_background_row(i))-0.5*log(cov_face_row(i));
end
c = tot;

ll = zeros(size(backgrounds_test,1),1);
for i = 1:size(backgrounds_test,1)
    tot=0;
    for j=1:size(faces,2)
        tot = tot + 0.5*(backgrounds_test(i,j)-mean_face_row(j))^2/cov_face_row(j) - 0.5*(backgrounds_test(i,j)-mean_background_row(j))^2/cov_background_row(j);
    end
    ll(i) = c - tot;
end

accuracy_background_test = 1-length(find(ll >0))/length(ll);

files=dir('testing/face_resized/');
allIms = [];
[allIms,nrows,ncols,np] = getAllIms('testing/face_resized/',colorspace);
faces_test=allIms;

tot=0;
for i=1:size(faces_test,2)
    tot = tot + 0.5*log(cov_background_row(i))-0.5*log(cov_face_row(i));
end
c = tot;

ll = zeros(size(faces_test,1),1);
for i = 1:size(faces_test,1)
    tot=0;
    for j=1:size(faces,2)
        tot = tot + 0.5*(faces_test(i,j)-mean_face_row(j))^2/cov_face_row(j) - 0.5*(faces_test(i,j)-mean_background_row(j))^2/cov_background_row(j);
    end
    ll(i) = c - tot;
end

accuracy_face_test = length(find(ll >0))/length(ll);
accuracy_background
accuracy_faces
accuracy_background_test
accuracy_face_test