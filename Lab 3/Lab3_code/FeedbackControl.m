function [u, data] = FeedbackControl(data, settings)
% coil current order SWEN

th = data.curr_theta;
% TODO: create your PID controller here, the input is data and settings and
% the output should be u (the control efforts) and data. You should update
% all the values in data class (position, error, etc.) and your contorl
% effort should be in the form of [south west east north].
kp = 0.05*0.1e3;
ki = 0.005*0.5e3;
kd = 2*sqrt(kd);%0.01*0.5e3;

% initialize output
south = 0; west = 0; east = 0; north = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Use settings.p_control, settings.i_control, settings.d_control in your pid control equation
% INSERT YOUR CODE HERE
% define the error
data.err_xPos = data.desired_x - data.curr_x;
data.err_yPos = data.desired_y - data.curr_y;

if data.err_xPos > 0 %if we have positive error, pull towards east coil
    east = kp * data.err_xPos;
else % if the error is negative, pull towards west coil 
    west = kp * data.err_xPos;
end

if data.err_yPos > 0 %if we have positive error, pull towards south coil
    south = kp * data.err_yPos;
else % if the error is negative, pull towards north coil 
    north = kp * data.err_yPos;
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


%% v