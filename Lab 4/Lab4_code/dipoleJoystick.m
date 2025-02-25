function [u, data] = dipoleJoystick(data)
% here the control algorithm (dipole model) with joystick reading
% coil current order LTRD

lh= data.joyReading(1);
lh = (abs(lh)>0.02)*lh;
lv= data.joyReading(2);
lv = (abs(lv)>0.02)*lv;
rh= data.joyReading(3);
rh = (abs(rh)>0.02)*rh;
rv= data.joyReading(4);
rv = (abs(rv)>0.02)*rv;
% eliminate when there is very small readings from the joystick

if lh == 0 && lv ==0 && rh==0 && rv==0
    u = [0 0 0 0];
else
    % TODO1: develop your dipole model here. You must define any constants
    % and/or other values your think must be used in the dipole model in
    % this TODO comment. The permeability and area are already defined for
    % you

    N = 648 % Number of windings in a single coil (Number of turns) 
    mu0 = 4*pi*1e-7; % permeability kg*m/(s*A)^2
    coil_area = pi*35e-3*35e-3;
    
    
    % TODO2: for each coil calculate the unit magnetic field (B_tilde) and
    % force (F_tilde)

    for i=1:4
        
        % unit magnetic field
        B_tilde(:,i) = ;
        % unit magnetic force
        F_tilde(:,i) = ;
        
    end
    
    % TODO3:  Uncomment lines and define desired heading and force  
    
%     h_des_x =; % Desired Orientation from joystick 
%     h_des_y =;
%     h_des = ;
      
%     F_des_x = ; % define desired F from joystick
%     F_des_y = ;
%     F_des = ;

      %Finish computing coil currents as shown in Class lectures

% TODO4: Uncomment and Define Coil Currents here
    %u = ;
    
end

% adjusting the currents based on the maximum current of power supply
MAX_CURR = 1;
curr_sum = sum(abs(u));
if curr_sum >MAX_CURR
    u = u/curr_sum*MAX_CURR;
end


end
