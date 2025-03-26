function [u] = JoystickActuation(joy)
    % send the joystick signals to MapinouttoCoilCurrents
    
    joy_data = read(joy);
 
    lh = joy_data(1);% left horizontal joystick 
    lv = joy_data(2);% left vertical joystick 
    rh = joy_data(4);% right horizontal joystick
    rv = joy_data(5);% right vertical joystick
    
    u = [lh lv rh rv];

end
