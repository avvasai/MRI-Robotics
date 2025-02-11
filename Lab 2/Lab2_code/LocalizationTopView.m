%function [x, y, theta,isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame)
% Function to localize the magnetic robot


% Training part of the file
videoFile = 'Camera2.avi';
% Create a VideoReader object
videoObj = VideoReader(videoFile);
% Get the frame you want (e.g., frame number 10)
frame_number = round(1543/2);
% Read the specified frame
singleFrame = read(videoObj, frame_number);
% Display the extracted frame
imshow(singleFrame);


% TODO: The following gives a example to find two a red region and a blue region
% Use your designed localization method to localize your robot. You can
% change the output to names as well. 

% output example: 
%   x: x coordinate of the robot in pixel coordinate
%   y: y coordinate of the robot in pixel coordinate
%   theta: orientation of the robot
%   isLocWorking: boolean showing if localization is working or not
%   red_centroid: centroid of red region 
%   blue_centroid: centroid of blue region
              

% if localization failed, output the following
x = 0;
y = 0;
theta = 0;
red_centroid = [0,0];
blue_centroid = [0,0];
disp("Localization Failed")
isLocWorking = 0;




%end



