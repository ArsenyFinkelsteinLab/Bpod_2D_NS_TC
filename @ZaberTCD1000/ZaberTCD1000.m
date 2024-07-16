function z = ZaberTCD1000(a)
%
% Arguments:
%
% -NONE: Zaber is intialized on serial port COM1.
% -Can be string giving serial port ID, eg, 'COM3'.
% 
%
% Zaber T-CD1000 motor controller class constructor
% DHO, 12/06
% TW 9/17: This configuration is computer specific
global ZaberPORT
ZaberPORT='COM6';
global maximum_zaber_position;
% maximum_zaber_position=300000;
maximum_zaber_position=1049869;

if nargin==0
    out = instrfind('Port',ZaberPORT);
	for i=1:length(out),
		fclose(out(i));
	end
	z.sobj = serial(ZaberPORT,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,...
        'InputBufferSize',6,'OutputBufferSize',6); % Input and output codes are all 6 bytes each
    set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
    z.unit = 0;
    z = class(z,'ZaberTCD1000');

elseif isa(a,'char')
	a=ZaberPORT; % FORCE PORT
    out = instrfind('Port',a);
	for i=1:length(out),
		fclose(out(i));
	end
    z.sobj = serial(a,'BaudRate',9600,'DataBits',8,'Parity','none','StopBits',1,...
        'InputBufferSize',6,'OutputBufferSize',6); % Input and output codes are all 6 bytes each
    set(z.sobj,'BytesAvailableFcnCount',6,'BytesAvailableFcnMode','byte')
    z.unit = 0;
    z = class(z,'ZaberTCD1000');

elseif isa(a,'ZaberTCD1000')
    z = a;
end
