function remove_blurry_images

    close('all')

    base = 'I:/SPring-8/2018 A/Images/FD Corrected/';

    run('exp_list/S8_18A_XU.m')
    
    %Load info from excel spreadsheet
    disp('Loading file')
    [num,txt,~] = xlsread('exp_list/S8_18A_XU.xlsx');
    disp('File Loaded')

    %num = num(expt.tracking(2).runlist,:);
    %txt = txt(expt.tracking(2).runlist,:);     

    num = num(54,:);
    txt = txt(54,:);
    
    %folder = txt(41:end,1);
    %frame_nums = num(41:end,2);

    %name_start = txt(41:end,2);

    %folder = txt(53:end,1);
    folder = txt(:,1);
    frame_nums = num(:,2);
    %frame_nums = num(53:end,2);

    %name_start = txt(53:end,2);    
    name_start = txt(:,2);
    
    figure()
    ax1 = gca;
    
    figure()
    ax2 = gca;
    
    figure()
    ax3 = gca;

    figure()
    ax4 = gca;    

    figure()
    ax5 = gca;
    
    figure()
    ax6 = gca;    
    
    max_f = [];
    
    L = [0 -1 0;-1 4 -1;0 -1 0];
    %L = [0 -1 0;-1 4 -1;0 -1 0];
    
    W = 50;      %Width of window for normal dist calculation from center to outside bit of window
    
    %th = 35;
    
    z = -1.00;
    
    %sub_image_nums = 4;
    
    %im_width = 2048;
    
    for i = 1:numel(folder)
    %for i = 5:numel(folder)   
       if ~contains(string(name_start(i)),'R01')
            vars = zeros(frame_nums(i),1);
            %vars2 = zeros(frame_nums(i),4);
            %vars2 = zeros(frame_nums(i),sub_image_nums);
            %for j = 1:frame_nums(i)
            for j = 1:round(2*W)
%                     if j < 10
%                         f = strcat('000',num2str(j));
%                     elseif j < 100
%                         f = strcat('00',num2str(j));
%                     elseif j < 1000
%                         f = strcat('0',num2str(j));
%                     else
%                         f = strcat('',num2str(j));
%                     end
%                     file = strjoin([base,folder(i),'Low/',name_start(i),'fad_',f,'.jpg'],'');
%                     im = imread(file);
                    im = load_image(j,base,folder(i),name_start(i));
                    imshow(im,'parent',ax1)
                    
                    C = conv2(im,L);
                    vars(j) = var(C(:));

                    disp(['Variance = ',num2str(vars(j))])  
                    h = histfit(vars(1:round(2*W)));
                    %disp(h)

                    x_bar = mean(vars(1:round(2*W)));
                    s = std(vars(1:round(2*W)));

                    th = x_bar + z*s;   
                    
                    
%                     ind = sqrt(sub_image_nums);
%                     for k = 1:ind
%                         something1 = round((k-1)*2048/ind)+1:round(k*2048/ind);
%                         for m = 1:ind
%                             something2 = round((m-1)*2048/ind)+1:round(m*2048/ind);
%                             im_mini = im(something1,something2);
%                             imshow(im_mini,'parent',ax2)
%                             vars2(j,ind*(k-1)+m) = get_var(im_mini,L);
%                         end
%                     end
                    
%                     im11 = im(1:1024,1:1024);
%                     imshow(im11,'parent',ax2)
%                     vars2(j,1) = get_var(im11,L);
%                     im12 = im(1:1024,1024:end);
%                     imshow(im12,'parent',ax3)
%                     vars2(j,2) = get_var(im12,L);
%                     im21 = im(1024:end,1:1024);
%                     imshow(im21,'parent',ax4)
%                     vars2(j,3) = get_var(im21,L);
%                     im22 = im(1024:end,1024:end);
%                     imshow(im22,'parent',ax5)
%                     vars2(j,4) = get_var(im22,L);
                   
%                     v2 = vars2(1:round(2*W),:);
%                     
% %                     x_bar2 = mean(v2(:));
% %                     s2 = std(v2(:));
% 
%                     x_bar2 = mean(v2);
%                     s2 = std(v2);
% 
%                     th2 = x_bar2 + z*s2;
%                     for k = 1:sub_image_nums
%                         h = histfit(v2(:,k));
%                     end
                    
                    
            end
            
            h = histfit(vars(1:round(2*W)));
            %disp(h)

            x_bar = mean(vars(1:round(2*W)));
            s = std(vars(1:round(2*W)));

            th = x_bar + z*s;               

