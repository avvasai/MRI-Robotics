% Load the video file
videoFile = 'camera.avi'; % Replace with your video file name
vid = VideoReader(videoFile);

% Initialize variables to store coordinates
frameCount = 0;
coordinates = []; % To store [x, y] coordinates for each frame

% Loop through all frames in the video
while hasFrame(vid)
    % Read the current frame
    frame = readFrame(vid);
    frameCount = frameCount + 1;
    
    % Display the frame
    imshow(frame);
    title(['Frame ', num2str(frameCount), ': Click on a point']);
    
    % Get user input for the point (x, y) coordinates
    [x, y] = ginput(1); % Select one point per frame
    
    % Store the coordinates
    coordinates = [coordinates; x, y];
    
    % Display the selected point on the image
    hold on;
    plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    hold off;
    
    % Pause for better visualization (optional)
    pause(0.1);
end

% Display results
disp('Coordinates for each frame:');
disp(coordinates);

% Save coordinates to a file (optional)
save('coordinates.mat', 'coordinates');
