function track_testing_2017_3
%Testing linking algorithms for all 2017B data with 2 detectors. Can do
%stuff with moving frames

    close('all')

    figure()
    ax1 = gca;
    
    figure()
    fig2 = gcf;
    ax2 = gca;
    
    figure()
    ax3 = gca;  
    
    figure()
    ax4 = gca;       
    
%     figure()
%     ax4 = gca; 
%     
%     figure()
%     ax5 = gca;    
    
    base = 'I:\SPring-8/2017 B/Images/FD Corrected/';   
    
    %Location where the tracked images will be saved
    save_dest = 'I:\SPring-8/2017 B/Images/Processed/Auto_processed3/';
    
     %str1 = '2017_particle_detector_partA.xml';
     %str2 = '2017_particle_detector_partB.xml';
    
     %Detectors
     %str1 = '2017_new_detector_partA.xml';
     str1 = '2017new_negatives_partA.xml';
     %str2 = '2017_new_detector_partB.xml';
     str2 = '2017new_negatives_partB.xml';
    
%    
    run('exp_list/S8_17B_XU.m')

    %pixel_size = 50*7.2/1000/668; 

    %How to train the cascade classifiers
    
    %file2 = 'particle_recognition/Negative2/';
    
    %load('particle_recognition/Positive/particles_2017b','pos_2017')
    
%     for i = 1:numel(pos_2017)
%         data = pos_2017(i).objectBoundingBoxes;
%         data(data < 1) = 1;
%         pos_2017(i).objectBoundingBoxes = data;
%     end    
%     
%     pos_2017_2 = [];
% 
%     for i = 2:2:numel(pos_2017)
%         pos_2017_2(i/2).imageFilename = pos_2017(i).imageFilename;
%         pos_2017_2(i/2).objectBoundingBoxes = pos_2017(i).objectBoundingBoxes;
%     end

%     trainCascadeObjectDetector(str1,pos_2017,file2,'FalseAlarmRate'...
%         ,0.15,'NumCascadeStages',17,'FeatureType','LBP');
% 
%     trainCascadeObjectDetector(str2,pos_2017,file2,'FalseAlarmRate'...
%         ,0.15,'NumCascadeStages',17,'FeatureType','Haar');    
    
    %define maximum possible size of the images in which a particle could
    %be
    maxsize = [120 120];

    detector1 = vision.CascadeObjectDetector(str1,'MaxSize',maxsize);  
    detector2 = vision.CascadeObjectDetector(str2,'MaxSize',maxsize);
    
    %Read file information
    [num,txt] = xlsread('exp_list/S8_17B_XU.xlsx');
    
    %exclude files that are not in runlist
    num = num(expt.tracking.runlist,:);
    txt = txt(expt.tracking.runlist,:); 
    
    data = cell.empty(numel(num(:,1)),0);
    
    t_frames = cell.empty(numel(num(:,1)),0);
    
    str_save = [save_dest,'MCT calculation.mat'];
    
    i = 2;
    
    %Threshold for linking algorithm. Smaller values mean algorithm is more
    %conservative
    th = 75;
    %th = 50;
    th2 = 75;
    %th2 = 50;
    
    %Create .mat file for saving data to. If a .mat file exists it will not
    %delete the old one but will make a new one
    while exist(str_save,'file') > 1
        str_save = [save_dest,'MCT calculation',num2str(i),'.mat'];
        i = i + 1;
    end
    
    date = datetime('today');
    save(str_save,'data','date','t_frames')   
    
    iptsetpref('ImshowBorder','tight');

    %r = 17;
    for r = 1:numel(num(:,1))
        %r = 9;
        %r = 4
    %for r = (numel(num(:,1))-1):numel(num(:,1))
        %r = 2;
       %r = ceil(numel(num(:,1))*rand);

        file = strcat(base,[txt{r,1},'Low/',txt{r,2},'fad_']);

        s = txt{r,2};
        if exist(strcat(save_dest,s(9:end-1)),'dir') == 0
            try
                mkdir(strcat(save_dest,s(9:end-1)))
            catch
                disp('Folder cannot be created') 
            end
        end
