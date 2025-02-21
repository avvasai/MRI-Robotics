clc
clear all
close all

%% hardware setups
handles.closedWindow = 0;
handles.joy = vrjoystick(1); % initialize joystick
handles.video = videoinput('gentl', 1, 'BGR8'); % intialize video
handles.arduino = serialport('COM3', 115200);%initialize arduino communciation

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
% TODO: turn on closedloop_control when you want to use PID
settings.closedloop_control_on = 1;
settings.image_processing_on = 1;
% TODO: turn on videoRecording when you want to record the video
settings.videoRecording_on = 1;

% TODO: use these settings for different closed-loop controller, ignore
% dipole model for this lab
% PID settings
settings.p_control = 1;
settings.i_control = 0;
settings.d_control = 0;

settings.dipole_model = 0;

% set threshold for determine if the robot is at desired location
threshold = 2e-3; % position threshold for determine is the robot is at the target location
vel_threshold = 0.1e-3; % velocity threshold for determine is the robot is at the target location


%% locate petri dish
%locate the petri dish and make the center as 0
[handles.data.petri_center,handles.data.petri_radius] = findPetri(current_frame);

% TODO: copy and paste your equation for scalar from the previous lab
scalar = 0.085/(handles.data.petri_radius*2) ; % m/pixel

%% initialize control related parameters

% initialize all the parameters
handles.data.isLocWorking = 1;
% TODO: initialize prev_t for the first derivative iteration calculation:
% define prev_t the negative of your averaged delta_t
handles.data.prev_t= -0.11;
if (settings.image_processing_on)
    [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame);
    % TODO: copy and paste your camera robot calibration here from the
    % previous lab
    handles.data.curr_x = (handles.data.image.curr_x-handles.data.petri_center(1))*scalar;
    handles.data.curr_y = (handles.data.image.curr_y-handles.data.petri_center(2))*scalar;
else
    handles.data.curr_x = 0;
    handles.data.curr_y = 0;
    handles.data.image.curr_x = 0;
    handles.data.image.curr_y = 0;
    handles.data.curr_theta = 0;
end

% TODO: initialize important variables for pid control
% go through these variables, use the name for these variables in your code
% and update their values
% all of these variables are in robot coordinates (in meters)
handles.data.xVel = 0;  % velocity in x direction
handles.data.yVel = 0;  % velocity in y direction
handles.data.thetaVel = 0;  % angular velocity
handles.data.prevXpos = 0;  % previous x position
handles.data.prevYpos = 0;  % previous y position
handles.data.err_xPos = 0; % initialize x position error
handles.data.err_yPos = 0; % initialize y position error
handles.data.err_prev_x = 0;% previous position error in x direction
handles.data.err_prev_y = 0;% previous position error in y direction
handles.data.sum_err_x = 0; % sum of position error in x coordinates
handles.data.sum_err_y = 0; % sum of position error in y coordinates
handles.data.last_t = 0; % current time
handles.data.dt = handles.data.last_t - handles.data.prev_t;     % delta_t
handles.data.goalReached = 0; % boolean to determine if the target is reached


% TODO: change target x and y for desired position and convert them into
% pixel coordinates so that they can be displayed on the image
%handles.data.desired_x = handles.data.curr_x + 0.085/4;
%handles.data.desired_y = handles.data.curr_y + 0*0.085/4;
handles.data.desired_theta = 0;

[handles.data.desired_x,handles.data.desired_y] = desiredpoints(current_frame,handles.data.petri_center,scalar);

handles.data.image_desired_x = handles.data.desired_x/scalar + handles.data.petri_center(1);
handles.data.image_desired_y = handles.data.desired_y/scalar + handles.data.petri_center(2);




all_frames = [];
all_s = {};

% TODO: initialize the column number to match the number of variables you
% stored in experimentdata
experimentdata = zeros(1,8);

FS = stoploop({'Stop'});

% create video object if video recording is on
if (settings.videoRecording_on)
    % setup video recording
    v = VideoWriter('Camera.avi');
    open(v);
end

tic

