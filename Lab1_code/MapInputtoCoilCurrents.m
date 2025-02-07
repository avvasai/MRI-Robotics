function [coil_currents] = MapInputtoCoilCurrents(u, settings)

% find the actual coil current command

if (settings.closedloop_control_on)
    
else % Joystick control on
    lh = u(1); % left horizontal joystick 
    lv = u(2); % left vertical joystick 
    rh = u(3); % right horizontal joystick 
    rv = u(4); % right vertical joystick  
    
    % You can change this scale but make sure it LESS THAN 1 and is a
    % single decimal number. (0.0 - 1.0)
    scale = 0.3; % scale down the current output. DO NOT INCREASE THIS BEYOND 0.3! 
   
    
%   TODO: convert the joystick output to coil current, you can either
%   control the robot with one joystick or two joysticks, as long as your
%   control action using joystick(s) is intuitive. Uncomment the following
%   lines and code from here
west_c = 0 ;
east_c = 0 ;
north_c = 0 ;
south_c = 0 ;
if lh<0.1
    west_c = 1*abs(scale*lh) ;
    %east_c = 0.5;
% for i = 0:(lh/10):lh
%     west_c = abs(scale*lh) ;
% end
elseif lh>0.1
    east_c =  1*abs(scale*lh) ;
    %west_c = 0.5;
% for i = 0:(lh/10):lh
%     east_c =  abs(scale*lh) ;
% end
else
    west_c = 0 ;
    east_c = 0 ;
    north_c = 0 ;
    south_c = 0 ;
end
if rv<0.1
    north_c = 1*abs(scale*rv) ;
    %south_c = 0.5;
% for i = 0:(rv/10):rv
%     north_c = abs(scale*rv) ;
% end
elseif rv > 0.1
    south_c =  1*abs(scale*rv) ;
    %north_c = 0.5;
% for i = 0:(rv/10):rv
%     south_c =  abs(scale*rv) ; 
% end
else
    west_c = 0 ;
    east_c = 0 ;
    north_c = 0 ;
    south_c = 0 ;
end

% DO NOT CHANGE THIS PART OF THE CODE!!! VERY IMPORTANT
    % current projection
    MAX_CURR = 0.3; % maximum current
    current = [south_c, west_c, east_c, north_c];
    disp("current = " + num2str(current))
    curr_sum = sum(abs(current));
    disp("sum = " + num2str(curr_sum));
   
    if curr_sum >MAX_CURR
        coil_currents = current/curr_sum*MAX_CURR;
    else
        coil_currents = current;
    end 
coil_currents
end
