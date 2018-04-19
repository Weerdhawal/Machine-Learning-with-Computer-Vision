function [allIms,nrows,ncols,np,orig_ims] = getAllIms(directory,colorSpace)

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
    orig_ims=[];
    for ii = 1:size(files,1)
        [im,orig_im] = getIm([directory files(ii).name],colorSpace,Gsigmax);    
        allIms = [allIms; im(:)'];
        orig_ims=[orig_ims;orig_im];
    end
    if strcmp(colorSpace,'Gradient')    
        allIms = normalizeIm(allIms);
    else
        allIms = double(allIms)/double(max(allIms(:)));
    end
    [nrows, ncols, np] = size(im);    
end

