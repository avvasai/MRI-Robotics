function joyVibrate(joy, f)
% simple single axis vibration 
x = 1:.25:10;
f = .1

for x < 10
    force(joy, x, f)
    f = f + 0.025;
end 
