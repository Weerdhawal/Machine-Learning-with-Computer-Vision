clc;
clear all;
close all;

trainingImageDirectory = 'trainingImages\';
trainingImageFiles = dir(trainingImageDirectory);
for iFile = 3:size(trainingImageFiles,1)    
    origIm=imread([trainingImageDirectory trainingImageFiles(iFile).name]);      
    [nrows, ncols, ~] = size(origIm);
    bw = zeros(nrows, ncols);
    showIm = origIm;
    while true
        figure(1); clf; imshow(showIm,[]);
        tmp = roipoly;
        bw = bw | tmp;     
        showIm(bw) = 255;
        reply = input('Do you want to continue? y/n: [y]', 's');
        if isempty(reply)
            reply = 'y';
        end
        if strcmp(reply,'n')
            break;
        end
    end
    imwrite(bw,sprintf('%s_AccurateFacialRegion.png',trainingImageFiles(iFile).name));
end