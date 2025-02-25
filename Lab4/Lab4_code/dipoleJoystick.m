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

    N = 648; % Number of windings in a single coil (Number of turns)
    mu0 = 4*pi*1e-7; % permeability kg*m/(s*A)^2
    coil_area = pi*35e-3*35e-3;
    r1 = [0; 0.08]; r2 = [-0.08; 0]; r3 = [0.08;0]; r4 = [0;-0.08];
    r = [r1,r2,r3,r4];
    r_hat = [r1/norm(r1),r2/norm(r2),r3/norm(r3),r4/norm(r4)]; % unit pos vec matrix
    n_hat = [[0;1], [1;0], [1;0], [0;1]]; %unit vector normal to loop matrix

    m_c_tilde = N*coil_area*1*n_hat; % unit magnetic moment matrix

    m = data.m_magnet/mu0;
    h = [cos(handles.theta); sin(handles.theta)]; h_hat = h/norm(h); % CHECK THETA

    % TODO2: for each coil calculate the unit magnetic field (B_tilde) and
    % force (F_tilde)
    

    for i=1:4

        % unit magnetic field
        B_tilde(:,i) = (mu0/(4*pi*(norm(r(:,i))^3)))*(3*dot(m_c_tilde(:,i), r_hat(:,i))*r_hat(:,1)-m_c_tilde(:,i));
        % unit magnetic force
        F_tilde(:,i) = ((3*mu0)/(4*pi*(norm(r(:,i))^4)))*...
            (((dot(m_c_tilde(:,i),r_hat(:,i)))*m)...
            +(dot(m*r_hat(:,i))) + (dot(m_c_tilde(:,i),m)*r_hat(:,i))...
            -(5*dot(m_c_tilde(:,i),r_hat(:,i))*dot(m,r_hat(:,i))*(r_hat(:,i))));

    end

    C = [B_tilde; F_tilde];

    % TODO3:  Uncomment lines and define desired heading and force

    %     h_des_x =; % Desired Orientation from joystick
    %     h_des_y =;
    %     h_des = ;

    %     F_des_x = ; % define desired F from joystick
    %     F_des_y = ;
    %     F_des = ;

    %Finish computing coil currents as shown in Class lectures

    % TODO4: Uncomment and Define Coil Currents here
    u = ;

end

% adjusting the currents based on the maximum current of power supply
MAX_CURR = 1;
curr_sum = sum(abs(u));
if curr_sum >MAX_CURR
    u = u/curr_sum*MAX_CURR;
end


end
