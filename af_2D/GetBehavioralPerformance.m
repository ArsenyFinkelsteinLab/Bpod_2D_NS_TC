function [Outcomes, PrevProtocolTypes, Early, PrevTrialTypes] = GetBehavioralPerformance(Data)
if ~isempty(Data.TrialTypes)
    Outcomes = zeros(1,Data.nTrials);
    PrevProtocolTypes = zeros(1,Data.nTrials);
    Early = zeros(1,Data.nTrials);
    PrevTrialTypes = zeros(1,Data.nTrials);
  
    for x = 1:Data.nTrials
        if isfield(Data.TrialSettings(x),'GUI') && ~isempty(Data.TrialSettings(x).GUI) && isfield(Data.RawEvents.Trial{x}.States,'Reward') && Data.TrialSettings(x).GUI.ProtocolType>=1
            if ~isnan(Data.RawEvents.Trial{x}.States.Reward(1))
                Outcomes(x) = 1;    % correct
            elseif ~isnan(Data.RawEvents.Trial{x}.States.NoResponse(1))
                Outcomes(x) = 2;    % no response
            else
                Outcomes(x) = 3;    % others
            end
                Early(x) = 3;
        else
            Outcomes(x) = 3; % others
            Early(x) = 3;
        end
        if isfield(Data.TrialSettings(x),'GUI') && ~isempty(Data.TrialSettings(x).GUI) % if Bpod skipped
            PrevProtocolTypes(x) = Data.TrialSettings(x).GUI.ProtocolType;
            PrevTrialTypes(x) = Data.TrialTypes(x);
        else
            PrevProtocolTypes(x) = PrevProtocolTypes(x-1);
            PrevTrialTypes(x) = PrevTrialTypes(x-1);
                     
            warning('missing GUI');
            disp(x);
        end
    end
else
    Outcomes = [];
end
end