% 
% 
        %Setup video file
         v = VideoWriter([save_dest,s(9:end-1),'/Tracking2.mp4']);
         v.FrameRate = 2;
         open(v)    

        t = [];

        pts_diff = [];
        pts_diff2 = [];
        
        f_num = num(r,2);
        %f_num = 100;

        pts_all = zeros(200,2,f_num);
        %pts_all2 = zeros(200,2,f_num);
        
        for n = 1:f_num
        %for n = 1:20
        %for n = 1:598
        %for n = 1:num(r,2)-2
        %for n = 187:num(r,2)-2

            if n < 10
                f = strcat('00',num2str(n));
            elseif n < 100
                f = strcat('0',num2str(n));
            else
                f = strcat('',num2str(n));
            end   

            [im, t_new] = ReadFileTime([file,num2str(f),'.jpg']);
            t = [t;t_new];               

            %Get particle locations from image
            [pts,~] = image_stuff(im,ax4,detector1,detector2);
            
            disp('finished plotting')     

            if n == 1        
            %if n == 187 
                pts_all(1:numel(pts(:,1)),:,n) = pts;
                %pts_all2(1:numel(pts(:,1)),:,n) = pts;
                imshow(im,'parent',ax2)
                hold(ax2,'on')      
                plot(ax2,pts_all(pts_all(:,1,n) > 0,1,n),pts_all(pts_all(:,2,n) > 0,2,n),'bo')
                %plot(ax2,pts_all(pts_all(:,1,n) > 0,1,n),pts_all(pts_all(:,2,n) > 0,2,n),'ko')
                hold(ax2,'off')
                
                pts_num = numel(pts(:,1));
                
            else
                
                if isempty(pts_diff)
                    pts_diff = zeros(size(pts_last(:,1))) ;%+ th2;
                end
                if isempty(pts_diff2)
                    pts_diff2 = zeros(numel(pts_last(:,1)),2);
                end                
                %pts_diff(pts_diff < th2) = th2;
                
                %Linking particles

%                 if n > 4
%                    disp('Many Particles') 
%                 end
                
                s1 = numel(pts_last(:,1));
                s2 = numel(pts(:,1));

                dist = zeros(s1+s2);

                pts_shift = zeros(size(pts_last));

                pts_shift = pts_shift + 0.5*pts_diff2;  %Variable that tries to account for frames moving
                
                %Create difference matrix from particles at time t and t-1
                %For more info see Jaqaman, K.,et al (2008). Robust single-particle tracking in live-cell time-lapse sequences. Nature Methods, 5(8), 695�702. https://doi.org/10.1038/nmeth.1237
                for i = 1:s1
                    %dist(i,1:s2) = sqrt(((pts_last(i,1)+0.5*pts_diff2(i,1))-pts(:,1)).^2 + ((pts_last(i,2)+0.5*pts_diff2(i,2))-pts(:,2)).^2);\
                    dist(i,1:s2) = sqrt(((pts_last(i,1)+pts_shift(i,1))-pts(:,1)).^2 + ((pts_last(i,2)+pts_shift(i,2))-pts(:,2)).^2);
%                     if n > 4
%                         pts_found = squeeze(pts_all(i,:,n-4:n-1));
%                         if isempty(find(pts_found==0, 1))
%                             SD = std(pts_found,[],2);
%                             SD = sqrt(SD(1)^2 + SD(2)^2);
%                             C = 3*SD;
%                             C = max([C 50]);
%                             %highs = find(dist(i,1:s2) > C);
%                             dist(i,dist(i,1:s2) > C) = Inf;
%                         end
%                     end
                end                    


                dist(s1+1:end,1:s2) = Inf;

                for i = 1:s2 
                    dist(s1+i,i) = th;
                end

                dist(1:s1,s2+1:end) = Inf;

                for i = 1:s1
                   dist(i,s2+i) = th; 
                end
%                 for i = 1:s1
%                    dist(i,s2+i) = pts_diff(i); 
%                 end    

                dist(s1+1:end,s2+1:end) = 1;
                
                [rowsol,~] = lapjv(dist);

                %[rowsol2,~] = munkres(dist);
                
