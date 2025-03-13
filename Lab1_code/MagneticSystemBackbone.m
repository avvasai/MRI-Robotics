clc
clear all
close all

% *****************Note*****************************
% Pixel coordinates is in pixels, robot coordinates is in meters
% x coordinate of a image is horizontal, increasing from left to right
% y coordinate of a image is vertical, increasing from top to bottom
% handles.data.image.curr_x is x coordinate in pixel coordinate
% handles.data.curr_x is x coordinate in robot coordinate
%***************************************************

%% hardware setups
handles.closedWindow = 0;

handles.joy = vrjoystick(1); % initialize joystick
handles.video = videoinput('gentl', 1, 'BGR8'); % intialize video

% TODO: You may need to change 'COM3' to your COM
handles.arduino = serialport('COM7', 115200);%initialize arduino communciation

%% setup camera parameters
src = getselectedsource(handles.video);
src.AutoExposureLightingMode = 'Backlight';
src.BalanceWhiteAuto = 'Once';

%% Setup preview window
fig = figure('NumberTitle', 'off', 'MenuBar', 'none');
fig.Name = 'My Camera';
ax = axes(fig);
current_frame = getsnapshot(handles.video);
im = image(ax, zeros(size(current_frame), 'uint8'));
axis(ax, 'image');
axes(ax); hold on

% marker for the current location and the target location
handles.graphics.hMarker = ...
    scatter(-10, -10, 'filled', 'dy','Parent', ax);
handles.graphics.gMarker = ...
    scatter(-10, -10, 'p', 'dg','Parent', ax);

% a line representing the orientation of the plot
handles.graphics.Orientation = ...
    plot([-10, -10],[-10, -10],'Parent', ax);
handles.data.resolution = [1024 1280];

% initialized variables for legend
handles.data.frameRateCam = [];
handles.data.curr_x = [];
handles.data.curr_y = [];

% legend
handles.graphics.framerate = text(ax,handles.data.resolution(1)/3,handles.data.resolution(2)/15,['Frame Rate ', num2str(handles.data.frameRateCam)],'HorizontalAlignment','left');
handles.graphics.Xgradient = text(ax,handles.data.resolution(1)/3,handles.data.resolution(2)/10,['X ', num2str(handles.data.curr_x)],'HorizontalAlignment','left');
handles.graphics.Ygradient = text(ax,handles.data.resolution(1)/3,handles.data.resolution(2)/7.5,['Y ', num2str(handles.data.curr_y)],'HorizontalAlignment','left');


%% Start preview
preview(handles.video, im)
setappdata(fig, 'cam', handles.video);

%% system settings
settings.saveon = 0;
settings.closedloop_control_on =0;
settings.localization_on = 0;
% TODO: turn on videoRecording when you want to record the video
settings.videoRecording_on = 0;


%% locate petri dish

%[handles.data.petri_center,handles.data.petri_radius] = findPetri(current_frame);

%plot(handles.data.petri_center(1),handles.data.petri_center(2),'bo','parent',ax)


%% initialize control related parameters

% initialize all the parameters
handles.data.isLocWorking = 0;
handles.data.last_t = -0.17;  % chnage this to make delta_t consistent
if (settings.localization_on)
    [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame);
   
    %'handles.data.curr_x = 
    %'handles.data.curr_y = 
else
    handles.data.curr_x = 0;
    handles.data.curr_y = 0;
    handles.data.image.curr_x = 0;
    handles.data.image.curr_y = 0;
    handles.data.curr_theta = 0;
end


handles.data.xVel = 0;
handles.data.yVel = 0;
handles.data.thetaVel = 0;
handles.data.goalReached = 0;

handles.data.prevXpos = 0;
handles.data.prevYpos = 0;
handles.data.err_prev_x = 0;
handles.data.err_prev_y = 0;
handles.data.sum_err_x = 0;
handles.data.sum_err_y = 0;
handles.data.dt = 0.17;

all_frames = [];
experimentdata = zeros(1,5); % should be initialized with correct number of elements

FS = stoploop({'Stop'});




% create video object if video recording is on
if (settings.videoRecording_on)
    % setup video recording
    v = VideoWriter('Camera.avi');
    open(v);
end

all_s = {};
tic

while (~FS.Stop()&&~handles.data.goalReached)
    
    current_frame = getimage(im);
    if (settings.localization_on)
        [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame);
    end
    
%     'handles.data.curr_x = ;
%     'handles.data.curr_y = ;
    
    t_processing = toc; % current time
     
% 
%     'handles.data.xVel = ;
%     'handles.data.yVel = ;
%     
    
    if (settings.closedloop_control_on && handles.data.isLocWorking) % close loop control
        
    else % joystick controller on
        [u] = JoystickActuation(handles.joy);
    end
    
    % TODO: finish MapInputtoCoilCurrents.m
    coil_currents = MapInputtoCoilCurrents(u, settings);  % calculate the coil current command
    ArduinoCommunication(coil_currents, handles.arduino); % send coil current command to arduino
    
    if(settings.localization_on)
          
%*************************************************************************
        % frame visualization + any indicators can be added on
%         handles.graphics.Orientation.XData = [red_centroid(:,1),blue_centroid(:,1)];
%         handles.graphics.Orientation.YData = [red_centroid(:,2),blue_centroid(:,2)];
%         
%         handles.data.frameRateCam = 1/handles.data.dt;
%         handles.graphics.framerate.String = ['Frame Rate ', num2str(handles.data.frameRateCam)];
%         handles.graphics.Xgradient.String = ['X ', num2str(handles.data.curr_x*1000)];
%         handles.graphics.Ygradient.String = ['Y ', num2str(handles.data.curr_y*1000)];
%         
%         if(~handles.data.isLocWorking)
%             disp("Localization not working")
%         else
%             c = [handles.data.image.curr_x, handles.data.image.curr_y];
%             %         plot(c(:,1),c(:,2),'r*')
%             handles.graphics.hMarker.XData = handles.data.image.curr_x;
%             handles.graphics.hMarker.YData = handles.data.image.curr_y;
%         end
%*************************************************************************
     end
    
   
    
    % for data saving
    handles.data.prev_t = handles.data.last_t;
    handles.data.last_t = toc;
    handles.data.dt = handles.data.last_t - handles.data.prev_t;
    
    % Create a function to plot the robot path. Use x, y, and theta in
    % robot coordinates to represent the robot location and orientation. 
    experimentdata = [experimentdata; handles.data.last_t coil_currents(1) coil_currents(2) coil_currents(3)...
        coil_currents(4)];
    
    
    
    % get the current frame with the markers 
    frame = getframe(ax);
    if (settings.videoRecording_on)
        writeVideo(v,frame);
    end
    
    % record the image frames 
    if (isempty(all_frames))
        all_frames = frame;
    else
        all_frames(:,:,:, end+1) = frame;
    end
    
    
end
if (settings.videoRecording_on)
    close(v);
end
if(settings.closedloop_control_on)
    % send 0 0 0 0 to arduino before closing everything
    coil_currents = [0, 0, 0, 0];
    for i = 1:5 % loop five times to make sure all the coil currents are zero
        ArduinoCommunication(coil_currents, handles.arduino);
    end
end
%
if (settings.saveon)
    save('actuation_signals.mat', 'experimentdata') %this is coil signals and other necessary data
    save('image_frames.mat', 'all_frames') % this is image frames 2D
end

%clear up variables
stoppreview(handles.video)
clear handles.video
clear handles.arduino
close all




