function [petri_center,petri_radius] = findPetri(current_frame)
% Function used to locate the petri dish

    image = current_frame; 
    
    image_grayscale = im2gray(image);
    image_white = imbinarize(image_grayscale, 'adaptive');

    image_white = bwareaopen(image_white, 6000);

    rmin = 360;
    rmax = 475;
    [centers,radii] = imfindcircles(image_white, [rmin rmax], ObjectPolarity="bright", Sensitivity=0.98);
    

    k_max =  (radii == max(radii));
    petri_center = centers(k_max,:); 
    petri_radius = radii(k_max);
    disp(petri_radius)
    
    %{
    figure
    imshow(image)
    hold on
    viscircles(centers, radii, 'EdgeColor', 'b');
    plot(petri_center(1), petri_center(2), '.', 'MarkerSize', 10);
    %}

end