%                 if ~isequal(rowsol(1:numel(pts_last(:,1))),rowsol2(1:numel(pts_last(:,1))))
%                    disp('Error') 
%                 end
                
                imshow(im,'parent',ax1)
                hold(ax1,'on')
                plot(ax1,pts_last(:,1),pts_last(:,2),'b+')
                plot(ax1,pts_last(:,1)+pts_shift(:,1),pts_last(:,2)+pts_shift(:,2),'yo')
                plot(ax1,pts(:,1),pts(:,2),'r+')
    %             plot(ax1,pts_last(goods,1),pts_last(goods,2),'bs')
    %             plot(ax1,pts(goods2,1),pts(goods2,2),'ro')            
                hold(ax1,'off')

                s1 = numel(pts_last(:,1));
                s2 = numel(pts(:,1));

                goods = find(pts_all(:,1,n-1));

                %Find an plot which particles were linked, which particles
                %were lost, and which new particles there are
                imshow(im,'parent',ax2)
                hold(ax2,'on')
                for i = 1:s1+s2
                    if i > s1
                        %Particle appeared
                        if rowsol(i) <= s2
                            try
                                plot(ax2,pts(rowsol(i),1),pts(rowsol(i),2),'gs')
                                %current = find(pts_all(:,1,n),1,'last');
                                [row,~] = find(squeeze(pts_all(:,1,:)));
                                pts_all(max(row)+1,:,n) = pts(rowsol(i),:);                                                     
                            catch
                               disp('Error') 
                            end
                        end
                    else
                        if rowsol(i) <= s2
                            %Particle linked
                            plot(ax2,[pts_last(i,1) pts(rowsol(i),1)],[pts_last(i,2) pts(rowsol(i),2)],'b-o')
                            pts_all(goods(i),:,n) = pts(rowsol(i),:);
                        else
                            %Particle disappeared
                            plot(ax2,pts_last(i,1),pts_last(i,2),'rx')
                            pts_all(goods(i),:,n) = [0 0];
                        end                
                    end
                end
                hold(ax2,'off')

                %Plot particle paths. If the path length was less than 3
                %frames long then it was considered a false positive and
                %not plotted
                %imhow(im2,'parent',ax3)
                hold(ax2,'on')
                for i = 1:numel(pts_all(:,1,1))
                    x_pts = zeros(1,n);
                    y_pts = zeros(1,n);
                    for j = 1:n
                        x_pts(j) = pts_all(i,1,j);
                        y_pts(j) = pts_all(i,2,j);
                    end
                    if x_pts(end) == 0
                        if n > 3 && numel(x_pts(x_pts > 0)) > 2
                            plot(ax2,x_pts(x_pts > 0),y_pts(y_pts > 0),'k')
                        elseif n <= 3
                            plot(ax2,x_pts(x_pts > 0),y_pts(y_pts > 0),'b')
                        else
                            %disp('Line ignored')
                        end
                    else
                        plot(ax2,x_pts(x_pts > 0),y_pts(y_pts > 0),'b')
                    end
                end
                hold(ax2,'off')            

                goods_new = find(pts_all(:,1,n));
                pts_diff = zeros(numel(goods_new),1);
                [~,ind_n1,ind_n2] = intersect(goods,goods_new);
                pts_diff(ind_n2) = sqrt((pts_all(goods_new(ind_n2),1,n)-pts_all(goods(ind_n1),1,n-1)).^2 + (pts_all(goods_new(ind_n2),2,n)-pts_all(goods(ind_n1),2,n-1)).^2);
                pts_diff = pts_diff*1.5;
                
                %Measure the difference in particle locations between
                %current and previous frame
                pts_diff2 = zeros(numel(goods_new),2);
                pts_diff2(ind_n2,:) = [(pts_all(goods_new(ind_n2),1,n)-pts_all(goods(ind_n1),1,n-1)) (pts_all(goods_new(ind_n2),2,n)-pts_all(goods(ind_n1),2,n-1))];
                
                %Median difference is calculated to account for the frame
                %moving or general drift of particles and such
                pts_diff2(ind_n2,:) = pts_diff2(ind_n2,:) - median(pts_diff2(ind_n2,:));
                
                %Gap closing
                
