function[centers,radii,detectedImg] = smooth_circle_detector2(im,ax,rmin,rmax,sensitivity)
%Algorithm for detecting particles using gaussian smoothing and a Circular
%Hough Transform
%Input
%im - image file
%ax - axis for plotting results
%rmin - minimum radius of particle
%rmax - maximum radius of particle
%sensitivity - scalar value between 0 and 1 that governs how sensitive the
%CHT circle detector is
%Outputs
%centers - vector containing x and y co-ordinates of center points of
%circles detected
%radii - radii of detected circles
    r = rmin + (rmax - rmin)/2;     %Calculate average particle size

    sig1 = 1/(1+sqrt(2))*r;         %Sigma values for gaussian smoothies. I can't remember where I got these forumlas from but it works so...
    sig2 = sqrt(2)*r;   

    f1 = imgaussfilt(im,sig1);
    f2 = imgaussfilt(im,sig2);

    im2 = imadjust(f2-f1);          %Take difference in smoothes images to get image with only particles (in theory)

    imshow(im2,'parent',ax);

    [centers, radii] = imfindcircles(im2,[rmin rmax],'ObjectPolarity','bright','Sensitivity',sensitivity);      %Find particles using CHT. 

    %viscircles(ax,centers, radii,'Color','r');
    
    detectedImg = insertShape(im2,'Circle',[centers radii],'Color','red','LineWidth',2);
    
    imshow(detectedImg,'parent',ax)
    
end
