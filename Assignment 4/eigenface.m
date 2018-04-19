%eigen face
%@Zhaozheng Yin, Spring 2017

clc; clear all; close all;

facedir_training = 'training\';
facedir_testing = 'testing\';

colorSpace = 'RGB'; %RGB, Gray, HSV, YCbCr, HSVYCbCr, Gradient
nSubject = 33; %There are 33 persons in the training dataset. There are only 27 in the testing dataset
K = 60; %the number of eigen vectors

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read in all the images
allFaceIms_training = [];
labels = []; %each row represents [folder, image in the folder] i.e., [person, which image of the person].
for iSubject = 1:nSubject
    [FaceIms,nrows,ncols,np] = getAllIms(sprintf('%s%02d\\',facedir_training,iSubject),colorSpace);
    if isempty(FaceIms), continue; end
    allFaceIms_training = [allFaceIms_training; FaceIms];    
    labels = [labels; [iSubject*ones(size(FaceIms,1),1) (1:size(FaceIms,1))']]; 
end
allFaceIms_training = allFaceIms_training'; %every column in allFaceIms_training is one face image

%your code will be below