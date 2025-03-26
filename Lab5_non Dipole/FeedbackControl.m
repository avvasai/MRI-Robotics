function [u, data] = FeedbackControl(data,settings)
% here the control algorithm (dipole model)
% coil current order LTRD

%TODO1: copy and paste your calculation for pid from the previous lab. This
%refers to your force calculation from PID. You may have to tune the PID
%gains again.


%TODO2: Define magnetic field computation here
N = 648; % Number of windings in a single coil (Number of turns)
mu0 = 4*pi*1e-7; % permeability kg*m/(s*A)^2
coil_area = pi*35e-3*35e-3;
r1 = [0; 0.08]; r2 = [-0.08; 0]; r3 = [0.08;0]; r4 = [0;-0.08]; % coil positions
r = -[r1,r2,r3,r4]+[data.curr_x; data.curr_y];
r_hat = [r1/norm(r1),r2/norm(r2),r3/norm(r3),r4/norm(r4)]; % unit pos vec matrix
n_hat = 1*[[0;1], [-1;0], [1;0], [0;-1]]; % coil orientations

m_c_tilde = N*coil_area*1*n_hat; % unit magnetic moment matrix

h = [cos(data.curr_theta); sin(data.curr_theta)]; h_hat = h/norm(h); % CHECK THETA
m = (data.m_magnet)*h_hat;


if(settings.dipole_model) % dipole model with position and orientation control
    % TODO3: Implement your dipole model here. You may use the same logic
    % as "dipoleJoystick.m". You can copy and paste your dipole model from dipoleJoystick.m and
    % replace joystick reading with open-loop for orientation and pid for
    % position
    for i=1:4
        % unit magnetic field
        B_tilde(:,i) = (mu0/(4*pi*(norm(r(:,i))^3)))*(3*dot(m_c_tilde(:,i), r_hat(:,i))*r_hat(:,i)-m_c_tilde(:,i));
        
        %unit magnetic force
        F_tilde(:,i) = ((3*mu0)/(4*pi*(norm(r(:,i))^4)))*...
            (((dot(m_c_tilde(:,i),r_hat(:,i)))*m)...
            + (dot(m,r_hat(:,i))*m_c_tilde(:,i))...
            + (dot(m_c_tilde(:,i),m)*r_hat(:,i))...
            - (5*dot(m_c_tilde(:,i),r_hat(:,i))*dot(m,r_hat(:,i))*(r_hat(:,i))));

    end

    C = [B_tilde;F_tilde];
    
    % desired heading - open loop
    alpha = 2.5e-8; % 0-20
    %{
    [lh, lv, rh, rv] = joystickOutput(data);
    h_des_x = rh; % Desired Orientation from joystick
    h_des_y = rv;
    %}
    h_des_x = cos(data.desired_theta);
    h_des_y = sin(data.desired_theta);
    h_des = [h_des_x; h_des_y];  h_des = alpha*h_des/norm(h_des);

    % desired force - PID
    [PID_x, PID_y] = controlEffort(data, settings);
    F_des_x = PID_x;
    F_des_y = PID_y;
    b=5;
    F_des = [F_des_x; F_des_y]

    M1 = [h_des;F_des];

    % Define coil currents here
    u = inv(C)*M1

else % pid controller without dipole model

    % TODO4: copy and paste your 'pid only' (P, PI, PD or PID whichever
    % worked best for you in the previous lab) control effort here

    [PID_x, PID_y] = controlEffort(data, settings);

    if data.err_xPos > 0 %if we have positive error, pull towards east coil
        east = PID_x;
    else % if the error is negative, pull towards west coil
        west = PID_x;
    end

    if data.err_yPos > 0 %if we have positive error, pull towards south coil
        south =  PID_y;
    else % if the error is negative, pull towards north coil
        north = PID_y;
    end

    u = [south west east north];
end

% adjusting the currents based on the maximum current of power supply
MAX_CURR = 0.3;
curr_sum = sum(abs(u));
if curr_sum >MAX_CURR
    u = u/curr_sum*MAX_CURR;
end


end


%% control law helper function
function [PID_x, PID_y] = controlEffort(data, settings)
kp_x = (0.09e-3); %(0.11e-3); 
kp_y = (0.12e-3);
ki = 1.5e-5;
kd_x = (0.08e-1*sqrt(kp_x)/5.7); 
kd_y = (0.11e-1*sqrt(kp_y)/5.2);% (mass spring damper critical - good starting point) %0.01*0.5e3;

% define the error
data.err_xPos = data.desired_x - data.curr_x;
data.err_yPos = data.desired_y - data.curr_y;

%derivative
err_x_dot = (data.err_xPos-data.err_prev_x)/data.dt;
err_y_dot = (data.err_yPos-data.err_prev_y)/data.dt;

% sum error for integral (I) control
data.sum_err_x = data.sum_err_x + data.err_xPos*data.dt;
data.sum_err_y = data.sum_err_y + data.err_yPos*data.dt;

% total control law
PID_x = [settings.p_control settings.i_control settings.d_control]*...
    [kp_x*data.err_xPos; ki*data.sum_err_x; kd_x*err_x_dot];

PID_y = [settings.p_control settings.i_control settings.d_control]*...
    [kp_y*data.err_yPos; ki*data.sum_err_y; kd_y*err_y_dot];

end

%% read joystick and give desired heading
function [lh, lv, rh, rv] = joystickOutput(data)
lh= data.joyReading(1);
lh = (abs(lh)>0.02)*lh;
lv= data.joyReading(2);
lv = (abs(lv)>0.02)*lv;
rh= data.joyReading(3);
rh = (abs(rh)>0.02)*rh;
rv= data.joyReading(4);
rv = (abs(rv)>0.02)*rv;
end