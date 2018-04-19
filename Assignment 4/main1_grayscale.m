

clc;
clear all;
close all;
 


%mode = 'oneFeature';
mode = 'grayFeature';
Dataset_1 = [1:33]; %image names in dataset-1
%Just change _<no> and path no for changing data set for training and testing
 
no_of_indiv = 33;
trainingpath1 = 'training\';
test_ds_1 = Dataset_1; testpath = 'testing\';

 
cols = 40; %c
rows = 30; %r
NData = cols * rows; %c.r
DSize1 = 0;
for i = 1 : no_of_indiv
    path = sprintf('%s%02d\\', trainingpath1, i);
    files_in_dir = dir(path);
    display(sprintf('Files in dir %s\\%02d: %02d', trainingpath1, i, (size(files_in_dir, 1)-2)));
    DSize1 = DSize1 + size(files_in_dir, 1) - 2;
end
%DSize1 = dir();
%DSize2 = size(train_ds_2, 2);
TSize = 0;
for i = 1 : no_of_indiv
    path = sprintf('%s%02d//', testpath, i);
    files_in_dir = dir(path);
    display(sprintf('Files in dir %s//%02d: %02d', testpath, i, (size(files_in_dir, 1)-2)));
    TSize = TSize + size(files_in_dir, 1) - 2;
end
%TSize = size(test_ds_1, 2);

disp(sprintf('Training # images: %d', DSize1));
disp(sprintf('Testing # images: %d', TSize));

M =  DSize1; %No of total training images
M
noDataPts = 0;
if strcmpi(mode, 'grayFeature') == 1
    disp('Using gray Scale mode');
    noDataPts = NData;
    %sprintf('M:%d --- 3M:%d', M, noDataPts)
else
    noDataPts = NData;
end

IM = zeros(noDataPts, M); %Matrix of size c.r X M containing all Im's 
Mue = zeros(noDataPts, 1);
IMTest = zeros(noDataPts, TSize);

K = 100;%M;%Change K value accordingly 
K
%
%STEP-1%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Training of the image datasets
counter = 1; 
 %TRAINING OF DATASET-1
file_name = 'a';
for i = 1:no_of_indiv
    path = sprintf('%s%02d\\', trainingpath1, i);
    files_in_dir = dir(path);
    no_files_in_dir = size(files_in_dir, 1);
    
    for j = 3:no_files_in_dir
    
        file_name = sprintf('%s%02d\\%s',trainingpath1, i, (files_in_dir(j).name));
        imrgb = imread(file_name);
            
        img_grayscale = rgb2gray(imrgb);%img_hsv(:, :, 2);
        IM(:,counter) = [img_grayscale(:)]'; %Accessing i'th column and putting the i'th image grayscale values as a column
        %figure();
        %subplot(1,1,1); imshow(img_grayscale); title('Grayscale');
        counter = counter+1;
    end
end


%
%STEP-2%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Computation of Mue

for i = 1:M
 Mue = Mue + IM(:, i);
end

Mue = Mue./M;


%
%STEP-3%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Computation of IM - mue

for i = 1:size(IM,2)
    IM(:,i) = IM(:,i) - Mue;
end

%
%STEP-4%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Formation of 'A' Matrix

A = IM ;

%
%STEP-5%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Eigen Decomposition on A'.A
Square_A = A' * A;
[X, lambda] = eig(Square_A);

%P = Square_A * X;
%Q = X * lambda;
    
%%
%Selecting largest K values
X = X(:,size(X,2)-K+1:size(X,2));

%
%STEP-6%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Finding 'k' number of Y's by doing (i = 1 to K) Yi = A * Xi where Xi is
%i'th column in Vector Matrix X
Y = zeros(noDataPts, K);
for i = 1:K
Y(:,i) = A * X(:, i);
end

%
%STEP-7%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Forming Alpha Matrix of size 'M' Columns each haveing 'K' Rows
Alpha = zeros(K, M);
for i= 1:M
    for j=1:K
        Alpha(j,i) = [Y(:,j)]'*[IM(:,i)];
    end
end

%
%STEP-8%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TESTING

testCounter = 1;
 %Testing OF DATASET
for i = 1:no_of_indiv
    path = sprintf('%s%02d\\', testpath, i);
    files_in_dir = dir(path);
    %files_in_dir
    %sprintf('No of files in test dir:%d', size(files_in_dir,1))
    %sprintf('i:%d', i)
    
    no_files_in_dir = size(files_in_dir, 1);
    
    for j = 3:no_files_in_dir
    
        file_name = sprintf('%s%02d\\%s',testpath, i, (files_in_dir(j).name));
        %disp(file_name);
        imrgb = imread(file_name);    
        %img_hsv = rgb2hsv(imrgb);
        img_grayscale = rgb2gray(imrgb);;%img_hsv(:, :, 2);
        IMTest(:,testCounter) = [img_grayscale(:)]'; %Accessing i'th column and putting the i'th image grayscale values as a column
        testCounter = testCounter + 1;
    end
end

for i = 1:size(IMTest,2)
    IMTest(:,i) = IMTest(:,i) - Mue;
end

AlphaTest = zeros(K, TSize);
for i= 1:TSize
    for j=1:K
        AlphaTest(j,i) = ((Y(:,j))')*(IMTest(:,i));
    end
end



%Norm 1 and Norm 2
DistConfusion  = zeros(M,TSize);

for i = 1:TSize
    for j = 1:M   
      temp=  [(AlphaTest(:,i) - Alpha(:,j))];
        dist = 0;
        for k = 1:K;
            dist = dist + temp(k).^2; %Norm2
           % dist = dist+temp(k);  %Norm1
        end
        dist = sqrt(dist);
        DistConfusion(j,i) = dist;
    end
end

Result = zeros(TSize,1);

[minValueInColumn,atIndex] = min(DistConfusion);
Result = atIndex;

%for i = 1:TSize
%     []
%    Result(i) = min(DistConfusion(:,i));
%end
%disp('-----------')
%Result

accuracy = 0;
%display
for i = 1:TSize
   %fig = figure();
   [testFile, test_person] = getFileNameFromIndex('testing', i, no_of_indiv);
  % subplot(1,2,1); imshow(imread(testFile)); title('TestImage');
%    if size(train_ds_1, 2) < Result(i)
%        closestImageId = train_ds_2(1, Result(i) - size(train_ds_1, 2));
%        closestImagePath = trainingpath2;
%    else
%        closestImageId = train_ds_1(1, Result(i));
%        closestImagePath = trainingpath1;
%    end
   [matchedFilePath, result_person] = getFileNameFromIndex('training', round(Result(i)), no_of_indiv);
   %disp(matchedFilePath);
  % subplot(1,2,2); imshow(imread(matchedFilePath))     ; title('ClosestMatchingImage');
   
   if test_person == result_person
       accuracy = accuracy + 1;
   end
  % pause(1);
  % close(fig);
end

fprintf('end of the program: accuracy percentage:%f', (accuracy/TSize*100));
fprintf('No of similar images : %d',accuracy);




