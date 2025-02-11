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
%imshow(singleFrame);


% TODO: The following gives a example to find two a red region and a blue region
% Use your designed localization method to localize your robot. You can
% change the output to names as well. 

%converting the image to HSV color space
hsv_img = rgb2hsv(singleFrame);
imshow(hsv_img)

%Defining the Red Region HSV Range
r_hue_max = 0.057439; 
r_hue_min = 0.030382;
r_sat_max = 0.78261;
r_sat_min = 0.6996;
r_val_max = 1;
r_val_min = 0.95294;

%Defining the Blue Region HSV Range
b_hue_max = 0.8333; 
b_hue_min = 0.61639;
b_sat_max = 1;
b_sat_min = 0.876;
b_val_max = 1;
b_val_min = 0.94902;

%Creating a red binary mark
r_mask = (hsv_img(:,:,1)>r_hue_min) & (hsv_img(:,:,1)<r_hue_max) & (hsv_img(:,:,2)>r_sat_min) & (hsv_img(:,:,2)<r_sat_max) &(hsv_img(:,:,3)>r_val_min) & (hsv_img(:,:,3)<r_val_max);
b_mask = (hsv_img(:,:,1)>b_hue_min) & (hsv_img(:,:,1)<b_hue_max) & (hsv_img(:,:,2)>b_sat_min) & (hsv_img(:,:,2)<b_sat_max) &(hsv_img(:,:,3)>b_val_min) & (hsv_img(:,:,3)<b_val_max);
%comb_mask =(hsv_img(:,:,1)>r_hue_min) & (hsv_img(:,:,1)<r_hue_max) & (hsv_img(:,:,2)>r_sat_min) & (hsv_img(:,:,2)<r_sat_max) &(hsv_img(:,:,3)>r_val_min) & (hsv_img(:,:,3)<r_val_max) & (hsv_img(:,:,1)>b_hue_min) & (hsv_img(:,:,1)<b_hue_max) & (hsv_img(:,:,2)>b_sat_min) & (hsv_img(:,:,2)<b_sat_max) &(hsv_img(:,:,3)>b_val_min) & (hsv_img(:,:,3)<b_val_max);
%Finding the connected components
ccr = bwconncomp(r_mask);
ccb = bwconncomp(b_mask);
%find the properties of the red region
r_region = regionprops(ccr, 'Area', 'Centroid', 'BoundingBox');
%finding the properties of the blue region
b_region = regionprops(ccb, 'Area', 'Centroid', 'BoundingBox');

% Access properties of a specific region (e.g., the first region)
%area = r_region(1).Area;
%centroid = r_region(1).Centroid;
%bbox = r_region(1).BoundingBox;

%displaying the mask
imshow(b_mask); 
hold on;
for i = 1:numel(r_region)
    rectangle('Position', r_region(i).BoundingBox, 'EdgeColor', 'r');
end
for i = 1:numel(b_region)
    rectangle('Position', b_region(i).BoundingBox, 'EdgeColor', 'b');
end
%rectangle('Position', r_region(i).Centroid, 'EdgeColor', 'g');


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



