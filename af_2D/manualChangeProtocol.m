function manualChangeProtocol(hObject, eventdata, input)
global S;
protocolType = get(hObject,'Value');
S.GUI.ProtocolType = protocolType;
S.ProtocolHistory(end+1,:) = [S.GUI.ProtocolType 1 0];