%                 pts_num = max([pts_num find(pts_all(:,1,n),1,'last')]);
%                
%                 for i = 1:pts_num
%                     f2 = find(squeeze(pts_all(i,1,:)));
%                     if ~isempty(f2)
%                         if f2(end) < n && f2(end)-f2(1) >= 3 && (n - f2(end)) <  3      %Only look to close gap with particles lost in previous 2 frames
%                            x = squeeze(pts_all(i,1,1:n));
%                            x(x == 0) = [];
%                            x = diff(x);
%                            y = squeeze(pts_all(i,2,1:n));
%                            y(y == 0) = [];
%                            y = diff(y);                         
%                            mag = sqrt(sum(x)^2+sum(y)^2);
%                            if numel(x) > 5 
%                                mag2 = sqrt(sum(x(end-5:end))^2+sum(y(end-5:end))^2);
%                            else
%                                mag2 = mag;
%                            end
% 
%                            SD = sqrt(std(x)^2+std((y))^2); 
%                            t_gap = n - f2(end);
%                            C = min([3*SD mag2]);
%                            if C > 250
%                                C = 250;
%                            elseif C < 30
%                                C = 30;
%                            end
%                            disp([mag2 C])
%                            if mag2 > 45
%                                x_new = pts_all(i,1,f2(end)) + t_gap*round(C*(sum(x)/mag));
%                                y_new = pts_all(i,2,f2(end)) + t_gap*round(C*(sum(y)/mag));
%                            else                           
%                                x_new = pts_all(i,1,f2(end));
%                                y_new = pts_all(i,2,f2(end));
%                            end
%                            f_current = find(pts_all(:,1,n));
%                            f_past = find(pts_all(:,1,n-1)==0);
%                            pts_check = intersect(f_current,f_past);
%                            differ = sqrt((x_new - pts_all(pts_check,1,n)).^2 + (y_new - pts_all(pts_check,2,n)).^2);
%                            viscircles(ax2,[x_new y_new],C);
%                            links = find(differ <= C);
%                            if ~isempty(links)
%                                disp('Linking Particle Found!')
%                                if numel(links) == 1
%                                    pts_all(i,:,n) = pts_all(pts_check(links),:,n);
%                                    pts_all(pts_check(links),:,n) = [0 0];
%                                    if pts_all(i,1,n-1) == 0
%                                        pts_all(i,1,n-1) = round((pts_all(i,1,n) + pts_all(i,1,n-2))/2);
%                                        pts_all(i,2,n-1) = round((pts_all(i,2,n) + pts_all(i,2,n-2))/2);
%                                    end
%                                else
%                                   disp('Fuck') 
%                                end                         
%                            end
%                         end
%                     end
%                 end
                
                
                
            end


            %Save image containing particle paths. Image is saved as both a
            %jpg file and a frame as part of the video.
            if n < 10
                f = strcat('00',num2str(n));
            elseif n < 100
                f = strcat('0',num2str(n));
            else
                f = strcat('',num2str(n));
            end
           saveas(fig2,[save_dest,s(9:end-1),'/frame',f,'_3.jpg'])
            writeVideo(v,getframe(fig2));


%             bbox = bbox2;
%             bbox2 = bbox3;

%             detectedImg = detectedImg2;
%             detectedImg2 = detectedImg3;
% 
%             imshow(detectedImg,'parent',ax3);
%             imshow(detectedImg2,'parent',ax4)

%             im = im2;
%             im2 = im3;
% 
%             %dist_12 = dist_23;
%             pts12 = pts23;
% 
%             cent_1 = cent_2;
%             cent_2 = cent_3;

            pts_last = pts_all(pts_all(:,1,n) > 0,:,n);

            imshow(im,'parent',ax3)
            hold(ax3,'on')
            plot(ax3,pts(:,1),pts(:,2),'+')
            hold(ax3,'off')


        end

        close(v)

        disp('Finished')
        
