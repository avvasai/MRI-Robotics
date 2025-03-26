function joyVibrate(joy, f) 

% simple single axis vibration (axis = 1 or 2)
force(joy,1,f);

% for t=1:0.25:10
%     force(joy, 1, f)
%     f = f + 0.025;
% end 
