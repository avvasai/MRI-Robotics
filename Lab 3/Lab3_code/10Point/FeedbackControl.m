function [u, data] = FeedbackControl(data, settings)
% coil current order SWEN

%th = data.curr_theta;
% TODO: create your PID controller here, the input is data and settings and
% the output should be u (the control efforts) and data. You should update
% all the values in data class (position, error, etc.) and your contorl
% effort should be in the form of [south west east north].
kp = 0.7*0.1e3;
ki = 0.002*0.5e3;
kd = 0.15*sqrt(kp); % (mass spring damper critical - good starting point) %0.01*0.5e3;

% initialize output
south = 0; west = 0; east = 0; north = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Use settings.p_control, settings.i_control, settings.d_control in your pid control equation
% INSERT YOUR CODE HERE
% define the error
data.err_xPos = data.desired_x - data.curr_x;
data.err_yPos = data.desired_y - data.curr_y;

%derivative
x_error_dot = data.err_xPos/data.dt;
y_error_dot = data.err_yPos/data.dt;


% integral -> sum defined & updated in MagneticSystemBackbone.m while loop


% total control law
PID_x = [settings.p_control settings.i_control settings.d_control]*...
        [kp*data.err_xPos; ki*data.sum_err_x; kd*x_error_dot];

PID_y = [settings.p_control settings.i_control settings.d_control]*...
        [kp*data.err_yPos; ki*data.sum_err_y; kd*y_error_dot];

%Activation of Coils based on condition
 r_origin_x = data.curr_x;
 r_origin_y = data.curr_y;
 d_conv_x = data.desired_x - r_origin_x;
 d_conv_y = data.desired_y - r_origin_y;
 d_quad = quad(d_conv_x,d_conv_y);
 r_quad = quad(data.curr_x,data.curr_y);

if d_quad == 2 || d_quad == 3
    west = PID_x;
elseif d_quad == 1 || d_quad == 4
    east = PID_x;
else
    east = 0;
    west = 0;
end

if d_quad == 2 || d_quad == 1
    north = PID_y;
elseif d_quad == 4 || d_quad == 3
    south = PID_y;
else
    south = 0;
    north = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u = [south west east north];

% adjusting the currents based on the maximum current of power supply
MAX_CURR = 0.3;
curr_sum = norm(u);
if curr_sum >MAX_CURR
    u = u/curr_sum*MAX_CURR;
end

end


%% Helper Function

function val = quad(x,y)
    if x >=0 && y>0
        val = 4; 
    elseif x <=0 && y>0
        val = 3;%disp('Quadrant II') 
    elseif x <=0 && y<0
        val = 2;%disp('Quadrant III') 
    elseif x >=0 && y<0
        val = 1;%disp('Quadrant IV') 
    else 
        val = 0;
    end
end