function [petri_center,petri_radius] = findPetri(current_frame)
% Function used to locate the petri dish

    image = current_frame; 
    
    
    %'image_white = im2bw();
    %'[centers,radii] = imfindcircles();
    
    k_max =  (radii == max(radii));
    petri_center = centers(k_max,:);
    petri_radius = radii(k_max);


end

