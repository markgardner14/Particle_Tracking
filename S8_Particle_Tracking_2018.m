function S8_Particle_Tracking_2018

% Function to manually track movement of particles between adjacent
% frames. The time intervals between adjancet frames can be variable and
% not fixed. The file 'generate_time_values.m' will extract the time values from the images which are used in this function.  
%
% NOTE 1: Track only particles that are moving. Stationary particles should
% be excluded.
%
% BUTTON ASSIGNMENT:
%
%   LEFT MOUSE:                 Select and track a particle.
%
%   MIDDLE MOUSE (SPACEBAR):    Replay sequence
%                               Remove any selected points for the current particle
%
%   RIGHT MOUSE (UP ARROW):     Next. Finish tracking the current particle and begin the next PARTICLE
%                               NOTE: This action is not counted as a selection
%
%   RIGHT ARROW:                Move on. Finish tracking the current particle & timepoint and begin the next TIMEPOINT
%
%   LEFT ARROW:                 Go back. Remove current and previous particle and start previous particle (Only works in current timepoint)
%
%   X KEY:                      Run / animal no good. Complete the current run and begin the next LINE IN THE XLS

%% Perform setup

% Set the base pathname for the current machine
setbasepath;

% Time between frames in preview sequence
pauselength = 0.2;

% Set the axis visible for grid lines
iptsetpref('ImshowAxesVisible','on');
iptsetpref('ImshowBorder','loose');
iptsetpref('ImshowInitialMagnification', 40);

tmpdata = [];

% Select whether to start or continue an analysis
button = questdlg('Would you like to continue or begin a new analysis?', 'Analysis options', 'Continue', 'New', 'New');

