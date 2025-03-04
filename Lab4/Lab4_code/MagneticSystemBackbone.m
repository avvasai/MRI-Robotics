clc
clear all
close all

%% system settings
% CHange system settings as you need
settings.saveon = 1;
settings.closedloop_control_on =1;
settings.image_processing_on = 1;
settings.videoRecording_on = 1;

% Use these settings to switch between P, PI, PD and PID control as needed.
settings.p_control = 1;
settings.i_control = 0;
settings.d_control = 0;

% TODO1: change settings based on the problem you are working on
settings.dipole_joysitck = 1;
settings.dipole_model = 0;

% TODO2: change this to 1 when you want to follow trajectory
settings.trajectory_following_on = 0;

% set threshold to determine if the robot is at desired location
% TODO3: change threshold to make trajecotry work. Find the minimum
% threshold. The threshold value must be given in meters
threshold = 4e-3; %2e-3 % position threshold for determine is the robot is at the target location
vel_threshold = 3e-3; %0.1e-3; % velocity threshold for determine is the robot is at the target location

%% hardware setups
handles.closedWindow = 0;
handles.joy = vrjoystick(1); % initialize joystick
handles.video = videoinput('gentl', 1, 'BGR8'); % intialize video

%TODO4: Check COM port
handles.arduino = serialport('COM3', 115200);%initialize arduino communciation

%% Defining magnetic component of the magnet
% TODO5: change the dimensions with repect to your robot
l_magnet = 4e-3; %m This is either 4e-3 or 3e-3. Check underside of robot to see if you have 3 or 4 magnets
d_magnet = 1e-3; %m
M_magnet = 1000e3; % A/m
volume_magnet = pi*(d_magnet/2)^2*l_magnet;
handles.data.m_magnet = volume_magnet*M_magnet; %kA*m2 magnetic dipole moment

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

%% locate petri dish
%locate the petri dish and make the center as 0
[handles.data.petri_center,handles.data.petri_radius] = findPetri(current_frame);

% filter everything outside petri
current_frame = filterOutsideCircle(current_frame, handles.data.petri_center(1), handles.data.petri_center(2), handles.data.petri_radius);

% TODO6: Uncomment the following line and then copy and paste your equation for scalar from the previous lab
scalar = 0.085/(handles.data.petri_radius*2) ; % m/pixel


%% initialize control related parameters

% initialize all the parameters
handles.data.isLocWorking = 1;
% TODO7: initialize prev_t for the first derivative iteration calculation:
% define prev_t as the negative of your averaged delta_t. Calculating
% delta_t again might be worthwhile.
handles.data.prev_t= -0.1;
if (settings.image_processing_on)
    [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame);
    handles.data.curr_x = scalar*(handles.data.image.curr_x - handles.data.petri_center(1));
    handles.data.curr_y = scalar*(handles.data.image.curr_y - handles.data.petri_center(2));
else
    handles.data.curr_x = 0;
    handles.data.curr_y = 0;
    handles.data.image.curr_x = 0;
    handles.data.image.curr_y = 0;
    handles.data.curr_theta = 0;
end

% initialize important variables for pid control
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

% initialize desired location 
%[x,y] = desiredpoints(current_frame,handles.data.petri_center,scalar);
x = 0e-3; y = 0e-3;
handles.data.desired_x = x;
handles.data.desired_y = y;
handles.data.desired_theta = pi/4;
handles.data.image_desired_x = handles.data.desired_x / scalar + handles.data.petri_center(1);
handles.data.image_desired_y = handles.data.desired_y / scalar + handles.data.petri_center(2);

% define trajectory
% TODO8: Use the following cases to test your dipole model. You can change the shapes or add new shapes here
shape = 2; % 1: diamond, 2: circle

switch shape
    case 1 % diamond
        diamondsize = 8e-3;
        handles.data.trajectory = [diamondsize        0    -diamondsize     0        diamondsize;...
            0       -diamondsize         0       diamondsize        0;...
            -pi/4      -3*pi/4      -pi/4  -3*pi/4      -pi/4];

    case 2 % circle
        r = 10e-3;
        handles.data.trajectory = [r r*cosd(30) r*cosd(60) 0 r*cosd(120) r*cosd(150) r*cosd(180) r*cosd(150) r*cosd(120) 0 r*cosd(60) r*cosd(30) r;...
            0 -r*sind(30) -r*sind(60) -r -r*sind(120) -r*sind(150) -r*sind(180) r*sind(150) r*sind(120) r r*sind(60) r*sind(30) 0;...
            -pi/3 -2*pi/3 -5*pi/6 5*pi/6 5*pi/6 2*pi/3 pi/3 pi/3 pi/6 0 -pi/6 -pi/3 -2*pi/3 ];

end

all_frames = [];
all_s = {};

