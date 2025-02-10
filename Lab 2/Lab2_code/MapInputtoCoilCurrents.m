function [coil_currents] = MapInputtoCoilCurrents(u, settings)

% find the actual coil current command

if (settings.closedloop_control_on)
    
else % Joystick control on
    lh = u(1); % left horizontal joystick 
    lv = u(2); % left vertical joystick 
    rh = u(3); % right horizontal joystick 
    rv = u(4); % right vertical joystick  
    
    scale = 0.8; % scale down the current output
   
    % 2 Joystick Control 
    south_c = (max(0.0, -lv) + max(0.0, -rv))*scale;
    north_c = (max(0.0, lv) + max(0.0, rv))*scale;
    east_c = (max(0.0, lh) + max(0.0, rh))*scale;
    west_c = (max(0.0, -lh) + max(0.0, -rh))*scale; 
    
end
    % current projection
    MAX_CURR = 1; % maximum current
    current = [south_c, west_c, east_c, north_c];
    curr_sum = sum(abs(current));
    if curr_sum >MAX_CURR
        coil_currents = current/curr_sum*MAX_CURR;
    else
        coil_currents = current;
    end 

end