switch button
    case 'Continue'
        
        [filename,pathname] = uigetfile('*.mat','Select a file',[basepath,'/MCT*.mat']);
        if filename == 0, return; end
        MAT = [pathname,filename];
        XLS = [MAT(1:length(MAT)-4),'.xls'];
        load(MAT);
        if complete,
            disp('Tracking complete for this experimental run!')
            return;
        end

    case 'New'

        [filename,pathname] = uigetfile('*.mat','Select an experiment','/*.m');     %Changed so that experiment file can be in a different directory
        experiment = [pathname,filename];
        %if experiment == 0, return; end
        if filename == 0, return; end
        run(experiment);
        
        if length(expt.tracking) > 1,
            tracked = listdlg('PromptString','Select experiment:','SelectionMode','single','ListString',num2str([1:length(expt.tracking)]'));
        else
            tracked = 1;
        end
        
        expt.info = ReadS8Data(strcat(pathname,expt.file.filelist));                %Changed so that experiment file can be in a different directory
        expt.rand_order = randperm(length(expt.tracking(tracked).runlist));
        expt.tracking(tracked).runlist = expt.tracking(tracked).runlist(expt.rand_order);     % Randomise the runlist order to blind observer
        expt.tracking(tracked).blocks = expt.tracking(tracked).blocks(randperm(length(expt.tracking(tracked).blocks)));        % Randomise the timepoints to analyse

        m = 1;
        t = 1;
        p = 1;
        complete = false;
        
        datetime = datestr(now,'yyyy-mmm-dd HH-MM-SS');
        initials = inputdlg('Please enter your initials (e.g. MD)','User ID');
        file = ['MCT ',datetime,' ',char(initials)];
        MAT = [basepath,expt.tracking(tracked).MCT,file,'.mat'];
        XLS = [basepath,expt.tracking(tracked).MCT,file,'.xls'];
        if(~exist([basepath,expt.tracking(tracked).MCT])), mkdir([basepath,expt.tracking(tracked).MCT]); end
        
        data = cell.empty(length(expt.info.imagestart),0);
        
end

if isfield(expt.naming,'zeropad') zeropad = expt.naming.zeropad; else zeropad = 4; end
h = figure;

if isfield(expt.tracking(tracked),'isfixed')
    fixed_Fs = expt.tracking(tracked).isfixed;
else
    fixed_Fs = true;
end

if fixed_Fs
    % Determine the frames to analyse
    startframes = expt.tracking(tracked).blockimages * expt.tracking(tracked).blocks + expt.tracking(tracked).startframe;
    L = numel(startframes);
else
    start_times =  expt.tracking(tracked).times*60;
    L = numel(start_times);
    
    inds = zeros(1,numel(expt.tracking(tracked).runlist));
    
    try
        expt.tracking(tracked).multiple_images;
    catch
        expt.tracking(tracked).multiple_images = false;
    end
    %if exist(expt.tracking(tracked).time_file,'file') > 0
    try
        load(expt.tracking(tracked).time_file,'times')
    %else
    catch
        try
            load(expt.file.time_file,'times')
        catch
            disp('Time file not found. Run file generate_time_values.m and save as expt.file.time_file in expt file')
            return

        end
    end

end



%% Begin analysis

% Repeat for each line in the XLS sheet
while m <= length(expt.tracking(tracked).runlist)
%     try
%         if ~isempty(data{expt.tracking(tracked).runlist(m)})
%             m = m + 1;
%             continue
%         end
%     catch
%         
%     end

        
    if ~fixed_Fs
        
        if expt.tracking(tracked).runlist(m) == 0
           m = m+1;
           continue
        end        
        if tracked == 3
            end_times = start_times + expt.tracking(tracked).frames;
        else
            %end_times =  start_times + expt.tracking(tracked).frames*median(diff(times(expt.rand_order(m)).t0));
            end_times =  start_times + expt.tracking(tracked).frames*median(diff(times(expt.tracking(tracked).runlist(m)).t0));
        end
    end
    
    % Repeat for each timepoint
    %while t <= length(startframes),
    while t <= L

        if ~fixed_Fs
            
            if expt.tracking(tracked).blocks(t) == 0
                t = t+1;
                continue
            end            
            try
                try
                    t_frames = times(expt.tracking(tracked).runlist(m)).t2;
                    %frames = find(times(expt.tracking(tracked).runlist(m)).t2 >= start_times(expt.tracking(tracked).blocks(t)) & times(expt.tracking(tracked).runlist(m)).t2 < end_times(expt.tracking(tracked).blocks(t)));
                    %frames = find(times(expt.rand_order(m)).t2 >= start_times(expt.tracking(tracked).blocks(t)) & times(expt.rand_order(m)).t2 < end_times(expt.tracking(tracked).blocks(t)));
                catch
                    t_frames = times(expt.rand_order(m)).t2;
                    %frames = find(times(expt.rand_order(m)).t2 >= start_times(expt.tracking(tracked).blocks(t)) & times(expt.rand_order(m)).t2 < end_times(expt.tracking(tracked).blocks(t)));
                end
                frames = find(t_frames >= start_times(expt.tracking(tracked).blocks(t)) & t_frames < end_times(expt.tracking(tracked).blocks(t)));

                %frames = find(times(expt.tracking(tracked).runlist(m)).t2 >= start_times(expt.tracking(tracked).blocks(t)) & times(expt.tracking(tracked).runlist(m)).t2 < end_times(expt.tracking(tracked).blocks(t)));
                if expt.tracking(tracked).multiple_images && numel(frames) > 1
                    frames = get_non_blurry_images(frames,t_frames(frames),basepath,expt,tracked,m);
%                    df_frames = diff(times(expt.rand_order(m)).t2(frames));
%                    md_pt = min(df_frames) * 2;% + (range(df_frames))/2;
%                    frames(df_frames > md_pt) = [];
%                    lows = find(diff(times(expt.rand_order(m)).t2(frames)) < md_pt);
%                    highs = find(diff(times(expt.rand_order(m)).t2(frames)) > md_pt);
%                    if numel(lows) > 1.5*numel(highs)
%                        df_frames = diff(times(expt.rand_order(m)).t2(frames));
%                        dels = find(df_frames > md_pt) + 1;
%                        frames(dels) = [];
%                    end
                end
            catch
               disp('Error') 
            end
            f = numel(frames);
            if f == 0
                t = t+1;
                continue
            end
            %start_frames = 'something'; 
        else
            f = expt.tracking(tracked).frames;
        end        
        
        % Load each of the images at that timepoint
        %for i = 1:expt.tracking(tracked).frames
        for i = 1:f

            % Calculate the framenumber
            if fixed_Fs 
                framenumber(i) = startframes(t) + (i - 1) * expt.tracking(tracked).gap + 1;
            else
                framenumber(i) = frames(i);
            end
            
            % Determine the filename
            imagename = [basepath,...
                expt.fad.corrected,...
                expt.info.image{expt.tracking(tracked).runlist(m)},...
                expt.fad.FAD_path_low,...
                expt.info.imagestart{expt.tracking(tracked).runlist(m)},...
                expt.fad.FAD_file_low,...
                sprintf(['%.',num2str(zeropad),'d'],framenumber(i)),...
                expt.fad.FAD_type_low];
            
            % Load the image
            if exist(imagename),
                %disp(['Loading image ', num2str(i), ' of ', num2str(expt.tracking(tracked).frames)]);
                disp(['Loading image ', num2str(i), ' of ', num2str(f)]);
                [images(:,:,i),acquired_temp] = ReadFileTime(imagename);
                if ~isempty(acquired_temp)
                    acquired(i) = acquired_temp;   
                else
                    acquired(i) = i;
                end                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%uncomment above%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%line%%%%%%%%%%%%%%%%%%%%
                %[images(:,:,i)] = ReadFileTime(imagename);
                %acquired(i) = framenumber(i)*expt.tracking(1).frameinterval;
            else
                images(:,:,i) = uint8(zeros(expt.tracking(tracked).imsize));
            end
            
        end
        
        acquired = acquired ./ 60;

        % Repeat for each of the particles
        while p < expt.tracking(tracked).particles,
            
            % Display the image series to allow user to visualise the particles
            %for i = expt.tracking(tracked).frames:-1:1,
            for i = f:-1:1,
                
                tic
                figure(h), imshow(images(:,:,i));
                grid on
                title(['Sequence Preview: Frame ',num2str(i)],'color','r')
                
                if ~isempty(tmpdata),
                    
                    % Determine the previous particles to mark
                    previous = find((tmpdata(:,1) == t) & (tmpdata(:,3) == framenumber(i)));
                    
                    % Mark each of the previously selected particles
                    for j = 1:length(previous), rectangle('Position',[tmpdata(previous(j),4)-expt.tracking(tracked).radius,tmpdata(previous(j),5)-expt.tracking(tracked).radius,2*expt.tracking(tracked).radius,2*expt.tracking(tracked).radius],'Curvature',[1,1],'EdgeColor','r'); end
                    
                end
                
                pause(pauselength-toc);
                
            end
            
            % Select the particles
            %for i = 1:expt.tracking(tracked).frames,
            for i = 1:f,

                figure(h), imshow(images(:,:,i));
                grid on
%                 title(['Run: ', num2str(m) ' of ', num2str(length(expt.tracking(tracked).runlist)),', ',...
%                     'Timepoint: ', num2str(t),' of ',num2str(length(startframes)),', ',...
%                     'Particle: ', num2str(p), ' of ', num2str(expt.tracking(tracked).particles), ', ',...
%                     'Frame: ', num2str(i),' of ', num2str(expt.tracking(tracked).frames)])
                title(['Run: ', num2str(m) ' of ', num2str(length(expt.tracking(tracked).runlist)),', ',...
                    'Timepoint: ', num2str(t),' of ',num2str(L),', ',...
                    'Particle: ', num2str(p), ' of ', num2str(expt.tracking(tracked).particles), ', ',...
                    'Frame: ', num2str(i),' of ', num2str(f)])
                
                if ~isempty(tmpdata),
                    
                    % Determine the previous particles to mark
                    previous = find((tmpdata(:,1) == t) & (tmpdata(:,3) == framenumber(i)));
                    
                    % Mark each of the previously selected particles
                    for j = 1:length(previous), rectangle('Position',[tmpdata(previous(j),4)-expt.tracking(tracked).radius,tmpdata(previous(j),5)-expt.tracking(tracked).radius,2*expt.tracking(tracked).radius,2*expt.tracking(tracked).radius],'Curvature',[1,1],'EdgeColor','r'); end

                end                

                % Get the user input
                [x, y, userinput] = ginput(1);
                
                % Perform action based on which button is pressed
                switch userinput,
                    
                    % Left button (select and track a particle)
                    case 1
                        tmpdata_new = [t, p, framenumber(i), x, y, acquired(i)];
                        tmpdata = [tmpdata; tmpdata_new];
                        %[x2,y2,~] = locate_particle(x,y,images(:,:,i),'');
                        %tmpdata = [tmpdata; t, p, framenumber(i), x2, y2, acquired(i)];
                        %if i == expt.tracking(tracked).frames,
                        if i == f,
                            p = p + 1;
                            break;
                        end
                        
                    % Middle button or spacebar (remove all data for that particle and REPLAY)
                    case {2, 32}
                        if i > 1,
                            tmpdata((tmpdata(:,1) == t) & (tmpdata(:,2) == p),:) = [];
                        end
                        break;
                        
                    % Right button (Finish current particle and start next PARTICLE)
                    case {3, 30}
                        p = p + 1;
                        break;
                        
                    % Right arrow (Finish current particle and start next TIMEPOINT)
                    case 29
                        p = expt.tracking(tracked).particles;
                        break;
                        
                    % Left arrow (Remove current and previous particles and start previous particle)
                    case 28
                        tmpdata((tmpdata(:,1) == t) & (tmpdata(:,2) >= p - 1),:) = [];
                        p = p - 1;
                        if p < 1, p = 1; end
                        break;
                        
                    % X key (Finish current particle and start next LINE IN THE XLS)
                    case 120
                        p = expt.tracking(tracked).particles;
                        if fixed_Fs 
                            t = length(startframes);
                        else
                            t = L;
                        end
                        break;
                        
                    %Delete key (Ignore frame)
                    case 127
                        tmpdata_new = [t, p, framenumber(i), -1, -1, acquired(i)];
                        tmpdata = [tmpdata; tmpdata_new];                        
                        if i == f,
                            p = p + 1;
                            break;
                        end                        
                        
                    otherwise
                        disp('Key has no effect')
                        break;
                        
                end
  
            end

            % Save the temporary results in the MAT file
            save(MAT,'expt','m','t','p','tmpdata','data','tracked','complete');
            
        end
        
        p = 1;
        t = t+1;
        
    end
    
    if isempty(tmpdata), 
        
        % In case no points were selected at any timepoint
        tmpdata = NaN; 
        
    else
                
        % Sort the data into the correct order
        if fixed_Fs
            [C,ia,ic] = unique(expt.tracking(tracked).blocks);
            temptimes = expt.tracking(tracked).times(ic');
            tmpdata(:,1) = temptimes(tmpdata(:,1))'; % To fix error found by Larissa Billig
%           tmpdata(:,1) = expt.tracking.times(tmpdata(:,1))';
            tmpdata = sortrows(tmpdata,[1 2 3]);            
        else
        % Sort the data into the correct order
            try
                tmpdata(:,1) = expt.tracking(tracked).times(expt.tracking(tracked).blocks(tmpdata(:,1)))';
            catch
                tmpdata(:,1) = expt.tracking(tracked).times(tmpdata(:,1))';
            end
            tmpdata = sortrows(tmpdata,[1 2 3]);            
        end
        
        % Remove any data from selections outside the image area
        tmpdata(tmpdata(:,4) < 0,4:5) = NaN;
        tmpdata(tmpdata(:,4) >  expt.tracking(tracked).imsize(2),4:5) = NaN;
        tmpdata(tmpdata(:,5) < 0,4:5) = NaN;
        tmpdata(tmpdata(:,5) > expt.tracking(tracked).imsize(1),4:5) = NaN;
        
        % Perform the remainder of the MCT rate calculations
        % (timepoint) (particle #) (frame) (x) (y) (time) (pixels) (mm) (dt) (rate) (angle)
        dx = tmpdata(:,4) - circshift(tmpdata(:,4),[1 0]);
        dy = tmpdata(:,5) - circshift(tmpdata(:,5),[1 0]);
        dt = tmpdata(:,6) - circshift(tmpdata(:,6),[1 0]);
        tmpdata(:,7) = sqrt(dx.^2 + dy.^2);
        tmpdata(:,8) = tmpdata(:,7)*expt.tracking(tracked).pixelsize;
        tmpdata(:,9) = dt;
        tmpdata(:,10) = tmpdata(:,8)./tmpdata(:,9);
%         tmpdata(:,11) = -sign(dy) .* (90 - atand(dx./abs(dy)));     % Relative to 90 degrees
        tmpdata(:,11) = sign(dx) .* (90 - atand(-dy./abs(dx)));     % Angle measured from 12 o'clock position

        
        % Remove the rate data for the first recorded frame for each tracked particle
        ia = find(sum(tmpdata(:,1:2) - circshift(tmpdata(:,1:2),[1 0]) ~= 0,2) ~= 0);
        tmpdata(ia,7:11) = NaN;
        
    end
    
    %% Save the data
    disp(['Writing file ', MAT]);
    data{expt.tracking(tracked).runlist(m)} = tmpdata;
    
    m = m+1;
    t = 1;
    tmpdata = [];
    if m < length(expt.tracking(tracked).runlist),
        save(MAT,'expt','data','m','t','p','tracked','complete');
    else
        complete = true;
        save(MAT,'expt','data','tracked','complete');
    end

end

color = 'blue';

% Create images with the particles marked
markParticles(expt, data, color);

close all; clc;