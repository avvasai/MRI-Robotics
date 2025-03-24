function [I] = FEAJoystick(joy_axis, data, settings)
%joy_axis(1)--lh, right--1
%joy_axis(2)--lv, down--1
%joy_axis(4)--rh, right--1
%joy_axis(5)--rv, down--1
lh = joy_axis(1);
lh = (abs(lh)>0.02)*lh;
lv= joy_axis(2);
lv = (abs(lv)>0.02)*lv;
rh= joy_axis(4);
rh = -(abs(rh)>0.02)*rh;
rv= joy_axis(5);
rv = (abs(rv)>0.02)*rv;


if lh == 0 && lv ==0 && rh==0 && rv==0
    I = [0 0 0 0]';
else

    temp_theta=atan2(rv,rh)+pi;

    mm_N=[-data.m_magnet*cos(temp_theta);
        -data.m_magnet*sin(temp_theta)];
    mm_S=[-data.m_magnet*cos(temp_theta+pi);
        -data.m_magnet*sin(temp_theta+pi)];
    mm_W=[-data.m_magnet*cos(temp_theta+pi/2);
        -data.m_magnet*sin(temp_theta+pi/2)];
    mm_E=[-data.m_magnet*cos(temp_theta+3*pi/2);
        -data.m_magnet*sin(temp_theta+3*pi/2)];
    
    % Prevent interp2 out of limits
    if data.curr_x>50
        temp_x=50;
    elseif data.curr_x<-50
        temp_x=-50;
    else
        temp_x=data.curr_x;
    end
    
    if data.curr_y>50
        temp_y=50;
    elseif data.curr_y<-50
        temp_y=-50;
    else
        temp_y=data.curr_y;
    end
    
    % Calculate field for small coils
    Bx_N=interp2(data.field.Position_x, data.field.Position_y, data.field.Bx, -temp_x, -temp_y);
    By_N=interp2(data.field.Position_x, data.field.Position_y, data.field.By, -temp_x, -temp_y);
    dBxx_N=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxx, -temp_x, -temp_y);
    dBxy_N=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxy, -temp_x, -temp_y);
    dByx_N=interp2(data.field.Position_x, data.field.Position_y, data.field.dByx, -temp_x, -temp_y);
    dByy_N=interp2(data.field.Position_x, data.field.Position_y, data.field.dByy, -temp_x, -temp_y);
    
    Bx_S=interp2(data.field.Position_x, data.field.Position_y, data.field.Bx, temp_x, temp_y);
    By_S=interp2(data.field.Position_x, data.field.Position_y, data.field.By, temp_x, temp_y);
    dBxx_S=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxx, temp_x, temp_y);
    dBxy_S=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxy, temp_x, temp_y);
    dByx_S=interp2(data.field.Position_x, data.field.Position_y, data.field.dByx, temp_x, temp_y);
    dByy_S=interp2(data.field.Position_x, data.field.Position_y, data.field.dByy, temp_x, temp_y);
    
    Bx_E=interp2(data.field.Position_x, data.field.Position_y, data.field.Bx, -temp_y, temp_x);
    By_E=interp2(data.field.Position_x, data.field.Position_y, data.field.By, -temp_y, temp_x);
    dBxx_E=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxx, -temp_y, temp_x);
    dBxy_E=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxy, -temp_y, temp_x);
    dByx_E=interp2(data.field.Position_x, data.field.Position_y, data.field.dByx, -temp_y, temp_x);
    dByy_E=interp2(data.field.Position_x, data.field.Position_y, data.field.dByy, -temp_y, temp_x);
    
    Bx_W=interp2(data.field.Position_x, data.field.Position_y, data.field.Bx, temp_y, -temp_x);
    By_W=interp2(data.field.Position_x, data.field.Position_y, data.field.By, temp_y, -temp_x);
    dBxx_W=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxx, temp_y, -temp_x);
    dBxy_W=interp2(data.field.Position_x, data.field.Position_y, data.field.dBxy, temp_y, -temp_x);
    dByx_W=interp2(data.field.Position_x, data.field.Position_y, data.field.dByx, temp_y, -temp_x);
    dByy_W=interp2(data.field.Position_x, data.field.Position_y, data.field.dByy, temp_y, -temp_x);

    
    
    % Calculate B_tilde for all coils
    B_tilde=[Bx_S -By_W By_E -Bx_N;
             By_S Bx_W -Bx_E -By_N];

    % Calculate F_tilde for all coils
    dB_N=[dBxx_N dByx_N;
         dBxy_N dByy_N];
    dB_S=[dBxx_S dByx_S;
         dBxy_S dByy_S];
    dB_W=[dBxx_W dByx_W;
         dBxy_W dByy_W];
    dB_E=[dBxx_E dByx_E;
         dBxy_E dByy_E];
    
    F_tilde_N=dB_N*mm_N;
    F_tilde_S=dB_S*mm_S;
    F_tilde_W=dB_W*mm_W;
    F_tilde_E=dB_E*mm_E;

    F_tilde=[F_tilde_S(1) -F_tilde_W(2) F_tilde_E(2) -F_tilde_N(1);
            F_tilde_S(2) F_tilde_W(1) -F_tilde_E(1) -F_tilde_N(2)];

    h_des_x =rh; % Desired Orientation from joystick 
    h_des_y =rv;
    h_des = [h_des_x; h_des_y];
      
    F_des_x =-lh; % define desired F from joystick
    F_des_y =lv;
    F_des = [F_des_x; F_des_y];


    %Finish computing coil currents
    C=[B_tilde; F_tilde];

    A=[settings.OriWeight*h_des;F_des];
    %C=[C(:,2) C(:,3) C(:,4)];
    % I1=C1\A;%South, west, east, north
    % I2=C2\A;
    [a,b]=size(data.last_I);
    if a==1
        data.last_I=data.last_I';
    end

    if abs(det(C*C'))>0%1e-25
        C=[C;settings.ChangeWeight*eye(12)];
        A=[A;settings.ChangeWeight*data.last_I];
        I=C\A;

    else
        %warning("Singularity")
        I=Singularity_Solver(C,A,data.last_I,settings.ChangeWeight);
    end

    
    % adjust input based on the maximum allowed input
    signal_max = max(abs(I));
    if signal_max >settings.max_output
        I = I/signal_max*settings.max_output;
    end
end
end
