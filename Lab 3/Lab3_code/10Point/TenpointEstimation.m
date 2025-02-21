%%Script to run 10 points
clc
clear all
close all

%% hardware setups
handle.closedWindow = 0;
handle.joy = vrjoystick(1); % initialize joystick
handle.video = videoinput('gentl', 1, 'BGR8'); % intialize video
%handle.arduino = serialport('COM4', 115200);%initialize arduino communciation

%% setup camera parameters
src = getselectedsource(handle.video);
src.AutoExposureLightingMode = 'Backlight';
src.BalanceWhiteAuto = 'Once';

%% Setup preview window
fig = figure('NumberTitle', 'off', 'MenuBar', 'none');
fig.Name = 'My Camera';
ax = axes(fig);
current_frame = getsnapshot(handle.video);
im = image(ax, zeros(size(current_frame), 'uint8'));
axis(ax, 'image');
axes(ax); hold on

% marker for the current location and the target location
handle.graphics.hMarker = ...
    scatter(-10, -10, 'filled', 'dy','Parent', ax);
handle.graphics.gMarker = ...
    scatter(-10, -10, 'p', 'dg','Parent', ax);

% a line representing the orientation of the plot
handle.graphics.Orientation = ...
    plot([-10, -10],[-10, -10],'Parent', ax);
handle.data.resolution = [1024 1280];

% initialized variables for legend
handle.data.frameRateCam = [];
handle.data.curr_x = [];
handle.data.curr_y = [];

% legend
handle.graphics.framerate = text(ax,handle.data.resolution(1)/3,handle.data.resolution(2)/15,['Frame Rate ', num2str(handle.data.frameRateCam)],'HorizontalAlignment','left');
handle.graphics.Xgradient = text(ax,handle.data.resolution(1)/3,handle.data.resolution(2)/10,['X ', num2str(handle.data.curr_x)],'HorizontalAlignment','left');
handle.graphics.Ygradient = text(ax,handle.data.resolution(1)/3,handle.data.resolution(2)/7.5,['Y ', num2str(handle.data.curr_y)],'HorizontalAlignment','left');


%% Start preview
preview(handle.video, im)
setappdata(fig, 'cam', handle.video);

%% locate petri dish
%locate the petri dish and make the center as 0
[origin,radius] = findPetri(current_frame);

% TODO: copy and paste your equation for scalar from the previous lab
scalar = 0.085/(radius*2) ; % m/pixel

%% Finding all the coordinates for a circle with given radius
% Define circle parameters
centerX = 0;
centerY = 0;
[desiredradX,desiredradY] = desiredpoints(current_frame,origin,scalar);
radius = sqrt(((desiredradX)^2)+((desiredradY)^2));
numPoints = 10; 
% Generate angles around the circle
theta = linspace(0, 2*pi, numPoints);
% Calculate x and y coordinates 
x = radius * cos(theta) + centerX;
y = radius * sin(theta) + centerY;
%converting the x and y values to those of robot coordinate to find into
%magnetic function
%x = (x - centerX)*scalar;
%y = (y - centerY)*scalar;
% %% Close the video to find the center points
stoppreview(handle.video)
clear handle.video
close all

% plot(x, y, 'r'); 
% 
% axis equal; % Ensure aspect ratio is correct for a circular appearance
% 
% grid on;
% hold on;
% plot((centerX-centerX),(centerY-centerY),'o')

% 
% %% Running the while loop
%handles = [];
%experimentdata_main = [];
% plot((centerX-centerX),(centerY-centerY),'ro')
for i = 1:numPoints
    [~,~] = magnetic(0,0,0);
    [~,~] = magnetic(x(i),y(i),i);
    [~,~] = magnetic(0,0,0);
end
save('main',"x","y","radius","desiredradX","desiredradY")
close all