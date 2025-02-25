function [u, data] = FeedbackControl(data,settings)
% here the control algorithm (dipole model)
% coil current order LTRD

th = data.curr_theta;
theta = data.desired_theta;
%TODO1: copy and paste your calculation for pid from the previous lab. This
%refers to your force calculation from PID. You may have to tune the PID
%gains again. 


%TODO2: Define magnetic field computation here
mu0 = 4*pi*1e-7; % permeability kg*m/(s*A)^2
% m_magnet = ;
coil_area = pi*35e-3*35e-3;
coil_positions = [0 0.08; -0.08 0; 0.08 0; 0 -0.08]; % order: S W E N
coil_orientations = [0 1; -1 0; 1 0; 0 -1];


if(settings.dipole_model) % dipole model with position and orientation control
    % TODO3: Implement your dipole model here. You may use the same logic
    % as "dipoleJoystick.m". You can copy and paste your dipole model from dipoleJoystick.m and
    % replace joystick reading with open-loop for orientation and pid for
    % position
    for i=1:4
        
        
    end
    
    % Define coil currents here
    u = ;
    
else% pid controller without dipole model
    % TODO4: copy and paste your 'pid only' (P, PI, PD or PID whichever 
    % worked best for you in the previous lab) control effort here
    
    u = [south west east north];
end

% adjusting the currents based on the maximum current of power supply
MAX_CURR = 1;
curr_sum = sum(abs(u));
if curr_sum >MAX_CURR
    u = u/curr_sum*MAX_CURR;
end


end