%             x_bar2 = mean(v2);
%             s2 = std(v2);
% 
%             th2 = x_bar2 + z*s2;
%             for k = 1:sub_image_nums
%                 h = histfit(v2(:,k));
%             end            
            
            
            for j = 1:frame_nums(i)
                
%                 if j < 10
%                     f = strcat('000',num2str(j));
%                 elseif j < 100
%                     f = strcat('00',num2str(j));
%                 elseif j < 1000
%                     f = strcat('0',num2str(j));
%                 else
%                     f = strcat('',num2str(j));
%                 end
%                 file = strjoin([base,folder(i),'Low/',name_start(i),'fad_',f,'.jpg'],'');
%                 im = imread(file);
                im = load_image(j,base,folder(i),name_start(i));
                imshow(im,'parent',ax1)                                
                %C = conv2(im,L);
                %V = var(C(:));

                disp(['Variance = ',num2str(vars(j))])                  
                if j <= W  || j > frame_nums(i)-W
%                     if V <= th
%                         isblurred = true;
%                     else
%                         isblurred = false;
%                     end

                else
                    im = load_image(j+W,base,folder(i),name_start(i));
                    C = conv2(im,L);
                    vars(j+W) = var(C(:)); 
                    
                    h = histfit(vars(j-W+1:j+W));
                    %disp(h)

                    x_bar = mean(vars(j-W+1:j+W));
                    s = std(vars(j-W+1:j+W));

                    th = x_bar +z*s;                      

                    
%                     im11 = im(1:1024,1:1024);
%                     imshow(im11,'parent',ax2)
%                     vars2(j+W,1) = get_var(im11,L);
%                     im12 = im(1:1024,1024:end);
%                     imshow(im12,'parent',ax3)
%                     vars2(j+W,2) = get_var(im12,L);
%                     im21 = im(1024:end,1:1024);
%                     imshow(im21,'parent',ax4)
%                     vars2(j+W,3) = get_var(im21,L);
%                     im22 = im(1024:end,1024:end);
%                     imshow(im22,'parent',ax5)
%                     vars2(j+W,4) = get_var(im22,L);
 
%                     ind = sqrt(sub_image_nums);
%                     for k = 1:ind
%                         something1 = round((k-1)*2048/ind)+1:round(k*2048/ind);
%                         for m = 1:ind
%                             something2 = round((m-1)*2048/ind)+1:round(m*2048/ind);
%                             im_mini = im(something1,something2);
%                             imshow(im_mini,'parent',ax2)
%                             vars2(j+W,ind*(k-1)+m) = get_var(im_mini,L);
%                         end
%                     end
% 
%                     v2 = vars2((j-W+1:j+W),:);
% 
%                     for k = 1:sub_image_nums
%                         h = histfit(v2(:,k));
%                     end     
%                     
% %                     x_bar2 = mean(v2(:));
% %                     s2 = std(v2(:));
% 
%                     x_bar2 = mean(v2);
%                     s2 = std(v2);
% 
%                     th2 = x_bar2 + z*s2;
%                     for k = 1:sub_image_nums
%                         h = histfit(v2(:,k));
%                     end
                    
                     
                end
                  
                
                if vars(j) <= th
                    disp('Blurry image. Booooo!')
                else
                    disp('Non blurry image!')
                end
                
%                 disp(vars2(j,:))
%                 disp(vars2(j,:) > th2)
%                 
%                 if sum(vars2(j,:) > th2) < 3
%                     disp('Blurry image. Booooo!')
%                 else
%                     disp('Non blurry image!')
%                 end
                
                disp('Done!')
            end
                
                
                
                
