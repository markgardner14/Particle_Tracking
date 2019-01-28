function[im2] = insert_particle(im_background,im_particle,X,Y)
%Insert image im_particle into the image im_base at the position X,Y

%Should probably insert some error checking here

    p_size = size(im_particle);

    radii = round(mean(p_size)/2);
    
    r_side = radii^2;
    
    centers = [p_size(2)/2 p_size(1)/2];    
    
    W = 5;
    
    im2 = im_background;
    
    im2(Y:Y+p_size(1)-1,X:X+p_size(2)-1) = im_particle;    
    
    im_corner1 = im2(Y:Y+W,X:X+W);
    im_corner2 = im2(Y+p_size(1)-1-W:Y+p_size(1)-1,X:X+W);
    im_corner3 = im2(Y:Y+W,X+p_size(2)-1-W:X+p_size(2)-1);
    im_corner4 = im2(Y+p_size(1)-1-W:Y+p_size(1)-1,X+p_size(2)-1-W:X+p_size(2)-1);    
    
    corners = [im_corner1(:);im_corner2(:);im_corner3(:);im_corner4(:)];
    
    mean_corners = mean(corners);
    
    im_mean1 = im2(Y-W:Y,X-W:X);
    im_mean2 = im2(Y+p_size(1)-1:Y+p_size(1)-1+W,X-W:X);
    im_mean3 = im2(Y-W:Y,X+p_size(2)-1:X+p_size(2)-1+W);
    im_mean4 = im2(Y+p_size(1)-1:Y+p_size(1)-1+W,X+p_size(2)-1:X+p_size(2)-1+W);
    %im_mean4 = [];
    
    mean_outside = mean([im_mean1(:);im_mean2(:);im_mean3(:);im_mean4(:)]);
    
    %im_diff = mean_outside - mean_corners;    
    im_diff = 0;
    
    r2 = double(range([im_mean1(:);im_mean2(:);im_mean3(:);im_mean4(:)]));
    
    rand_noise = uint16(round(r2*rand(size(im_particle)) - r2/2));
    
    min_p = min(corners(:));
    max_p = max(corners(:));
    r_p = double(max_p - min_p);
    
    im2(Y:Y+p_size(1)-1,X:X+p_size(2)-1) = (r2/r_p).*(im2(Y:Y+p_size(1)-1,X:X+p_size(2)-1) - min_p) + min(min([im_mean1(:);im_mean2(:);im_mean3(:);im_mean4(:)]));
    
    im2(Y:Y+p_size(1)-1,X:X+p_size(2)-1) = im2(Y:Y+p_size(1)-1,X:X+p_size(2)-1) + im_diff + rand_noise;
    
    for i = X:X+p_size(2)
       for j = Y:Y+p_size(1)
           l_side = (i-(X+centers(1)-1))^2 + (j-(Y + centers(2)-1))^2;
           if l_side > r_side
              im2(j,i) = im_background(j,i); 
           end
       end
    end    
    
end