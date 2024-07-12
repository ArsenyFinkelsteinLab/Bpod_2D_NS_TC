function myMove(position)
global motors_properties motors;
if isnumeric(position)
	move_absolute(motors, position, motors_properties.motor_num);
elseif ischar(position)
	position=str2num(position);
	if isempty(position)
		move_absolute(motors, 0, motors_properties.motor_num);
	else
		move_absolute(motors, position, motors_properties.motor_num);
	end
end