%                 if j <= 100
%                    
%                     if j < 10
%                         f = strcat('000',num2str(j));
%                     elseif j < 100
%                         f = strcat('00',num2str(j));
%                     elseif j < 1000
%                         f = strcat('0',num2str(j));
%                     else
%                         f = strcat('',num2str(j));
%                     end
%                     file = strjoin([base,folder(i),'Low/',name_start(i),'fad_',f,'.jpg'],'');
%                     im = imread(file);
%                     imshow(im,'parent',ax1)
% 
%                     C = conv2(im,L);
%                     vars(j) = var(C(:));
% 
%                     disp(['Variance = ',num2str(vars(j))])
%                     if j == 100
%                         h = histfit(vars(1:100));
%                         %disp(h)
% 
%                         x_bar = mean(vars(1:100));
%                         s = std(vars(1:100));
% 
%                         th = x_bar - 1.55*s;   
%                         for k = 1:100
%                             if k < 10
%                                 f = strcat('000',num2str(k));
%                             elseif k < 100
%                                 f = strcat('00',num2str(k));
%                             elseif k < 1000
%                                 f = strcat('0',num2str(k));
%                             else
%                                 f = strcat('',num2str(k));
%                             end
%                             file = strjoin([base,folder(i),'Low/',name_start(i),'fad_',f,'.jpg'],'');
%                             im = imread(file);
%                             imshow(im,'parent',ax1)   
% 
%                             C = conv2(im,L);
%                             vars(j) = var(C(:));
% 
%                             disp(['Variance = ',num2str(vars(j))])                                       
% 
%                             if vars(j) < th
%                                 disp('Blurry image. Booooo!')
%                             else
%                                 disp('Non blurry image!')
%                             end                              
%                             disp('DOone')
%                         end
%                     end
%                 elseif j > 100
%                     
%                 end
% %                 if V < th
% %                     disp('Blurry image. Booooo!')
% %                 else
% %                     disp('Non blurry image!')
% %                 end
% %                 im2 = abs(fftshift(fft(im)));
% %                 %imagesc(real(abs(im2)),'parent',ax2)
% %                 %hist(abs(real(im2)))
% %                 f1=20*log10(0.001+im2);
% %                 h1 = histogram(ax2,f1(:),100);
% %                 %h1 = histfit(f1(:),100); 
% %                 bins = h1.BinEdges(h1.BinEdges > 38);
% %                 vals = h1.Values(h1.BinEdges(1:end-1) > 38);
% %                 plot(ax4,bins(1:end-1),vals,'-*')
% %                 im3 = abs(fftshift(fft(abs(imgaussfilt(im,5)))));
% %                 f2=20*log10(0.001+im3);
% %                 h2 = histogram(ax3,f2(:),100);
% %                 bins2 = h2.BinEdges(h2.BinEdges > 35);
% %                 vals2 = h2.Values(h2.BinEdges(1:end-1) > 35);
% % 
% %                 maxes = find(h2.Values(2:end-1) >= h2.Values(1:end-2) & h2.Values(2:end-1) > h2.Values(3:end))+1;
% %                 
% %                 
% %                 [maximus1,ind1] = max(h2.Values(maxes));
% %                 bin1 = h2.BinEdges(maxes(ind1));
% %                 maxes(h2.BinEdges(maxes) < 35 | h2.BinEdges(maxes) > 80) = [];
% %                 
% %                 
% %                 plot(ax5,h2.BinEdges(1:end-1),h2.Values,'-*',h2.BinEdges(maxes),h2.Values(maxes),'o')   
% %                 xlim(ax5,[0,80])
% %                 [maximus2,ind2] = max(h2.Values(maxes));
% %                 disp(num2str(h2.BinEdges(maxes(ind2))))
% %                 disp(maximus2)
% %                 max_f = [max_f;h2.BinEdges(maxes(ind2))];  
% %                 [fitresult, ~] = createFit_gauss2(h2.BinEdges(1:end-1), h2.Values,[maximus1 maximus2],[bin1 h2.BinEdges(maxes(ind2))]);
% % %                 imshow(abs( im3),'parent',ax2)
% % %                 imshow(abs(im - im3),[],'parent',ax2)
% %                 disp(num2str(fitresult.b2))
%                 disp('Done')
%             end
%             disp('File Finished')
%             
%             %histogram(ax2,vars)
%             h = histfit(vars);
%             disp(h)
%             
%             x_bar = mean(vars);
%             s = std(vars);
% 
%             th = x_bar - 1.55*s;
%             
%             for j = 1:frame_nums(i)
%                 if j < 10
%                     f = strcat('000',num2str(j));
%                 elseif j < 100
%                     f = strcat('00',num2str(j));
%                 elseif j < 1000
%                     f = strcat('0',num2str(j));
%                 else
%                     f = strcat('',num2str(j));
%                 end
%                 file = strjoin([base,folder(i),'Low/',name_start(i),'fad_',f,'.jpg'],'');
%                 im = imread(file);
%                 imshow(im,'parent',ax1)
% 
%                 C = conv2(im,L);
%                 V = var(C(:))                
%                 
%                 if V < th
%                     disp('Blurry image. Booooo!')
%                 else
%                     disp('Non blurry image!')
%                 end                
%                 
%                 disp('Im Done')
%             end

        end
            
    end

end

function[v] = get_var(im,L)

    C = conv2(im,L);
    v = var(C(:));

end

function[im] = load_image(j,base,folder,name_start)

        if j < 10
            f = strcat('000',num2str(j));
        elseif j < 100
            f = strcat('00',num2str(j));
        elseif j < 1000
            f = strcat('0',num2str(j));
        else
            f = strcat('',num2str(j));
        end
        file = strjoin([base,folder,'Low/',name_start,'fad_',f,'.jpg'],'');
        im = imread(file);

end