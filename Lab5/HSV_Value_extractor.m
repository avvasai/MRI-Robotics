clc
clear all
% Training part of the file
videoFile = 'Camera.avi';
% Create a VideoReader object
videoObj = VideoReader(videoFile);
% Get the frame you want (e.g., frame number 10)
frame_number = round(1543/2)-1;
% Read the specified frame
singleFrame = read(videoObj, frame_number);
% Display the extracted frame
imshow(singleFrame);

%converting the image to HSV color space
hsv_img = rgb2hsv(singleFrame);
%cropping the image to the region of intrest
%cropped_image = imcrop(hsv_img); 
%imshow(cropped_image)

[x, y] = getpts;

% Display the clicked pixel coordinates
% disp(['Clicked pixel coordinates: (', num2str(x), ', ', num2str(y), ')']);
% 

%Going through a for loo and extracting the HUE Satruration and Val of a
%point
for i = 1:length(x)
    hue(i) = hsv_img(round(y(i)), round(x(i)), 1);
    saturation(i) = hsv_img(round(y(i)), round(x(i)), 2);
    value(i) = hsv_img(round(y(i)), round(x(i)), 3);
end
% % Display the extracted HSV values
disp(['Max Hue: ', num2str(max(hue))]);
disp(['Min Hue: ', num2str(min(hue))]);
disp(['Max Saturation: ', num2str(max(saturation))]);
disp(['Min Saturation: ', num2str(min(saturation))]);
disp(['MaxValue: ', num2str(max(value))]);
disp(['Min Value: ', num2str(min(value))]);


% % Access the HSV values at that point
% hue = hsv_img(y, x, 1);  
% saturation = hsv_img(y, x, 2); 
% value = hsv_img(y, x, 3); 
% 
% 
% % Display the extracted HSV values
% disp(['Hue: ', num2str(hue(1))]);
% disp(['Saturation: ', num2str(saturation(1))]);
% disp(['Value: ', num2str(value(1))]);