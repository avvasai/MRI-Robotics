
clc
clear all
close all

%% system settings
settings.saveon = 1;
settings.closedloop_control_on = 0;
settings.image_processing_on = 1;
settings.videoRecording_on = 1;

settings.p_control = 1;
settings.i_control = 1;
settings.d_control = 1;

settings.dipole_joysitck = 1;
settings.dipole_model = 0;

settings.trajectory_following_on = 0;

threshold = 5e-3; % position threshold for determine if the robot is at the target location
vel_threshold = 1e-3; % velocity threshold for determine if the robot is at the target location

%% hardware setups
handles.closedWindow = 0;
handles.joy = vrjoystick(1,'forcefeedback'); % initialize joystick
handles.video = videoinput('gentl', 1, 'BGR8'); % initialize video
handles.arduino = serialport('COM8', 115200); % initialize Arduino communication
%%
Wall = 0;
%% Defining magnetic component of the magnet
l_magnet = 4e-3; %m
d_magnet = 1e-3; %m
M_magnet = 1000e3; % A/m
volume_magnet = pi * (d_magnet/2)^2 * l_magnet;
handles.data.m_magnet = volume_magnet * M_magnet; %kA*m2 magnetic dipole moment

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

handles.graphics.hMarker = scatter(-10, -10, 'filled', 'dy', 'Parent', ax);
handles.graphics.gMarker = scatter(-10, -10, 'p', 'dg', 'Parent', ax);
handles.graphics.Orientation = plot([-10, -10], [-10, -10], 'Parent', ax);
handles.data.resolution = [1024, 1280];

handles.data.frameRateCam = [];
handles.data.curr_x = [];
handles.data.curr_y = [];

handles.graphics.framerate = text(ax, handles.data.resolution(1)/3, handles.data.resolution(2)/15, ['Frame Rate ', num2str(handles.data.frameRateCam)], 'HorizontalAlignment', 'left', 'Color', 'white');
handles.graphics.Xgradient = text(ax, handles.data.resolution(1)/3, handles.data.resolution(2)/10, ['X ', num2str(handles.data.curr_x)], 'HorizontalAlignment', 'left', 'Color', 'white');
handles.graphics.Ygradient = text(ax, handles.data.resolution(1)/3, handles.data.resolution(2)/7.5, ['Y ', num2str(handles.data.curr_y)], 'HorizontalAlignment', 'left', 'Color', 'white');
%handles.graphics.wallStatus = text(ax, handles.data.resolution(1)/3, handles.data.resolution(2)/5.5, ['Wall: No Wall'], 'HorizontalAlignment', 'left', 'Color', 'green');


%% Start preview
preview(handles.video, im)
setappdata(fig, 'cam', handles.video);

%% locate petri dish
[handles.data.petri_center, handles.data.petri_radius] = findPetri(current_frame);
current_frame = filterOutsideCircle(current_frame, handles.data.petri_center(1), handles.data.petri_center(2), handles.data.petri_radius);
scalar = 0.085 / (handles.data.petri_radius * 2); % m/pixel

%% initialize control related parameters
handles.data.isLocWorking = 1;
handles.data.prev_t = -0.1;


% initialize centroid tracking variables
handles.data.prev_centroid = [0, 0]; % Previous robot centroid (x, y)
handles.data.centroid_threshold = 5e-3; % Threshold to detect significant movement

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

% Initialize desired location
[x, y] = desiredpoints(current_frame, handles.data.petri_center, scalar);
handles.data.desired_x = x;
handles.data.desired_y = y;
handles.data.desired_theta = pi / 4;
handles.data.image_desired_x = handles.data.desired_x / scalar + handles.data.petri_center(1);
handles.data.image_desired_y = handles.data.desired_y / scalar + handles.data.petri_center(2);

