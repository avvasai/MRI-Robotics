function output = filterOutsideCircle(img, cx, cy, r)
    % Ensure the image is in double format for processing
    img = im2double(img);
    
    % Get the size of the image
    [rows, cols, channels] = size(img);
    
    % Create a grid of coordinates
    [X, Y] = meshgrid(1:cols, 1:rows);
    % Compute the mask for the circle
    mask = ((X - cx).^2 + (Y - cy).^2) <= r^2;
    
    % Create an output image initialized to zero (black)
    output = zeros(size(img));
    
    % Apply the mask to each channel
    for c = 1:channels
        tempChannel = img(:,:,c);
        tempChannel(~mask) = 1; % Set outside pixels to black
        output(:,:,c) = tempChannel;
    end
end