%         tmp_data = [];
%         %Frame particlenum time x y pixels mm dt rate angle
% 
%         %for i = 1:num(r,2)-2
%         for i = 1:f_num
%             data = pts_all(:,:,i);
% 
%             p = find(data(:,1));
%             L = numel(p);
% 
%             if i == 1
%                 dt = 0;
%                 dx = zeros(L,1);
%                 dy = zeros(L,1);
%             else
%                 dx = pts_all(p,1,i) - pts_all(p,1,i-1);
%                 dx(dx == pts_all(p,1,i)) = 0;
%                 dy = pts_all(p,2,i) - pts_all(p,2,i-1);
%                 dy(dy == pts_all(p,2,i)) = 0;
%                 dt = (t(i) - t(i-1))/60;
%             end
% 
%             pixels = sqrt(dx.^2 + dy.^2);
% 
%             mm = pixels * expt.tracking(1).pixelsize; 
%             if i == 1
%                 rate = zeros(L,1);
%                 angle = zeros(L,1);
%             else
%                 rate = mm./dt; %rate is in mm/min
% 
%                 angle = sign(dx) .* (90 - atand(-dy./abs(dx)));     % Angle measured from 12 o'clock position
%             end
% 
%             new_data = [zeros(L,1)+i p zeros(L,1)+t(i) data(p,:) pixels mm zeros(L,1)+dt rate angle];
% 
%             tmp_data = [tmp_data;new_data];
%         end

%          load(str_save,'data','date','t_frames')
%          data{r} = pts_all;
%          t_frames{r} = t;
%          save(str_save,'data','date','t_frames')
%          clear data date t_frames
    end
    disp('finished')
 
end

function[dist] = make_dist_mat(pts1,pts2)

    dist = zeros(numel(pts1(:,1)),numel(pts2(:,1)));

    for i = 1:numel(pts1(:,1))
        dist(i,:) = sqrt((pts1(i,1)-pts2(:,1)).^2 + (pts1(i,2)-pts2(:,2)).^2);
    end

end

function[dist] = make_linking_mat(pts1,pts2,differ,th)

    s1 = numel(pts1(:,1));
    s2 = numel(pts2(:,1));
        
    dist = zeros(s1+s2);
    
    for i = 1:s1
        dist(i,1:s2) = sqrt((pts1(i,1)-pts2(:,1)).^2 + (pts1(i,2)-pts2(:,2)).^2);
    end

    dist(s1+1:end,1:s2) = Inf;
    
    for i = 1:s2 
        dist(s1+i,i) = th;
    end
    
    dist(1:s1,s2+1:end) = Inf;
    
%     for i = 1:s1
%        dist(i,s2+i) = th; 
%     end
    for i = 1:s1
       dist(i,s2+i) = differ(i); 
    end    
    
    dist(s1+1:end,s2+1:end) = 1;
    
end

function[dist] = make_linking_mat2(pts1,pts2)
%For more info see Jaqaman, K.,et al (2008). Robust single-particle tracking in live-cell time-lapse sequences. Nature Methods, 5(8), 695�702. https://doi.org/10.1038/nmeth.1237

    s1 = numel(pts1(:,1));
    s2 = numel(pts2(:,1));
        
    dist = zeros(s1+s2);
    
    for i = 1:s1
        dist(i,1:s2) = sqrt((pts1(i,1)-pts2(:,1)).^2 + (pts1(i,2)-pts2(:,2)).^2);
    end

    dist(s1+1:end,1:s2) = Inf;
    
    for i = 1:s2 
        dist(s1+i,i) = 250;
    end
    
    dist(1:s1,s2+1:end) = Inf;
    
    for i = 1:s1
       dist(i,s2+i) = 250; 
    end
    
    dist(s1+1:end,s2+1:end) = 1;
    
end

function[pts] = find_common_pts(cent_1,cent_2)

    rowsol = lapjv(make_linking_mat2(cent_1,cent_2));
    
    goods = find(rowsol(1:numel(cent_1(:,1))) <= numel(cent_2(:,1)));
    
    pts = cent_2(rowsol(goods),:);

end

function[pts] = do_stuff(dist,cent_1,cent_2,im)

%     cent_1a = cent_1;
%     cent_2a = cent_2;
    
    pts = [];

    minibus12 = min(dist,[],2);
    
    a = find(minibus12 > 100);
    
    cent_1(a,:) = [];
    dist(a,:) = [];

    minibus12 = min(dist);
    
    a = find(minibus12 > 100);
    
    cent_2(a,:) = [];
    dist(:,a) = [];    
    
%     if numel(unique(ind1)) == numel(ind1)
%         disp('Yay!')
%     end

    if numel(cent_1(:,1)) > numel(cent_2(:,1))
        cent2a = cent_1;
        cent1a = cent_2;
        cent_1 = cent1a;
        cent_2 = cent2a;     
        dist = dist';
    end
    
    [rowsol,~] = lapjv(dist);

