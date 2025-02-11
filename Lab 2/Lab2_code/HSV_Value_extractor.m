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

%converting the image to HSV color space
hsv_img = rgb2hsv(singleFrame);
imshow(hsv_img)

[x, y] = getpts;
% Display the clicked pixel coordinates

disp(['Clicked pixel coordinates: (', num2str(x), ', ', num2str(y), ')']);

% Access the HSV values at that point
hue = hsv_img(y, x, 1);  
saturation = hsv_img(y, x, 2); 
value = hsv_img(y, x, 3); 


% Display the extracted HSV values
disp(['Hue: ', num2str(hue)]);
disp(['Saturation: ', num2str(saturation)]);
disp(['Value: ', num2str(value)]);