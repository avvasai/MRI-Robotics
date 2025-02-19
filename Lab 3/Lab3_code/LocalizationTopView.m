function [x, y, theta,isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame)
% Function to localize the magnetic robot

% TODO: The following gives a example to find two a red region and a blue region
% You can use the largest region to reprent the object. Use your designed localization method 
% to localize your robot. 

% output: 
%   x: x coordinate of the robot in pixel coordinate
%   y: y coordinate of the robot in pixel coordinate
%   theta: orientation of the robot
%   isLocWorking: boolean showing if localization is working or not
%   red_centroid: centroid of red region 
%   blue_centroid: centroid of blue region
              

red_thr = 0.92; % threshold for red object (0-1)
red_area_size = 60; % size of the object in pixel
blue_thr = 0.95; % threshold for blue object (0-1)
blue_area_size = 60; % size of object in pixel

rgbaq = current_frame; % read image
rgbaq_normalized = bsxfun(@rdivide,im2double(rgbaq),sqrt(sum((im2double(rgbaq)).^2,3))); % normalize the image
%figure(); imshow(rgbaq_normalized)

rgbaq_thresholded_red = (rgbaq_normalized(:,:,1)>red_thr).*rgbaq_normalized(:,:,1); % threshold them
BW2 = bwareaopen(rgbaq_thresholded_red,red_area_size); % reduce into closed area
red_region  = regionprops(BW2, 'centroid', 'Orientation', 'Area');

rgbaq_thresholded_blue = (rgbaq_normalized(:,:,3)>blue_thr).*rgbaq_normalized(:,:,3); % threshold them
BW3 = bwareaopen(rgbaq_thresholded_blue,blue_area_size); % reduce into closed area
blue_region  = regionprops(BW3, 'centroid', 'Orientation', 'Area');

if (length(red_region) >= 1)
    if (length(red_region) > 1)
        red_region = red_region([red_region.Area] == max([red_region.Area]));
    end
    if (length(blue_region) > 1)
        blue_region = blue_region([blue_region.Area] == max([blue_region.Area]));
    end
    
    % store all the centroids into handle
    if (numel(red_region) == 0)
        red_centroid = [0 0];
        
    else
        red_centroid = red_region.Centroid;
    end
    
    if (numel(blue_region) == 0)
        blue_centroid = [0 0];
        
    else
        blue_centroid = blue_region.Centroid;
    end
    
    center = (red_centroid + blue_centroid)/2;
    x = center(1);
    y = center(2);
    center_dif = red_centroid - center;
    theta = atan2d(center_dif(2), -center_dif(1));
    
    isLocWorking = 1;
else
    x = 0;
    y = 0;
    theta = 0;
    disp("Localization Failed")
    isLocWorking = 0;
end



end



