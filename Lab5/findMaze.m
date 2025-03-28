function P = findMaze(current_frame)
% function returns all the 'green' points in the image, 
%    which are the maze walls

grn_thr = 0.8; % green thresh

rgbaq = current_frame; % read image
rgbaq_normalized = bsxfun(@rdivide,im2double(rgbaq),sqrt(sum((im2double(rgbaq)).^2,3))); % normalize the image

rgbaq_thresholded_green = (rgbaq_normalized(:,:,2)>grn_thr).*rgbaq_normalized(:,:,2);

[Gx, Gy] = find(rgbaq_thresholded_green.*current_frame); %indices of green pixels

P = [Gx, Gy];
