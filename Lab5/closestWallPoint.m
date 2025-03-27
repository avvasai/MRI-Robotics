function d_min = closestWallPoint(data, P)
%function accepts:
%   handles.data (just need robot position: curr_x,curr_y) 
%   P: wall points (green pixels in the image from findMaze() function)
%returns:
%   d_min: distance of closest point from robot radius to wall points

% define robot position radius/circle
r = 0.0127; % PLACEHOLDER
cx = data.curr_x;
cy = data.curr_y;
theta = linspace(0,2*pi,50);
x = r*cos(theta) + cx;
y = r*sin(theta) + cy;

PQ = [x,y];

% find closest points
[k,dist] = dsearchn(P,PQ);

d_min = min(dist);