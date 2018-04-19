function [im] = getIm(imPath,colorSpace,Gsigmax)

im = imread(imPath);
% im = imresize(im,.5);

if strcmp(colorSpace,'Gray')
    im= rgb2gray(im);        
elseif strcmp(colorSpace,'HSV')
    im = rgb2hsv(im);
elseif strcmp(colorSpace,'YCbCr')
    im = rgb2ycbcr(im);
elseif strcmp(colorSpace,'HSVYCbCr')
    [nrows, ncols, ~] = size(im);
    hsvim = rgb2hsv(im);
    ycbcrim = rgb2ycbcr(im);
    im = zeros(nrows, ncols, 6);
    im(:,:,1:3) = hsvim;
    im(:,:,4:6) = ycbcrim;
elseif strcmp(colorSpace,'Gradient')

%     %use the matlab gradient() function
%     im = double(im);   
%     [dx1 dy1]= gradient(im(:,:,1)); 
%     [dx2 dy2]= gradient(im(:,:,2));
%     [dx3 dy3]= gradient(im(:,:,3));
%     gradsig1 = dx1.^2+dy1.^2;
%     gradsig2 = dx2.^2+dy2.^2;
%     gradsig3 = dx3.^2+dy3.^2;
%     [nrows, ncols, ~] = size(im);
%     im(:,:,1) = gradsig1;
%     im(:,:,2) = gradsig2;
%     im(:,:,3) = gradsig3;

    %use the smoothed derivative
    im = double(rgb2gray(im));
    Gsigmay = Gsigmax';
    smoothedDerX = imfilter(im,Gsigmax,'same','conv');
    smoothedDerY = imfilter(im,Gsigmay,'same','conv');
    
%     [nrows,ncols]= size(im);    
%     im = zeros(nrows,ncols,3);
%     im(:,:,1) = smoothedDerX;
%     im(:,:,2) = smoothedDerY;
%     im(:,:,3) = smoothedDerX.^2+smoothedDerY.^2;            

%     %use only the magnitude
%     im = sqrt(smoothedDerX.^2+smoothedDerY.^2);  

%     %use only the orientation
%     im = atan2(smoothedDerY,smoothedDerX);    

    %use the magnitude and orientation
    [nrows,ncols]= size(im);    
    im = zeros(nrows,ncols,2);
    im(:,:,1) = sqrt(smoothedDerX.^2+smoothedDerY.^2); 
    im(:,:,2) = atan2(smoothedDerY,smoothedDerX);  
end
    



