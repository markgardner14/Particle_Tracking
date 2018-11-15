function[centers,radii] = smooth_circle_detector2(im,ax,rmin,rmax,sensitivity)

    

    r = rmin + (rmax - rmin)/2;

    sig1 = 1/(1+sqrt(2))*r;
    sig2 = sqrt(2)*r;   

    f1 = imgaussfilt(im,sig1);
    f2 = imgaussfilt(im,sig2);

    im2 = imadjust(f2-f1);

    imshow(im2,'parent',ax);

    [centers, radii] = imfindcircles(im2,[rmin rmax],'ObjectPolarity','bright','Sensitivity',sensitivity);

    viscircles(ax,centers, radii,'Color','r');

end
