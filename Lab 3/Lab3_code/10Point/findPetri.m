function [petri_center,petri_radius] = findPetri(current_frame)
% Function used to locate the petri dish
    
    image = current_frame; 
    % TODO: use im2bw to threshold the image and convert it to binary image
    % you wll use the circle with maximum radius as the petri dish
    
    image_white = im2bw(image,0.45);
    [centers,radii] = imfindcircles(image_white,[300 500],'ObjectPolarity','bright', ...
    'Sensitivity',0.99);
    k_max =  (radii == max(radii));
    petri_center = centers(k_max,:);
    petri_radius = radii(k_max);


end

