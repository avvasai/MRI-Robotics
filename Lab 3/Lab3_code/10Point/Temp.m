% Define circle parameters

centerX = 0;

centerY = 0;

radius = 1;

numPoints = 10; 



% Generate angles around the circle

theta = linspace(0, 2*pi, numPoints);



% Calculate x and y coordinates 

x = radius * cos(theta) + centerX;

y = radius * sin(theta) + centerY;



% Plot the circle

plot(x, y, 'r'); 

axis equal; % Ensure aspect ratio is correct for a circular appearance

grid on;
