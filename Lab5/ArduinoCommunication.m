function [] = ArduinoCommunication(coil_currents, s)
% coil_current: coil value
% s: the serialport
write(s,coil_currents,"single")





