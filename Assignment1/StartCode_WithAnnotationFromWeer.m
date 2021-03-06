%Use a Generative Model to detect facial regions in the classroom
%Note: the facial regions are lousily annotated. Better performance can be
%expected by accurate annotation and some basic image processing operations such as imerode, imfill, etc.

%@Dr. Zhaozheng Yin, Missouri S&T, Spring 2017

clc;
clear all;
close all;
warning('off', 'Images:initSize:adjustingMag');

%file directory
annotator = 'Weer';
trainingImageDirectory = 'trainingImages\';
testingImageDirectory = 'testingImages\';
annotatedTrainingImageDirectory = ['annotatedTrainingImages_' annotator '\'];
annotatedTestingImageDirectory = sprintf('annotatedTestingImages_%s\\',annotator);

%your codes to define parameters, e.g. # of bins for your%likelihood, etc.
nDim = 33;
%N_face =0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%training process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tt= cputime;
Pr_x_given_w_equalsTo_1 = zeros(nDim,nDim,nDim);
Pr_x_given_w_equalsTo_0 = zeros(nDim,nDim,nDim);
N_facialRegionPixels = 0;
trainingImageFiles = dir(trainingImageDirectory);
annotatedTrainingImageFiles = dir(annotatedTrainingImageDirectory);
for iFile = 3:size(trainingImageFiles,1)
    %load the image and facial image regions
    origIm=imread([trainingImageDirectory trainingImageFiles(iFile).name]);
    origIm = floor(origIm/8);
    bwMask = imread([annotatedTrainingImageDirectory annotatedTrainingImageFiles(iFile).name]);  

    %visualization and generate the mask indicating the facial regions
    [nrows,ncols,~]= size(origIm);
    showIm = origIm; showIm(bwMask) = 255;
    figure; imshow(showIm,[]);
    %bwMask = zeros(nrows,ncols);    
    %figure; imshow(origIm,[]); hold on;
    

    %your codes to compute prior
    N_facialRegionPixels = N_facialRegionPixels + sum(bwMask(:));

    %your codes to compute likelihood
    for irow = 1:nrows
        for icol = 1:ncols
            r = origIm(irow,icol,1)+1;
            g = origIm(irow,icol,2)+1;
            b = origIm(irow,icol,3)+1;
            if(bwMask(irow,icol)==1)
                Pr_x_given_w_equalsTo_1(r,g,b) = Pr_x_given_w_equalsTo_1(r,g,b) + 1;
            else
                Pr_x_given_w_equalsTo_0(r,g,b) = Pr_x_given_w_equalsTo_0(r,g,b) + 1;
            end
        end
    end
           
        
end
%your codes to convert your histograms into probability distributions:

Pr_w_equalsTo_1 = N_facialRegionPixels/((iFile-3+1)*ncols*nrows);
Pr_w_equalsTo_0 = 1 - Pr_w_equalsTo_1;

Pr_x_given_w_equalsTo_1 = Pr_x_given_w_equalsTo_1/sum(Pr_x_given_w_equalsTo_1(:));
Pr_x_given_w_equalsTo_0 = Pr_x_given_w_equalsTo_0/sum(Pr_x_given_w_equalsTo_0(:));



disp(['traning: ' num2str(cputime-tt)]);
save(sprintf('FacialRegionDetection_TrainedProbs_%s.mat',annotator),'Pr_x_given_w_equalsTo_1','Pr_x_given_w_equalsTo_0','Pr_w_equalsTo_1','Pr_w_equalsTo_0');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End of the training process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(sprintf('FacialRegionDetection_TrainedProbs_%s.mat',annotator),'Pr_x_given_w_equalsTo_1','Pr_x_given_w_equalsTo_0','Pr_w_equalsTo_1','Pr_w_equalsTo_0');
testingFiles = dir(testingImageDirectory);
annotatedTestingImageFiles = dir(annotatedTestingImageDirectory);
%testingRectFiles = dir(testingRectDirectory);
truePositives = 0;
falsePositives = 0;
falseNegtives = 0;

precision = zeros(12,1);
recall = zeros(12,1);
for iFile = 3:size(testingFiles,1)
    tt = cputime;
    
    %load the image and facial image regions, gtMask is the groundtruth
    origIm=imread([testingImageDirectory testingFiles(iFile).name]);
    origIm=floor(origIm/8);
    [nrows, ncols,~] = size(origIm);
    gtMask = imread([annotatedTestingImageDirectory annotatedTestingImageFiles(iFile).name]); 
    %gtMask = zeros(nrows,ncols);
    detectedFacialMask = zeros(nrows,ncols);
    TP = zeros(nrows,ncols);
    %for ii = 1:size(allrects,1)
        %gtMask(allrects(ii,2):allrects(ii,2)+allrects(ii,4),allrects(ii,1):allrects(ii,1)+allrects(ii,3))=1;                    
    %end
    %gtMask = gtMask(1:nrows,1:ncols);
    
    %your code to do the inference on the input image (origIm)
    for irow = 1:nrows
        for icol = 1:ncols
            r = origIm(irow,icol,1)+1;
            g = origIm(irow,icol,2)+1;
            b = origIm(irow,icol,3)+1;
            if(Pr_x_given_w_equalsTo_1(r,g,b)*Pr_w_equalsTo_1 > Pr_x_given_w_equalsTo_0(r,g,b)*Pr_w_equalsTo_0)
                detectedFacialMask(irow,icol) = 1;
            end
        end
    end
    
    %suppose your inference result is summarized into a bitmap
    %(detectedFacialMask),the following are some visualization codes
    showIm = zeros(nrows,ncols,3);
    showIm(:,:,1) = detectedFacialMask; showIm(:,:,2) = gtMask;
    figure; imshow(showIm,[]); title('red: detection, green: groundtruth');
%     figure; imshow(detectedFacialMask); title('detection');
%     figure; imshow(gtMask); title('ground truth');
    showIm = origIm; showIm(nrows*ncols+find(detectedFacialMask)) = 255;
    figure; imshow([origIm repmat(255*detectedFacialMask,[1 1 3]) showIm],[]);
    
    %your code to do compute the precision and recall
    TP = detectedFacialMask & gtMask;
    TP = sum(TP(:));
    FP = detectedFacialMask & ~gtMask;
    FP = sum(FP(:));
    FN = ~detectedFacialMask & gtMask;
    FN = sum(FN(:));
    
    precision(iFile-3+1) = TP/(TP+FP);
    recall(iFile-3+1) = TP/(TP+FN);
    disp([num2str(iFile-2) ' testing: ' num2str(cputime-tt)]);
end

%output your precision and recall
precision
recall