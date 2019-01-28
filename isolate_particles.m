function isolate_particles

    close('all')

    folder = 'I:\SPring-8\2018 B\Images\Raw\2018.12.16_martin\Particles2\';

    %Flat field correction

    flat_str1 = [folder,'Flat'];       %For Particles A-C
    flat_str2 = [folder,'Flat2_'];       %For Particle D
    
    for i = 1:20
        if i == 1
            im_first = imread([flat_str1,'001.tif']);
            im1 = zeros([size(im_first),20],'uint16');
            im2 = zeros([size(im_first),20],'uint16');
        end
        
        if i < 10
            num = strcat('00',num2str(i));
        else
            num = strcat('0',num2str(i));
        end
        
        im1(:,:,i) = imread([flat_str1,num,'.tif']);
        im2(:,:,i) = imread([flat_str2,num,'.tif']);       
    end
    
    figure()
    flat1 = uint16(mean(im1,3));
    imshow(imadjust(flat1))
    flat2 = uint16(mean(im2,3));
    imshow(imadjust(flat2))
    
    mean_flat1 = mean(flat1(:));
    mean_flat2 = mean(flat2(:));
    
    beadsA1 = zeros([size(flat1),20]);
    beadsA2 = zeros([size(flat1),20]);
    beadsB = zeros([size(flat1),20],'uint16');
    beadsC = zeros([size(flat1),20],'uint16');
    beadsD = zeros([size(flat1),20],'uint16');
    
    for i = 1:20
        if i < 10
            num = strcat('00',num2str(i));
        else
            num = strcat('0',num2str(i));
        end
        
        imA1 = imread([folder,'Beads_A1_',num,'.tif']);
        imA2 = imread([folder,'Beads_A2_',num,'.tif']);
        imB = imread([folder,'Beads_B',num,'.tif']);
        imC = imread([folder,'Beads_C',num,'.tif']);
        imD = imread([folder,'Beads_D1_',num,'.tif']);
   
        beadsA1(:,:,i) = (double(imA1)./double(flat1))*mean_flat1;
        beadsA2(:,:,i) = (double(imA2)./double(flat1))*mean_flat1;
        beadsB(:,:,i) = (double(imB)./double(flat1))*mean_flat1;    
        beadsC(:,:,i) = (double(imC)./double(flat1))*mean_flat1;
        beadsD(:,:,i) = (double(imD)./double(flat2))*mean_flat2; 
    end
    
    beadsA1_im = uint16(mean(beadsA1,3));
    imshow(beadsA1_im,[]);
    
    %get_particles(beadsA1_im,folder,'BeadA1_eg_')
    
    beadsA2_im = uint16(mean(beadsA2,3));
    imshow(beadsA2_im,[]);
    
    %get_particles(beadsA2_im,folder,'BeadA2_eg_')
    %get_particles(beadsA2_im,folder,'BeadA2_eg_')
    
    beadsB_im = uint16(mean(beadsB,3));
    imshow(beadsB_im,[]);
    
    beadsC_im = uint16(mean(beadsC,3));
    imshow(beadsC_im,[]);
    
    beadsD_im = uint16(mean(beadsD,3));
    imshow(beadsD_im,[]);    
    
    get_particles(beadsB_im,folder,'BeadB_eg_')
    get_particles(beadsC_im,folder,'BeadC_eg_')
    get_particles(beadsD_im,folder,'BeadD_eg_')
    
end

function get_particles(im,folder,str)

    for i = 1:4
        h = imshow(im,[]);
       [J,rect] = imcrop(h);
       figure()
       imshow(J)
       [J] = imcrop(im,rect);
       imwrite(J,[folder,str,num2str(i),'.tif'])
    end

end