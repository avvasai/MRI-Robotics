function joyVibrate(joy, f) 
x = 1:.25:10;
f = .1

% simple single axis vibration (axis = 1 or 2)
force(joy,1,f);

% for x < 10
%     force(joy, x, f)
%     f = f + 0.025;
% end 
