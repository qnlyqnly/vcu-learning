function result = data_type_conversion_demo()
% MATLAB numeric conversion reference; not every Simulink block setting.
inputDouble = [-1.2; 0; 12.4; 12.6; 254.7; 260.0];
result.Data = table(inputDouble, single(inputDouble), uint8(inputDouble), ...
    'VariableNames', {'InputDouble','OutputSingle','OutputUint8'});
end