% Define trajectory
shape = 2; % Circle
switch shape
    case 1 % diamond
        diamondsize = 8e-3;
        handles.data.trajectory = [diamondsize 0 -diamondsize 0 diamondsize; 0 -diamondsize 0 diamondsize 0; -pi/4 -3*pi/4 -pi/4 -3*pi/4 -pi/4];
    case 2 % circle
        r = 10e-3;
        handles.data.trajectory = [r r*cosd(30) r*cosd(60) 0 r*cosd(120) r*cosd(150) r*cosd(180) r*cosd(150) r*cosd(120) 0 r*cosd(60) r*cosd(30) r; 0 -r*sind(30) -r*sind(60) -r -r*sind(120) -r*sind(150) -r*sind(180) r*sind(150) r*sind(120) r r*sind(60) r*sind(30) 0; -pi/3 -2*pi/3 -5*pi/6 5*pi/6 5*pi/6 2*pi/3 pi/3 pi/3 pi/6 0 -pi/6 -pi/3 -2*pi/3];
end

all_frames = [];
all_s = {};
experimentdata = zeros(1, 8);

FS = stoploop({'Stop'});

if (settings.videoRecording_on)
    v = VideoWriter('Camera.avi');
    v.FrameRate = 5;
    open(v);
end

tic

