function generate_time_values
%Extract time values from images and save them in a dataset that is
%accessed by the file S8_Particle_Tracking_2018.m


    base = 'I:/SPring-8/2017 B/Images/FD Corrected/';

    exp_name = 'S8_17B_XU';
    
    %run('exp_list/S8_17A_XU.m')
    run(['exp_list/', exp_name,'.m'])
    
    %Load info from excel spreadsheet
    disp('Loading file')
    %[num,txt,~] = xlsread('exp_list/S8_17A_XU.xlsx');
    [num,txt,~] = xlsread(['exp_list/',exp_name,'.xlsx']);
    disp('File Loaded')
    
    tracked = 1;
    
    num = num(expt.tracking(tracked).runlist,:);
    txt = txt(expt.tracking(tracked).runlist,:); 
    
    folder = txt(:,1);
    frame_nums = num(:,2);
    name_start = txt(:,2);
    
%     folder = txt(19:end,1);
%     frame_nums = num(19:end,2);
% 
%     name_start = txt(19:end,2);
    
%     times(1).t0 = 0;
%     times(1).num = 0;
    
    k = 1;
    
    for i = 1:numel(folder)
       %if ~contains(string(name_start(i)),'R01')
           disp(strjoin(['Analysing folder ',string(name_start(i))]),'')
           times(k).t0 = zeros(1,frame_nums(i));
           num2 = string(name_start(i));
           num2 = num2{1};
           %times(k).num = str2num(num2(10:11));
           %times(k).expt = str2num(num2(14:15));
           times(k).num = str2num(num2(9:10));
           times(k).expt = str2num(num2(13:14));           
           times(k).ind = i+expt.tracking.runlist(1) - 1;
           
           for j = 1:frame_nums(i)
%                if j < 10
%                    f = strcat('000',num2str(j));
%                elseif j < 100
%                    f = strcat('00',num2str(j));
%                elseif j < 1000
%                    f = strcat('0',num2str(j));
%                else
%                    f = num2str(j);
%                end
               if j < 10
                   f = strcat('00',num2str(j));
               elseif j < 100
                   f = strcat('0',num2str(j));
               elseif j < 1000
                   f = strcat('',num2str(j));
               else
                   f = num2str(j);
               end
               im_file = strjoin([base,string(folder(i)),'Low/',string(name_start(i)),'fad_',f,'.jpg'],'');
               if exist(im_file,'file')
                   %im = im_read(imfile);
                   %disp(['loading frame ',num2str(j)])
                   info = imfinfo(char(im_file));
                   if isfield(info, 'Comment')
                       %t = str2num(info.Comment{1});
                       times(k).t0(j) = str2num(info.Comment{1});
                       times(k).file(j) = strjoin([string(name_start(i)),'fad_',f],'');
                   end
               end
           end
           times(k).t2 = times(k).t0 - 60;
           k = k+1;
       %end
    end 
    
    save(['exp_list/', exp_name,'_times'],'times')
    
end

