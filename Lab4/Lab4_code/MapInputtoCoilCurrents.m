function [coil_currents] = MapInputtoCoilCurrents(u, settings)

% find the actual coil current command

if (settings.closedloop_control_on)
    south = u(1);
    west = u(2);
    east = u(3);
    north = u(4); 
    % TODO: this should be either positive or negative depending on how you
    % define error, you should experiment yourself. 
    current = [south, west, east, north];
else % Joystick control on
    lh = u(1); % left horizontal joystick 
    lv = u(2); % left vertical joystick 
    rh = u(3); % right horizontal joystick 
    rv = u(4); % right vertical joystick  
    
    scale = 0.8; % scale down the current output
    
% control with two joysticks 
%     south_c = (max(0.0, -lv) + min(0.0, rv))*scale;
%     north_c = (max(0.0, lv) + min(0.0, -rv))*scale;
%     east_c = (max(0.0, -lh) + min(0.0, rh))*scale;
%     west_c = (max(0.0, lh) + min(0.0, -rh))*scale;
    

    south_c = max(0.0, lv)*scale;
    north_c = min(0.0, -lv) *scale;
    east_c = max(0.0, lh) *scale;
    west_c = min(0.0, -lh)  *scale;
    current = [south_c, west_c, east_c, north_c];
end
    % current projection
    MAX_CURR = 1; % maximum current
    curr_sum = sum(abs(current));
    if curr_sum >MAX_CURR
        coil_currents = current/curr_sum*MAX_CURR;
    else
        coil_currents = current;
    end 

end