ctr = 1;
trajectory_size = size(handles.data.trajectory, 2);
while (~FS.Stop())
    if(settings.trajectory_following_on)
        handles.data.desired_x = handles.data.trajectory(1, ctr);
        handles.data.desired_y = handles.data.trajectory(2, ctr);
        handles.data.desired_theta = handles.data.trajectory(3, ctr);
    end

    current_frame = getimage(im);

    if (settings.image_processing_on)
        current_frame = filterOutsideCircle(current_frame, handles.data.petri_center(1), handles.data.petri_center(2), handles.data.petri_radius);
        [handles.data.image.curr_x, handles.data.image.curr_y, handles.data.curr_theta, handles.data.isLocWorking, red_centroid, blue_centroid, robot_centroid_xy] = LocalizationTopView(current_frame);

        handles.data.curr_x = scalar * (handles.data.image.curr_x - handles.data.petri_center(1));
        handles.data.curr_y = scalar * (handles.data.image.curr_y - handles.data.petri_center(2));
    end

    %%% BEGIN LAB 5 CONTROL ADDITIONS


    % Calculate displacement of the centroid
    centroid_displacement = sqrt((handles.data.curr_x - handles.data.prev_centroid(1))^2 + ...
        (handles.data.curr_y - handles.data.prev_centroid(2))^2);

    % Get joystick input and calculate directions
    [joystick_vector] = JoystickActuation(handles.joy);
    joystick_vector = [joystick_vector(1) joystick_vector(2)];
    robot_dxdy_vector = [handles.data.curr_x - handles.data.prev_centroid(1), handles.data.curr_y - handles.data.prev_centroid(2)];

    % Normalize vectors to get directions
    if norm(joystick_vector) > 0
        joystick_direction = joystick_vector / norm(joystick_vector);
    else
        joystick_direction = [0, 0];
    end

    if norm(robot_dxdy_vector) > 0
        robot_direction = robot_dxdy_vector / norm(robot_dxdy_vector);
    else
        robot_direction = [0, 0];
    end

    % Calculate dot product to see if moving in same direction
    dot_product = dot(joystick_direction, robot_direction);
    %text(ax, handles.data.resolution(1)/3, handles.data.resolution(2)/5.5, ['              '], 'HorizontalAlignment', 'left', 'Color', 'black');
    % Wall detection logic
    % Create a black box for text display
    text_width = 500;
    text_height = 60;
    x_position = handles.data.resolution(1) - text_width - 10; % 10 pixels padding from right edge
    y_position = 10; % 10 pixels padding from top edge
    rect_position = [x_position, y_position, text_width, text_height]; % [x y width height]
    rect_handle = rectangle(ax, 'Position', rect_position, 'FaceColor', 'black', 'EdgeColor', 'none');

    % Initialize time tracking variables if they don't exist
    if ~isfield(handles.data, 'wall_contact_time')
        handles.data.wall_contact_time = 0;
        handles.data.t_start = 0;
        handles.data.f = 0;
    end

    if (centroid_displacement < handles.data.centroid_threshold*1.5) && (dot_product > 0.2) && (norm(joystick_vector) > 0.1)
        % Robot is trying to move in the direction of joystick but can't - wall detected
        disp('Wall is being hit');
        Wall = 1;

        % Start timing if this is the first detection
        if handles.data.wall_contact_time == 0
            handles.data.t_start = tic;
        end

        % Calculate elapsed time and force
        handles.data.wall_contact_time = toc(handles.data.t_start);
        handles.data.f = min(handles.data.wall_contact_time/5, 1); % Cap force at 1

        % Apply vibration with increasing force
        joyVibrate(handles.joy, handles.data.f);
        text(ax, x_position + 10, y_position + text_height/2, sprintf('Wall: Present; Force: %.2f', handles.data.f), 'HorizontalAlignment', 'left', 'Color', 'red');
    else
        handles.data.prev_centroid = [handles.data.curr_x, handles.data.curr_y];
        handles.data.wall_contact_time = 0;
        handles.data.f = 0;
        joyVibrate(handles.joy, 0);
        disp('No wall detected');
        Wall = 0;
        text(ax, x_position + 10, y_position + text_height/2, 'Wall: No Wall', 'HorizontalAlignment', 'left', 'Color', 'green');
    end

    %%% END LAB 5 CONTROL ADDITIONS


    % Control logic
    if (settings.closedloop_control_on && handles.data.isLocWorking)
        if (~handles.data.goalReached)
            if settings.dipole_joysitck
                [handles.data.joyReading] = JoystickActuation(handles.joy);
                [u, handles.data] = dipoleJoystick(handles.data);
            else
                [u, handles.data] = FeedbackControl(handles.data, settings);
            end
        end

        if ((abs(handles.data.desired_x - handles.data.curr_x) <= threshold) && (abs(handles.data.desired_y - handles.data.curr_y) <= threshold) && ...
                (abs(handles.data.xVel) <= vel_threshold) && (abs(handles.data.yVel) <= vel_threshold))
            if (ctr == trajectory_size)
                handles.data.goalReached = 1;
                disp('goal reached');
                FS.Stop();
                break;
            end
            handles.data.err_prev_x = 0;
            handles.data.err_prev_y = 0;
            ctr = ctr + 1;
        end

        handles.data.prevXpos = handles.data.curr_x;
        handles.data.prevYpos = handles.data.curr_y;
        handles.data.prevXvel = handles.data.xVel;
        handles.data.prevYvel = handles.data.yVel;
    else
        [u] = JoystickActuation(handles.joy);
    end

    coil_currents = MapInputtoCoilCurrents(u, settings);
    ArduinoCommunication(coil_currents, handles.arduino);

    if (settings.image_processing_on)
        handles.graphics.gMarker.XData = handles.data.image_desired_x;
        handles.graphics.gMarker.YData = handles.data.image_desired_y;
        handles.graphics.Orientation.XData = [red_centroid(:, 1), blue_centroid(:, 1)];
        handles.graphics.Orientation.YData = [red_centroid(:, 2), blue_centroid(:, 2)];

        handles.data.frameRateCam = 1 / handles.data.dt;
        handles.graphics.framerate.String = ['Frame Rate ', num2str(handles.data.frameRateCam)];
        handles.graphics.Xgradient.String = ['X ', num2str(handles.data.curr_x * 1000)];
        handles.graphics.Ygradient.String = ['Y ', num2str(handles.data.curr_y * 1000)];
        %handles.graphics.Wall.String = ['Wall ', num2str(handles.data.curr_y * 1000)];

        if (~handles.data.isLocWorking)
            disp("Localization not working");
        else
            c = [handles.data.image.curr_x, handles.data.image.curr_y];
            handles.graphics.hMarker.XData = handles.data.image.curr_x;
            handles.graphics.hMarker.YData = handles.data.image.curr_y;
        end
    end

    handles.data.prev_t = handles.data.last_t;
    handles.data.last_t = toc;
    handles.data.dt = handles.data.last_t - handles.data.prev_t;

    experimentdata = [experimentdata; handles.data.last_t coil_currents(1) coil_currents(2) coil_currents(3) coil_currents(4) handles.data.curr_x handles.data.curr_y handles.data.curr_theta];

    frame = getframe(ax);
    if (settings.videoRecording_on)
        writeVideo(v, frame);
    end

end
