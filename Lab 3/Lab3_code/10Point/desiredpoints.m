function [x,y] = desiredpoints(current_frame,petri_center,scalar)
%Script to define the desired point in the image
f1 = figure();
imshow(current_frame);
[x, y] = getpts();
close(f1)

x = (x - petri_center(1))*scalar;
y = (y - petri_center(2))*scalar;

end


