function out = data_type_conversion_demo()
% MATLAB cast illustration; not a full emulation of Simulink block settings.
x = [-1.2;0;12.4;12.6;254.7;260];
out.Data = table(x,single(x),uint8(x), ...
    'VariableNames',{'InputDouble','OutputSingle','OutputUint8'});
end