%     figure()
%     imshow(im)
%     hold on
%     for i = 1:numel(rowsol)
%        plot([cent_1(i,1) cent_2(rowsol(i),1)],[cent_1(i,2) cent_2(rowsol(i),2)],'-+') 
%     end
%     hold off
    
    try
        d2 = sqrt((cent_1(:,1) - cent_2(rowsol,1)).^2 + (cent_1(:,2) - cent_2(rowsol,2)).^2);
    catch
        disp('Error')
    end
    
    a = find(d2 > 100);
    
    pts = [cent_2(rowsol,1) cent_2(rowsol,2)];
    
    pts(a,:) = [];
   
%     imshow(im)
%     hold on
%     for i = 1:numel(pts(:,1))
%        plot(pts(:,1),pts(:,2),'+') 
%     end
%     hold off    
    
end

function[dist] = make_linking_mat3(pts1,pts2,W1,W2)
%Create distance matrix for linking the center points of two ROIs (pts1 and pts2)
%For more info see Jaqaman, K.,et al (2008). Robust single-particle tracking in live-cell time-lapse sequences. Nature Methods, 5(8), 695�702. https://doi.org/10.1038/nmeth.1237
    s1 = numel(pts1(:,1));
    s2 = numel(pts2(:,1));
        
    dist = zeros(s1+s2);
    
    for i = 1:s1
        dist(i,1:s2) = sqrt((pts1(i,1)-pts2(:,1)).^2 + (pts1(i,2)-pts2(:,2)).^2);
    end

    dist(s1+1:end,1:s2) = Inf;
    
    for i = 1:s2 
        dist(s1+i,i) = 0.25*W2(i);
    end
    
    dist(1:s1,s2+1:end) = Inf;
    
    for i = 1:s1
       dist(i,s2+i) = 0.25*W1(i); 
    end
    
    dist(s1+1:end,s2+1:end) = 1;


end

function[cent,detectedImg] = image_stuff(im,ax,detector1,detector2)
%Function for identifying particles that are detected by both types of
%detectors.
%im - image file
%ax - axis that displayes image file and results of particle detection
%detector1, detector2 - Different types of detectors


    bbox1 = step(detector1,im);
    labels = cell(numel(bbox1(:,1)),1);
    
    bbox2 = step(detector2,im);
    labels2 = cell(numel(bbox2(:,1)),1);
   
    labels(bbox1(:,3) >= 200,:) = {'Bad Circle1'};
    labels(bbox1(:,3) < 200,:) = {'Circle1'};

    labels2(bbox2(:,3) >= 200,:) = {'Bad Circle2'};
    labels2(bbox2(:,3) < 200,:) = {'Circle2'};    
    
    detectedImg = insertObjectAnnotation(im,'rectangle',bbox1,labels);
    
    detectedImg2 = insertObjectAnnotation(detectedImg,'rectangle',bbox2,labels2,'Color','red');
    
    %detectedImg = insertObjectAnnotation(im,'rectangle',bbox2,'badcircle');
    
    imshow(detectedImg2,'parent',ax);

    hold(ax,'on')
    
    %Exclude annotations that are too big
    bbox1(bbox1(:,3) >= 200,:) = [];
    bbox2(bbox2(:,3) >= 200,:) = [];
    
    pts1 = [bbox1(:,1) + round(0.5*bbox1(:,3)) bbox1(:,2) + round(0.5*bbox1(:,4)) ]; 
    pts2 = [bbox2(:,1) + round(0.5*bbox2(:,3)) bbox2(:,2) + round(0.5*bbox2(:,4)) ]; 
    
    %A particle is "found" if there is a sufficiently small difference
    %between the center of a ROI from both detectors. mat is matrix containing the distances between the ROI's from
    %both types of detectors, as well as including a cost for a ROI not
    %matching. Minimizing this matrix (using lapjv) will give any matching
    %ROI. 
    mat = make_linking_mat3(pts1,pts2,bbox1(:,3),bbox2(:,3));
    
    rowsol = lapjv(mat);
    
    goods = find(rowsol(1:numel(pts1(:,1))) <= numel(pts2(:,1)));
    
    cent = pts2(rowsol(goods),:);

    plot(ax,cent(:,1),cent(:,2),'+')
    
    hold(ax,'off')
    
end