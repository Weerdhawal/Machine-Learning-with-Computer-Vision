function dist = mvgd1(IMAGE,MEAN,SIGMA,IMAGE_NUM)

first_term=((1200/2)*log10((sum(sqrt(sum(SIGMA.^2))))));

 for iFile = 1:IMAGE_NUM-1;

     summation_term=(((transpose(transpose(IMAGE(:,iFile))-transpose(MEAN)))*(transpose(IMAGE(:,iFile))-transpose(MEAN)))/SIGMA);
     dist(iFile,1)=-(first_term)-((0.5)*(sum(summation_term(:))));
     disp(iFile);

 end
 
