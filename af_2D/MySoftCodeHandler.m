function MySoftCodeHandler(Byte)
global motors_properties BpodSystem S LickPortPosition LickPortPositionNextTrial;
% disp(Byte)
if Byte == 1 % Bringing the motor into lickable position
    mySet('Lx_motor_pos',LickPortPosition.X);
    Motor_Move(LickPortPosition.X, motors_properties.Lx_motor_num);

    mySet('Z_motor_pos',LickPortPosition.Z);
    Motor_Move(LickPortPosition.Z, motors_properties.Z_motor_num);
    
elseif Byte == 2 && S.GUI.MovingLP == 2  % Retracting the motors, and bringing them in the apropriate X position for the next trial
    p = find(cellfun(@(x) strcmp(x,'Z_NonLickable'),BpodSystem.GUIData.ParameterGUI.ParamNames));
    position=get(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String');
    mySet('Z_motor_pos',position);
    Motor_Move(position, motors_properties.Z_motor_num);
    
    mySet('Lx_motor_pos',LickPortPositionNextTrial.X);
    Motor_Move(LickPortPositionNextTrial.X, motors_properties.Lx_motor_num);

end

end
