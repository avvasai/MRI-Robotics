clc
clear all
% Load the video file
% videoFile = ['1.avi','2.avi','3.avi','4.avi','5.avi','6.avi','7.avi','8.avi','9.avi','10.avi']; % Replace with your video file name
videoFile = [1:1:10];
%%loading some required variables
load('0.mat','scalar','handles')
load("main.mat","x","y")
x = x*scalar + handles.data.petri_center(1)*scalar;
y = y*scalar + handles.data.petri_center(1)*scalar;
%% 
x_robot = zeros(10,1);
y_robot = zeros(10,1);
%% 
for i = 1:numel(videoFile)
    vid = VideoReader(strcat(num2str(i),'.avi'));
% Read the last frame of the video
lastFrame = [];
while hasFrame(vid)
    lastFrame = readFrame(vid); % Continuously update until the last frame
end

% Display the last frame
imshow(lastFrame);
title('Last Frame: Click on a point');

% Get user input for the point (x, y) coordinates
[x_robot(i), y_robot(i)] = ginput(1); % Select one point on the last frame
close all
end
% %% 
%%
x_robot = -(x_robot - handles.data.petri_center(1))*scalar*2;
y_robot = -(y_robot - handles.data.petri_center(2))*scalar*2;
%%
errx = zeros(10,1);
erry = zeros(10,1);
for i = 1:numel(erry)
errx(i) = x_robot(i)-x(i);
erry(i) = y_robot(i)-y(i);
end
errx = errx*100;
erry = erry*100;
sx = std(errx)
sy = std(erry)
disp(max(errx))
disp(max(erry))
% Display the selected point on the image
hold on;
plot(x_robot, y_robot, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
plot(x, y, 'bo', 'MarkerSize', 10, 'LineWidth', 2);
hold off;

