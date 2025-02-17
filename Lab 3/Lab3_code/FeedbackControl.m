function [u, data] = FeedbackControl(data,settings)
% coil current order SWEN

th = data.curr_theta;
% TODO: create your PID controller here, the input is data and settings and
% the output should be u (the control efforts) and data. You should update
% all the values in data class (position, error, etc.) and your contorl
% effort should be in the form of [south west east north].
kp = 0.05*0.1e3;
ki = 0.005*0.5e3;
kd = 0.01*0.5e3;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Use settings.p_control, settings.i_control, settings.d_control in your pid control equation
% INSERT YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
u = [south west east north];

% adjusting the currents based on the maximum current of power supply
MAX_CURR = 0.3;
curr_sum = norm(u);
if curr_sum >MAX_CURR
    u = u/curr_sum*MAX_CURR;
end

end
