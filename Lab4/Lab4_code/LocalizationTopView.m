% function [x, y, theta,isLocWorking,red_centroid,blue_centroid] = LocalizationTopView(current_frame)
% % Function to localize the magnetic robot
% 
% %% Training part of the file
% %{
% videoFile = 'Camera2.avi';
% % Create a VideoReader object
% videoObj = VideoReader(videoFile);
% % Get the frame you want (e.g., frame number 10)
% frame_number = randi([1 videoObj.NumFrames]); %round(1543/2);
% % Read the specified frame
% singleFrame = read(videoObj, frame_number);
% % Display the extracted frame
% %imshow(singleFrame);
% %}
% 
% 
% %converting the image to HSV color space
% hsv_img = rgb2hsv(current_frame); %change input to singleFrame if training
% 
% 
% % TODO: The following gives a example to find two a red region and a blue region
% % Use your designed localization method to localize your robot. You can
% % change the output to names as well.
% 
% %imshow(hsv_img)
% 
% %Defining the Red Region HSV Range
% r_hue_max = 0.99449;
% r_hue_min = 0.02521;
% r_sat_max = 0.6494;
% r_sat_min = 0.46667;
% r_val_max = 1;
% r_val_min = 0.96863;
% 
% 
% %Defining the Blue Region HSV Range
% b_hue_max = 0.62408;
% b_hue_min = 0.57047;
% b_sat_max = 0.98824;
% b_sat_min = 0.58431;
% b_val_max = 1;
% b_val_min = 0.77255;
% 
% %Creating a red binary mark
% r_mask = (hsv_img(:,:,1)>r_hue_min) & (hsv_img(:,:,1)<r_hue_max) & (hsv_img(:,:,2)>r_sat_min) & (hsv_img(:,:,2)<r_sat_max) &(hsv_img(:,:,3)>r_val_min) & (hsv_img(:,:,3)<r_val_max);
% b_mask = (hsv_img(:,:,1)>b_hue_min) & (hsv_img(:,:,1)<b_hue_max) & (hsv_img(:,:,2)>b_sat_min) & (hsv_img(:,:,2)<b_sat_max) &(hsv_img(:,:,3)>b_val_min) & (hsv_img(:,:,3)<b_val_max);
% %comb_mask =(hsv_img(:,:,1)>r_hue_min) & (hsv_img(:,:,1)<r_hue_max) & (hsv_img(:,:,2)>r_sat_min) & (hsv_img(:,:,2)<r_sat_max) &(hsv_img(:,:,3)>r_val_min) & (hsv_img(:,:,3)<r_val_max) & (hsv_img(:,:,1)>b_hue_min) & (hsv_img(:,:,1)<b_hue_max) & (hsv_img(:,:,2)>b_sat_min) & (hsv_img(:,:,2)<b_sat_max) &(hsv_img(:,:,3)>b_val_min) & (hsv_img(:,:,3)<b_val_max);
% 
% %Finding the connected components
% ccr = bwconncomp(r_mask);
% ccb = bwconncomp(b_mask);
% 
% %find the properties of the red region
% r_region = regionprops(ccr, 'Area', 'Centroid', 'BoundingBox');
% %finding the properties of the blue region
% b_region = regionprops(ccb, 'Area', 'Centroid', 'BoundingBox');
% 
% % Access properties of a specific region (e.g., the first region)
% %area = r_region(1).Area;
% %centroid = r_region(1).Centroid;
% %bbox = r_region(1).BoundingBox;
% 
% %% function outputs
% if isempty(r_region) || isempty(b_region)
%     % if localization failed, output the following   
%     x = 0;
%     y = 0;
%     theta = 0;
%     red_centroid = [0,0];
%     blue_centroid = [0,0];
%     disp("Localization Failed")
%     isLocWorking = 0;
% 
% else
%     % get the average centroid
%     %red_centroid = mean(cat(1, r_region.Centroid));
%     %blue_centroid = mean(cat(1, b_region.Centroid));
% 
%     % weighted centroids 
%     [red_centroid, blue_centroid] = weightedCentroids(r_region, b_region);
% 
%     theta = atan2((red_centroid(2)-blue_centroid(2)), ((red_centroid(1)-blue_centroid(1)))); %atan2((y2-y1),(x2-x1))
% 
%     robot_center = mean(cat(1, red_centroid,blue_centroid));
% 
%     x = robot_center(1);
%     y = robot_center(2);
% 
%     isLocWorking = 1; 
% 
% end
% 
% %% displaying the mask
% %{
% imshow(b_mask); 
% hold on;
% for i = 1:numel(r_region)
%     rectangle('Position', r_region(i).BoundingBox, 'EdgeColor', 'r');
% end
% for i = 1:numel(b_region)
%     rectangle('Position', b_region(i).BoundingBox, 'EdgeColor', 'b');
% end
% 
% plot(x,y, 'g*')
% %}
% 
% %rectangle('Position', r_region(i).Centroid, 'EdgeColor', 'g');
% 
% 
% % output example:
% %   x: x coordinate of the robot in pixel coordinate
% %   y: y coordinate of the robot in pixel coordinate
% %   theta: orientation of the robot
% %   isLocWorking: boolean showing if localization is working or not
% %   red_centroid: centroid of red region
% %   blue_centroid: centroid of blue region
% end
% 
% %% Helper functions
% function [red_centroid, blue_centroid] = weightedCentroids(r_region, b_region)
% %calculates weighted centroids of red and blue regions
% redA = sum(cat(1,r_region.Area));
% red_Ai = (cat(1,r_region.Area));
% red_C_i = cat(1,r_region.Centroid);
% red_Cx_i = red_C_i(:,1);
% red_Cy_i = red_C_i(:,2);
% 
% r_Cx = dot(red_Cx_i, red_Ai)/redA;
% r_Cy = dot(red_Cy_i, red_Ai)/redA;
% 
% red_centroid = [r_Cx r_Cy];
% 
% blueA = sum(cat(1,b_region.Area));
% blue_Ai = (cat(1,b_region.Area));
% blue_C_i = cat(1,b_region.Centroid);
% blue_Cx_i = blue_C_i(:,1);
% blue_Cy_i = blue_C_i(:,2);
% 
% b_Cx = dot(blue_Cx_i, blue_Ai)/blueA;
% b_Cy = dot(blue_Cy_i, blue_Ai)/blueA;
% 
% blue_centroid = [b_Cx b_Cy];
% 
% end


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


red_thr = 0.85; % threshold for red object (0-1)
red_area_size = 70; % size of the object in pixel
blue_thr = 0.85; % threshold for blue object (0-1)
blue_area_size = 70; % size of object in pixel

rgbaq = current_frame; % read image
rgbaq_normalized = bsxfun(@rdivide,im2double(rgbaq),sqrt(sum((im2double(rgbaq)).^2,3))); % normalize the image

rgbaq_thresholded_red = (rgbaq_normalized(:,:,1)>red_thr).*rgbaq_normalized(:,:,1); % threshold them
BW2 = bwareaopen(rgbaq_thresholded_red,red_area_size); % reduce into closed area
red_region  = regionprops(BW2, 'centroid', 'Orientation', 'Area');

rib = 0.25; %red_in_blue
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
    %theta = atan2d(center_dif(2), -center_dif(1));
    theta = atan2((red_centroid(2)-blue_centroid(2)), ((red_centroid(1)-blue_centroid(1)))); %atan2((y2-y1),(x2-x1))

    isLocWorking = 1;
else
    x = 0;
    y = 0;
    theta = 0;
    disp("Localization Failed")
    isLocWorking = 0;
end



end




