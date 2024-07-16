function mySet(parameterName, parameterValue, varargin)
global BpodSystem;
p = find(cellfun(@(x) strcmp(x,parameterName),BpodSystem.GUIData.ParameterGUI.ParamNames));
if length(varargin)==1
	set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'Value',parameterValue);
else
	set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String',num2str(parameterValue));
end