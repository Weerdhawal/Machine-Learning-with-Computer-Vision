function [allIms,nrows,ncols,np] = getAllIms(directory,colorSpace)

if strcmp(colorSpace,'Gradient')
    sigma = 2; [x, y] = meshgrid(-3*sigma:1:3*sigma);    
    Gsigmax = -x.*exp(-0.5*(x.^2+y.^2)/(sigma^2));
else
    Gsigmax = [];
end

files = dir([directory '*.jpg']);
if isempty(files)
    allIms = [];
    nrows = [];
    ncols = [];
    np = [];
else
    allIms = [];
    for ii = 1:size(files,1)
        im = getIm([directory files(ii).name],colorSpace,Gsigmax);    
        allIms = [allIms; im(:)'];
    end
    if strcmp(colorSpace,'Gradient')    
        allIms = normalizeIm(allIms);
    else
        allIms = double(allIms)/double(max(allIms(:)));
    end
    [nrows, ncols, np] = size(im);    
end

