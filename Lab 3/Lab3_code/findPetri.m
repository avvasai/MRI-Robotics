function [petri_center,petri_radius] = findPetri(current_frame)
% TODO: copy and paste your findPetri from previous lab
%Utilizing find petri from lab 2
% Function used to locate the petri dish
image = current_frame;
dia = 932.5495;
dia1 = round((dia -50)/2 - 50);
dia2 = round((dia+50)/2)+50;
image_white = imbinarize(image,'adaptive');
[centers,radii] = imfindcircles(image_white,[dia1 dia2],Sensitivity=0.92,Method="TwoStage");
k_max =  find(radii == max(radii));
petri_center = centers(k_max,:);
petri_radius = radii(k_max);

end