while (~FS.Stop())

    current_frame = getimage(im);
    if (settings.image_processing_on)
        [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame);

        % TODO: copy and paste from your previous lab

        handles.data.curr_x = (handles.data.image.curr_x - handles.data.petri_center(1))*scalar;
        handles.data.curr_y = (handles.data.image.curr_y - handles.data.petri_center(2))*scalar;
        t_processing = toc;
        % TODO: copy and paste from your previous lab
        handles.data.xVel = 0;
        handles.data.yVel = 0;
    end

    if (settings.closedloop_control_on && handles.data.isLocWorking) % close loop control
        if(~handles.data.goalReached)
            % TODO: finish Feedbackcontrol function using the given inputs
            % and outputs
            [u, handles.data] = FeedbackControl(handles.data,settings);
        end

        % TODO: Uncomment the following if needed
        % determine if the goal is reached with threshold
        if((abs(handles.data.desired_x - handles.data.curr_x)<=threshold) && (abs(handles.data.desired_y - handles.data.curr_y)<= threshold)...
                && (abs(handles.data.xVel)<=vel_threshold) && (abs(handles.data.yVel)<=vel_threshold))
            handles.data.goalReached = 1;
            disp('goal reached')
            FS.Stop();
            break;
        end

        % store previous position, velocity
        handles.data.prevXpos = handles.data.curr_x;
        handles.data.prevYpos = handles.data.curr_y;
        handles.data.prevXvel = handles.data.xVel;
        handles.data.prevYvel = handles.data.yVel;

        % sum error for integral (I) control
        handles.data.sum_err_x = handles.data.sum_err_x + handles.data.err_xPos;
        handles.data.sum_err_y = handles.data.sum_err_y + handles.data.err_yPos;

    else % joystick controller on
        [u] = JoystickActuation(handles.joy);
    end


    coil_currents = MapInputtoCoilCurrents(u, settings);  % calculate the coil current command
    ArduinoCommunication(coil_currents, handles.arduino); % send coil current command to arduino

    if(settings.image_processing_on)

        % frame visualization + any indicators can be added on
        % marker
        handles.graphics.gMarker.XData = handles.data.image_desired_x;
        handles.graphics.gMarker.YData = handles.data.image_desired_y;

        handles.graphics.Orientation.XData = [red_centroid(:,1),blue_centroid(:,1)];
        handles.graphics.Orientation.YData = [red_centroid(:,2),blue_centroid(:,2)];

        handles.data.frameRateCam = 1/handles.data.dt;
        handles.graphics.framerate.String = ['Frame Rate ', num2str(handles.data.frameRateCam)];
        handles.graphics.Xgradient.String = ['X ', num2str(handles.data.curr_x*1000)];
        handles.graphics.Ygradient.String = ['Y ', num2str(handles.data.curr_y*1000)];

        if(~handles.data.isLocWorking)
            disp("Localization not working")
        else
            c = [handles.data.image.curr_x, handles.data.image.curr_y];
            %         plot(c(:,1),c(:,2),'r*')
            handles.graphics.hMarker.XData = handles.data.image.curr_x;
            handles.graphics.hMarker.YData = handles.data.image.curr_y;
        end

    end



    % for data saving
    handles.data.prev_t = handles.data.last_t;
    handles.data.last_t = toc;
    handles.data.dt = handles.data.last_t - handles.data.prev_t;


    experimentdata = [experimentdata; handles.data.last_t coil_currents(1) coil_currents(2) coil_currents(3)...
        coil_currents(4) handles.data.image.curr_x handles.data.image.curr_y handles.data.curr_theta];

    if(settings.closedloop_control_on)
        handles.data.err_prev_x = handles.data.err_xPos;
        handles.data.err_prev_y = handles.data.err_yPos;
    end

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

%% plot experiment data after the while loop

% main plot - show x and y at same time
figure();
t = experimentdata(:,1); 
x = experimentdata(:,2); 
y = experimentdata(:,3);
plot(t,x,'b',t,y,'r'); 
xlabel('Time in seconds'); 
ylabel('Robot location (x,y) in m');

legend('x','y'); 
title('Robot coordinates vs time');

%% subplots
% seperate x and y into subplots at show steady-state error, settling time, and percent overshoot

figure(2);

% extract desired here
x_des = data.desired_x;
y_des = data.desired_y;

% use same error definition as in feedback control
data.err_xPos = data.desired_x - data.curr_x;
data.err_yPos = data.desired_y - data.curr_y;

% settling time for x and y
settling_threshold = 0.01; % this we can change, I am just choosing 1% threshold for no reason
time_x = find(abs(x - x(end)) <= settling_threshold * abs(x(end)), 1,'first');
time_y = find(abs(y - y(end)) <= settling_threshold * abs(y(end)), 1, 'first');
% percent overshoot for these two guys
percent_over_x = ((max(x) - x(end)) / x(end)) * 100;
percent_over_y = ((max(y) - y(end)) / y(end)) * 100;

% subplot for x
subplot(2,1,1); 
plot(t, x, 'b');
xlabel('Time (s)');
ylabel('Robot x (m)');
title('Robot x vs time');
plot([time_x, time_x], [min(y), max(x)], 'r--'); % plot line for settling time
plot([min(t), max(t)], [e_x, e_x], 'b--'); % plot line for steady-state error
text(0.1, max(x) - 0.2, sprintf('%.2f s', time_x), 'Color', 'black');
text(0.1, max(x) - 0.4, sprintf('Percent overshoot = %.2f%%', percent_over_x), 'Color', 'black');


% subplot for y
subplot(2,1,2); 
plot(t, y, 'r');
xlabel('Time (s)');
ylabel('Robot y (m)');
title('Robot y vs time');
plot([time_y, time_y], [min(y), max(x)], 'r--'); % plot line for settling time
plot([min(t), max(t)], [e_y, e_y], 'b--'); % plot line for steady-state error
text(0.1, max(x) - 0.2, sprintf('%.2f s', time_x), 'Color', 'black');
text(0.1, max(x) - 0.4, sprintf('Percent overshoot = %.2f%%', percent_over_x), 'Color', 'black');