% TODO9: initialize the column number to match the number of variables you
% stored in experimentdata
experimentdata = zeros(1,8);

FS = stoploop({'Stop'});

% create video object if video recording is on
if (settings.videoRecording_on)
    % setup video recording
    v = VideoWriter('Camera.avi');
    v.FrameRate = 5;
    open(v);
end

tic

ctr = 1;
trajectory_size = size(handles.data.trajectory,2);
while (~FS.Stop())
    if(settings.trajectory_following_on)
        handles.data.desired_x = handles.data.trajectory(1,ctr);
        handles.data.desired_y = handles.data.trajectory(2,ctr);
        handles.data.desired_theta= handles.data.trajectory(3,ctr);
    end

    current_frame = getimage(im);

    if (settings.image_processing_on)
        % filter everything outside petri
        current_frame = filterOutsideCircle(current_frame, handles.data.petri_center(1), handles.data.petri_center(2), handles.data.petri_radius);
        [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta,handles.data.isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame);


        handles.data.curr_x = scalar*(handles.data.image.curr_x - handles.data.petri_center(1));
        handles.data.curr_y = scalar*(handles.data.image.curr_y - handles.data.petri_center(2));
        t_processing = toc;

        handles.data.xVel = (handles.data.curr_x - handles.data.prevXpos)/(t_processing - handles.data.last_t);
        handles.data.yVel = (handles.data.curr_y - handles.data.prevYpos)/(t_processing - handles.data.last_t);
    end

    if (settings.closedloop_control_on && handles.data.isLocWorking) % close loop control
        if(~handles.data.goalReached)

            if settings.dipole_joysitck
                % TODO10: modify your dipoleJoystick function to test using
                % joystick with dipole model
                [handles.data.joyReading] = JoystickActuation(handles.joy);
                [u,handles.data] = dipoleJoystick(handles.data);
            else
                % TODO11: modify your Feedbackcontrol function so that dipole
                % model can be implemented in closed loop
                [u, handles.data] = FeedbackControl(handles.data,settings);
            end
        end

        if((abs(handles.data.desired_x - handles.data.curr_x)<=threshold) && (abs(handles.data.desired_y - handles.data.curr_y)<= threshold)...
                && (abs(handles.data.xVel)<=vel_threshold) && (abs(handles.data.yVel)<=vel_threshold))
            if(ctr == trajectory_size)
                handles.data.goalReached = 1;
                disp('goal reached')
                FS.Stop();
                break;
            end
            %            FS.Stop();
            handles.data.err_prev_x = 0;% previous position error in x direction
            handles.data.err_prev_y = 0;% previous position error in y direction
            handles.data.sum_err_x = 0; % sum of position error in x coordinates
            handles.data.sum_err_y = 0; % sum of position error in y coordinates
            ctr = ctr + 1;
        end

        % store previous position, velocity
        handles.data.prevXpos = handles.data.curr_x;
        handles.data.prevYpos = handles.data.curr_y;
        handles.data.prevXvel = handles.data.xVel;
        handles.data.prevYvel = handles.data.yVel;
    else % joystick controller on
        [u] = JoystickActuation(handles.joy);
    end

    coil_currents = MapInputtoCoilCurrents(u, settings);  % calculate the coil current command
    ArduinoCommunication(coil_currents, handles.arduino); % send coil current command to arduino

    if(settings.image_processing_on)
        %         handles.data.desired_theta = (0.01*2*pi*handles.data.last_t);
        %         handles.data.desired_theta
        % frame visualization + any indicators can be added on
        % marker
        handles.data.image_desired_x = handles.data.desired_x / scalar + handles.data.petri_center(1);
        handles.data.image_desired_y = handles.data.desired_y / scalar + handles.data.petri_center(2);
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
            handles.graphics.hMarker.XData = handles.data.image.curr_x;
            handles.graphics.hMarker.YData = handles.data.image.curr_y;
        end

    end



    % for data saving
    handles.data.prev_t = handles.data.last_t;
    handles.data.last_t = toc;
    handles.data.dt = handles.data.last_t - handles.data.prev_t;


    experimentdata = [experimentdata; handles.data.last_t coil_currents(1) coil_currents(2) coil_currents(3)...
        coil_currents(4) handles.data.curr_x handles.data.curr_y handles.data.curr_theta];
    if(settings.closedloop_control_on && ~settings.dipole_joysitck)
        handles.data.err_prev_x = handles.data.err_xPos;
        handles.data.err_prev_y = handles.data.err_yPos;
    end

    % get the current frame with the markers
    frame = getframe(ax);
    if (settings.videoRecording_on)
        writeVideo(v,frame);
    end
    %
    % record the image frames
    %     if (isempty(all_frames))
    %         all_frames = frame;
    %     else
    %         all_frames(:,:,:, end+1) = frame;
    %     end


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




