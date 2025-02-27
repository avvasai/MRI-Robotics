function [u, data] = FeedbackControl(data, settings)
% coil current order SWEN

%th = data.curr_theta;
% TODO: create your PID controller here, the input is data and settings and
% the output should be u (the control efforts) and data. You should update
% all the values in data class (position, error, etc.) and your contorl
% effort should be in the form of [south west east north].
kp = 0.6*0.1e3;
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
err_x_dot = (data.err_xPos-data.err_prev_x)/data.dt;
err_y_dot = (data.err_yPos-data.err_prev_y)/data.dt;

% sum error for integral (I) control
data.sum_err_x = data.sum_err_x + data.err_xPos*data.dt;
data.sum_err_y = data.sum_err_y + data.err_yPos*data.dt;

% total control law
PID_x = [settings.p_control settings.i_control settings.d_control]*...
    [kp*data.err_xPos; ki*data.sum_err_x; kd*err_x_dot];

PID_y = [settings.p_control settings.i_control settings.d_control]*...
    [kp*data.err_yPos; ki*data.sum_err_y; kd*err_y_dot];

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

u = [south west east north]

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