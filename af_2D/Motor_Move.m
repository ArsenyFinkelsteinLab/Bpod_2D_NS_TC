function Motor_Move(position, motor_num) % position is zaber position; motor_num is forward-backward (1) or left-right (2)
	global motors;
	if isnumeric(position)
		move_absolute(motors, position, motor_num);
	elseif ischar(position)
		position=str2num(position);
		if isempty(position)
			move_absolute(motors, 0, motor_num);
		else
			move_absolute(motors, position, motor_num);
		end
	end
end