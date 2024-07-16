function af_2D

% Written by Arseny Finkelstein 05/2019.

% SETUP
% You will need:
% - A Bpod MouseBox (or equivalent) configured with 3 ports.
% > Port#1: Left lickport connected to left valve, left lick detector, and
% trigger 1 for WAV trigger
% for
% > Port#2: Right lickport connected to right valve, right lick detector, and
% trigger 2 for WAV trigger

% A Zaber motor is also connect to a pre-defined COM port so that the lickport can be moved automatically as part of the training program

global BpodSystem motors_properties motors S LickPortPosition LickPortPositionNextTrial;

%% Define parameters

motors_properties.PORT= 'COM6';

motors_properties.type = '@ZaberArseny';

motors_properties.Z_motor_num = 6;
motors_properties.Lx_motor_num = 4;
motors_properties.Ly_motor_num = 5;
BpodSystem.SoftCodeHandlerFunction = 'MySoftCodeHandler'; % for moving lickport

Camera_FPS = 250; % TTL pulses for camera
% Camera_FPS2 = 200; % Second TTL pulses for camera
MaxTrials = 9999;
RewardsForLastNTrials = 40; % THIS IS THE PERIOD OVER WHICH ADVANCEMENT PARAMETERS ARE DETERMINED
video_onset_delay=0.0;

% LeftWaterOutput = {'ValveState',2^0}; % Ethernet port 1
LeftWaterOutput = {'ValveState',2^1}; % Arseny I switched the ethernet ports on BPOD, so I am giving the reward on "right port" but its actully left


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               = LeftWaterOutput;
MoveLickPortIn = {'SoftCode', 1};
MoveLickPortOut = {'SoftCode', 2};

%% Load Settings
S = BpodSystem.ProtocolSettings; % Load settings chosen in launch manager into current workspace as a struct called S
if isempty(fieldnames(S))  % If settings file was an empty struct, populate struct with default settings
    S.GUI.WaterValveTime = 1;	  % in sec SET-UP SPECIFIC
    S.GUI.AutoWaterValveTime = 1;  % in sec SET-UP SPECIFIC
    S.GUI.RewardChangeProb  = 0.2; %probability on which a change in reward size will occur (reward omissions are not included here)
    S.GUI.RewardChangeFactor  = 3; % change in reward time compared to regular WaterValveTime
    S.GUI.RewardOmissionProb = 0.2; % Probability of a complete reward omission
    S.GUI.AnswerPeriodFirstLick = 100;	% in sec
    S.GUI.NumLicksForReward =2;
    S.GUI.AnswerPeriodEachLick=1;
    S.GUI.ConsumptionPeriod = 1;	  % in sec
    S.GUI.InterTrialInterval = 1.5;	  % in sec
    S.GUI.SpontaneousTrial = 60;	  % in sec
    
    S.GUIPanels.Behavior= {'WaterValveTime','AutoWaterValveTime','RewardChangeProb','RewardChangeFactor','RewardOmissionProb','AnswerPeriodFirstLick','AnswerPeriodEachLick','NumLicksForReward','ConsumptionPeriod','InterTrialInterval','SpontaneousTrial'};
    
    
    S.GUI.Z_motor_pos =  0;       %[0 200000];
    S.GUI.Lx_motor_pos = 210000;       %[0 1000000];
    S.GUI.Ly_motor_pos = 420000;       %[0 1000000];
    
    
    S.GUI.X_radius = 60000;
    S.GUI.Z_radius = 8000;
    S.GUI.num_bins = 4;
    
    S.GUI.X_center = 210000;
    S.GUI.Y_center =420000;
    S.GUI.Z_center = 153000;             % lickable position
    S.GUI.Z_NonLickable = 0;        % non lickable position
    S.GUIMeta.MovingLP.Style = 'popupmenu';      % trial type selection
    S.GUIMeta.MovingLP.String = {'OFF' 'ON'};
    S.GUI.MovingLP = 2;
    S.GUIPanels.Position = {'X_radius','Z_radius','num_bins','X_center','Y_center','Z_center','Lx_motor_pos','Ly_motor_pos','Z_motor_pos','MovingLP','Z_NonLickable','ResetSeq','RollDeg'};
    
    S.GUI.ResetSeq = 0;
    S.GUI.RollDeg = 0; %in degrees. Increase numbers means right ear down, from mouse perspective
    
    
    
    
    S.GUIMeta.ProtocolType.Style = 'popupmenu';	 % protocol type selection
    S.GUIMeta.ProtocolType.String = {'2D','Spontaneous'};
    S.GUI.ProtocolType = 1;
    S.GUIPanels.Protocol= {'ProtocolType'};
    
    S.GUIMeta.Autowater.Style = 'popupmenu';	 % give free water on every trial
    S.GUIMeta.Autowater.String = {'On' 'Off'};
    S.GUI.Autowater = 2;
    S.GUI.MaxSame = 7;
    S.GUI.AutowaterFirstTrialInBlock = 1;
    S.GUIPanels.TrialParameters= {'Autowater','MaxSame','AutowaterFirstTrialInBlock'};
    
    
    
    
    S.ProtocolHistory = [];	  % [protocol#, n_trials_on_this_protocol, performance]
end




%% Initialize
BpodParameterGUI('init', S);

% sync the protocol selections
p = find(cellfun(@(x) strcmp(x,'ProtocolType'),BpodSystem.GUIData.ParameterGUI.ParamNames));
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{@manualChangeProtocol, S});
p = find(cellfun(@(x) strcmp(x,'Autolearn'),BpodSystem.GUIData.ParameterGUI.ParamNames));
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{@manualChangeAutolearn, S});

%Arseny commented out
if isempty(S.ProtocolHistory)% start each day on autolearn
    S.ProtocolHistory(end+1,:) = [S.GUI.ProtocolType 1 0];
end


motors = ZaberTCD1000(motors_properties.PORT);
% serial_open(motors); Arseny uncomment DEBUG

% setup manual motor inputs
p = find(cellfun(@(x) strcmp(x,'Z_motor_pos'),BpodSystem.GUIData.ParameterGUI.ParamNames));
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{@manual_Z_Move});
Z_Move(get(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String'));

p = find(cellfun(@(x) strcmp(x,'Lx_motor_pos'),BpodSystem.GUIData.ParameterGUI.ParamNames));
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{@manual_Lx_Move});
Lx_Move(get(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String'));

p = find(cellfun(@(x) strcmp(x,'Ly_motor_pos'),BpodSystem.GUIData.ParameterGUI.ParamNames));
set(BpodSystem.GUIHandles.ParameterGUI.Params(p),'callback',{@manual_Ly_Move});
Ly_Move(get(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String'));



%% Define trials
TrialTypes_seq = [];
BpodSystem.Data.TrialTypes = []; % The trial type of each trial completed will be added here.
BpodSystem.Data.LickPortMotorPosition = [];
BpodSystem.Data.ProbeTrials = [];
BpodSystem.Data.StimTrials = [];
BpodSystem.Data.MATLABStartTimes = [];

%% Initialize plots
BpodSystem.ProtocolFigures.YesNoPerfOutcomePlotFig = figure('Position', [400 400 1400 200],'Name','Outcome plot','NumberTitle','off','MenuBar','none','Resize','off');
BpodSystem.GUIHandles.YesNoPerfOutcomePlot = axes('Position', [.1 .3 .75 .6]);
uicontrol('Style','text','String','nTrials','Position',[10 150 40 20]);
BpodSystem.GUIHandles.DisplayNTrials = uicontrol('Style','edit','string','100','Position',[10 130 40 20]);

%% Initialize BIAS interface for Video
% biasThing = StickShiftBpodUserClass() ;
% biasThing.wake() ;
% biasThing.startingRun() ;

% Pause the protocol before starting
BpodSystem.Status.Pause = 1;
HandlePauseCondition;

%% Computing trial structure (could be changed during ongoing aquisition by S.GUI.ResetSeq==1)
[trial_type_mat,X_positions_mat, Z_positions_mat, TrialTypes_seq, ~, first_trial_in_block_seq, current_trial_num_in_block_seq] = trial_sequence_assembly();
OutcomePlot2D(BpodSystem.GUIHandles.YesNoPerfOutcomePlot,BpodSystem.GUIHandles.DisplayNTrials,'init',2-TrialTypes_seq);


%% Main trial loop
for currentTrial = 1:MaxTrials
    S = BpodParameterGUI('sync', S); % Sync parameters with BpodParameterGUI plugin
    
    S.ProtocolHistory;
    %S.LickPortMove
    
    
    disp(['Starting trial ',num2str(currentTrial)])
    
    % build state matrix depending on the protocol type
    sma = NewStateMatrix(); % Assemble state matrix
    
    % sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 100, 'OnsetDelay', 0, 'Channel', 'BNC2', 'SendGlobalTimerEvents', 0); %% Arseny - trigger sent over BNC2
    % sma = SetGlobalTimer(sma, 'TimerID', 1, 'Duration', 100, 'OnsetDelay', 0, 'Channel', 'BNC1', 'SendGlobalTimerEvents', 0); %% Arseny - trigger sent over BNC2

    sma = SetGlobalTimer(sma, 'TimerID', 2, 'Duration', 1/(2*Camera_FPS), 'OnsetDelay', 0, 'Channel', 'Wire1', 'OnLevel', 1, 'OffLevel', 0, 'Loop', 1, 'SendGlobalTimerEvents', 0, 'LoopInterval', 1/(2*Camera_FPS));
    % TrialStart = {'GlobalTimerTrig', '1111'};
    TrialStart = {};
    

    sma = AddState(sma, 'Name', 'TrigTrialStart', 'Timer', 0.05, 'StateChangeConditions', {'Tup', 'StartBitcodeTrialNumber'},'OutputActions', TrialStart); % add bitcode here later
    
    %     sma = AddState(sma, 'Name', 'TrigTrialStart', 'Timer', 0.05, 'StateChangeConditions', {'Tup', 'StartBitcodeTrialNumber'},'OutputActions', TrialStart); % add bitcode here later
    
    %% Arseny generating bitcode (a different state for every bit). Sent over BNC2
    time_period=0.02;
    digits=20;
    %sends one pulse to signal the beginning of the bitcode that would contain a random trial-number
    sma = AddState(sma, 'Name', 'StartBitcodeTrialNumber', 'Timer', time_period*3, 'StateChangeConditions', {'Tup', 'OffState1'},'OutputActions', {'BNC2',1});
    random_number = floor(rand()*(2^digits-1));
    bitcode=dec2bin(random_number,digits);
    BpodSystem.Data.bitcode{currentTrial}=bitcode;
    %random trial bitcode
    for digit=1:digits
        sma = AddState(sma, 'Name', strcat('OffState',int2str(digit)), 'Timer', time_period, 'StateChangeConditions', {'Tup',strcat('OnState',int2str(digit))},'OutputActions',[]);
        bit=[];
        if bitcode(digit)=='1'
            bit={'BNC2',1};
        end
        
        sma = AddState(sma, 'Name', strcat('OnState',int2str(digit)), 'Timer', time_period, 'StateChangeConditions', {'Tup',strcat('OffState',int2str(digit+1))},'OutputActions', bit);
    end
    
    sma = AddState(sma, 'Name', strcat('OffState',int2str(digits+1)), 'Timer', time_period, 'StateChangeConditions', {'Tup','EndBitcodeTrialNumber'},'OutputActions',[]);
    %sends one pulse to signal the end of the bitcode that would contain a random trial-number
    sma = AddState(sma, 'Name', 'EndBitcodeTrialNumber', 'Timer', time_period*3, 'StateChangeConditions', {'Tup', 'OffStatePreSample'},'OutputActions', {'BNC2',1});
    
    
    switch S.GUI.ProtocolType
        
        case {1} % 2D trials
            if S.GUI.ResetSeq==1
                [trial_type_mat,X_positions_mat, Z_positions_mat, TrialTypes_seq, ~, first_trial_in_block_seq, current_trial_num_in_block_seq] = trial_sequence_assembly();
            end
            
            fprintf('Starting now: X pos %.1f  Z pos %.1f\n',X_positions_mat(TrialTypes_seq(currentTrial)),Z_positions_mat(TrialTypes_seq(currentTrial)));
            OutcomePlot2D(BpodSystem.GUIHandles.YesNoPerfOutcomePlot,BpodSystem.GUIHandles.DisplayNTrials,'next_trial',TrialTypes_seq(currentTrial));
            
            % saving TrialType related infor to BPOD
            BpodSystem.Data.trial_type_mat{currentTrial}=trial_type_mat;
            BpodSystem.Data.X_positions_mat{currentTrial}=X_positions_mat;
            BpodSystem.Data.Z_positions_mat{currentTrial}=Z_positions_mat;
            BpodSystem.Data.TrialTypes(currentTrial)=TrialTypes_seq(currentTrial);
            BpodSystem.Data.TrialBlockOrder(currentTrial)=current_trial_num_in_block_seq(currentTrial);
            
            flag_drop_water=0; %default
            if (S.GUI.AutowaterFirstTrialInBlock ==1 && first_trial_in_block_seq(currentTrial)==1) ... %drop water if its the first trial in block or if AutoWater
                    || (S.GUI.Autowater == 1) % or if AutoWater
                flag_drop_water = 1;
            end
            
            %% Reward size
            reward_flag=1; %default
            reward_size = S.GUI.WaterValveTime; %default
            if flag_drop_water==0
                x_prob=rand;
                if x_prob<S.GUI.RewardOmissionProb
                    reward_flag=0;
                end
                if x_prob>=(1-S.GUI.RewardChangeProb)
                    reward_flag=2; %that's just the flag, the actual value of a partial reward could be adjusted on-line from the GUI
                end
                
                reward_size = S.GUI.WaterValveTime;
                if  reward_flag ==0 %its a reward omission  trial
                    reward_size = 0;
                elseif reward_flag==2 %its a partial reward trial
                    reward_size = S.GUI.WaterValveTime * S.GUI.RewardChangeFactor;
                end
            end
            
            BpodSystem.Data.TrialRewardFlag (currentTrial) = reward_flag; % 0 no reward, 1 regular, 2 partial (higher or lower depends on the RewardFactor)
            
            %% Setting Motor positions for Current trial
            LickPortPosition.X=X_positions_mat(TrialTypes_seq(currentTrial));
            LickPortPosition.Z=Z_positions_mat(TrialTypes_seq(currentTrial));
            % Setting Motor positions for Next trial
            LickPortPositionNextTrial.X=X_positions_mat(TrialTypes_seq(currentTrial+1));
            
            
            %% Lick related states
            if flag_drop_water ==1 %drop water if on AutoWater or if its the first trial in a block
                sma = AddState(sma, 'Name', strcat('OffStatePreSample'), 'Timer', 2, 'StateChangeConditions', {'Tup','GiveDrop'},'OutputActions',[]);
                sma = AddState(sma, 'Name', 'GiveDrop', 'Timer', S.GUI.AutoWaterValveTime,'StateChangeConditions', {'Tup', 'AnswerPeriodAutoWater'},'OutputActions', RewardOutput); % turn on water
                BpodSystem.Data.TrialRewardSize (currentTrial) = S.GUI.AutoWaterValveTime; % in terms of valve time
            else
                if S.GUI.NumLicksForReward>1
                    % Giving reward only after XXX licks
                    sma = AddState(sma, 'Name', strcat('OffStatePreSample'), 'Timer', 2, 'StateChangeConditions', {'Tup','AnswerPeriodFirstLick'},'OutputActions',[]);
                    % sma = AddState(sma, 'Name', 'AnswerPeriodFirstLick', 'Timer', S.GUI.AnswerPeriodFirstLick,'StateChangeConditions', {'Port1In', 'LickIn1', 'Tup', 'NoResponse'},'OutputActions', MoveLickPortIn); % advance lickport and wait for response
                    sma = AddState(sma, 'Name', 'AnswerPeriodFirstLick', 'Timer', 1000,'StateChangeConditions', {'Port1In', 'LickIn1', 'Tup', 'NoResponse'},'OutputActions', MoveLickPortIn); % advance lickport and wait for response

                    sma = AddState(sma, 'Name', 'LickIn1', 'Timer', S.GUI.AnswerPeriodEachLick,'StateChangeConditions', {'Port1Out', 'LickOut1', 'Tup', 'NoResponse'},'OutputActions', []); % advance lickport and wait for response
                    for i_l=1:S.GUI.NumLicksForReward-1
                        sma = AddState(sma, 'Name', strcat('LickOut',int2str(i_l)), 'Timer', S.GUI.AnswerPeriodEachLick, 'StateChangeConditions', {'Port1In', strcat('LickIn',int2str(i_l+1)), 'Tup', 'NoResponse'},'OutputActions',[]);
                        sma = AddState(sma, 'Name', strcat('LickIn',int2str(i_l+1)), 'Timer', S.GUI.AnswerPeriodEachLick, 'StateChangeConditions', {'Port1In', strcat('LickOut',int2str(i_l+1)), 'Tup', 'NoResponse'},'OutputActions',[]);
                    end
                    sma = AddState(sma, 'Name', strcat('LickOut',int2str(i_l+1)), 'Timer', 1,'StateChangeConditions', {'Tup', 'Reward'},'OutputActions', []); % advance lickport and wait for response
                else %reward after first lick
                    sma = AddState(sma, 'Name', strcat('OffStatePreSample'), 'Timer', 2, 'StateChangeConditions', {'Tup','AnswerPeriod'},'OutputActions',[]);
                end
                BpodSystem.Data.TrialRewardSize (currentTrial) = reward_size; % in terms of valve time
            end
            
            % sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', S.GUI.AnswerPeriodFirstLick,'StateChangeConditions', {'Port1In', 'Reward', 'Tup', 'NoResponse'},'OutputActions', MoveLickPortIn); % advance lickport and wait for response
            sma = AddState(sma, 'Name', 'AnswerPeriod', 'Timer', 60,'StateChangeConditions', {'Port1In', 'Reward', 'Tup', 'NoResponse'},'OutputActions', MoveLickPortIn); % advance lickport and wait for response

            % sma = AddState(sma, 'Name', 'AnswerPeriodAutoWater', 'Timer', S.GUI.AnswerPeriodFirstLick,'StateChangeConditions', {'Port1In', 'RewardConsumption', 'Tup', 'NoResponse'},'OutputActions', MoveLickPortIn); % advance lickport and wait for response
            sma = AddState(sma, 'Name', 'AnswerPeriodAutoWater', 'Timer', 5,'StateChangeConditions', {'Port1In', 'RewardConsumption', 'Tup', 'NoResponse'},'OutputActions', MoveLickPortIn); % advance lickport and wait for response

            sma = AddState(sma, 'Name', 'Reward', 'Timer', reward_size,'StateChangeConditions', {'Tup', 'RewardConsumption'},'OutputActions', RewardOutput); % turn on water
            % sma = AddState(sma, 'Name', 'RewardConsumption', 'Timer', S.GUI.ConsumptionPeriod,'StateChangeConditions', {'Tup', 'InterTrialInterval'},'OutputActions', []); % reward consumption
            sma = AddState(sma, 'Name', 'RewardConsumption', 'Timer', 60,'StateChangeConditions', {'Tup', 'InterTrialInterval'},'OutputActions', []); % reward consumption

            % sma = AddState(sma, 'Name', 'NoResponse', 'Timer', S.GUI.ConsumptionPeriod, 'StateChangeConditions', {'Tup', 'InterTrialInterval'},'OutputActions',[]); % no response - wait same time as for reward consumption, as a time out
            sma = AddState(sma, 'Name', 'NoResponse', 'Timer', 60, 'StateChangeConditions', {'Tup', 'InterTrialInterval'},'OutputActions',[]); % no response - wait same time as for reward consumption, as a time out

            sma = AddState(sma, 'Name', 'InterTrialInterval', 'Timer', S.GUI.InterTrialInterval,'StateChangeConditions', {'Tup', 'TrialEnd'},'OutputActions', MoveLickPortOut); % retract lickport
            sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 2,'StateChangeConditions', {'Tup', 'exit'},'OutputActions', {'GlobalTimerCancel', '1111'}); %wait for the end of the trial
            
            BpodSystem.Data.BehaviorORSpontaneous{currentTrial}='Behavior';
        case {2} % Spontaneous
            sma = AddState(sma, 'Name', strcat('OffStatePreSample'), 'Timer', 2, 'StateChangeConditions', {'Tup','Spontaneous'},'OutputActions',[]);
            sma = AddState(sma, 'Name', strcat('Spontaneous'), 'Timer', S.GUI.SpontaneousTrial, 'StateChangeConditions', {'Tup','TrialEnd'},'OutputActions',[]);
            sma = AddState(sma, 'Name', 'TrialEnd', 'Timer', 2,'StateChangeConditions', {'Tup', 'exit'},'OutputActions', {'GlobalTimerCancel', '1111'}); %wait for the end of the trial
            BpodSystem.Data.TrialTypes(currentTrial)=0;
            BpodSystem.Data.BehaviorORSpontaneous{currentTrial}='Spontaneous';
            
    end
    
    
    %% Starting Video
    % biasThing.startingSweep() ;
    pause(0.2)
    
    %
    
    startTime=now;
    SendStateMatrix(sma);
    
    try
        RawEvents = RunStateMatrix;		 % this step takes a long time and variable (seem to wait for GUI to update, which takes a long time)
        bad = 0;
    catch ME
        warning('RunStateMatrix error!!!'); % TW: The Bpod USB communication error fails here.
        bad = 1;
    end
    
    % biasThing.completingSweep() ;
    S.GUI.ResetSeq=0;
    if bad == 0 & ~isempty(fieldnames(RawEvents)) % If trial data was returned
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents); % Computes trial events from raw data
        %%BpodSystem.Data = BpodNotebook('sync', BpodSystem.Data); % Sync with Bpod notebook plugin
        BpodSystem.Data.TrialSettings(currentTrial) = S; % Adds the settings used for the current trial to the Data struct (to be saved after the trial ends)
        %         BpodSystem.Data.TrialTypes(currentTrial) = TrialTypes_seq(currentTrial); % Adds the trial type of the current trial to data
        
        %% Arseny commented out
        % 			% save lickport position
        % 			p = find(cellfun(@(x) strcmp(x,'LickportMotorPosition'),BpodSystem.GUIData.ParameterGUI.ParamNames));
        % 			BpodSystem.Data.LickPortMotorPosition(currentTrial) = str2num(get(BpodSystem.GUIHandles.ParameterGUI.Params(p),'String'));
        
        
        BpodSystem.Data.MATLABStartTimes(currentTrial) = startTime;
        
        if S.GUI.ProtocolType == 1
            
            [Outcomes, PrevProtocolTypes, Early, PrevTrialTypes] = GetBehavioralPerformance(BpodSystem.Data);
            OutcomePlot2D(BpodSystem.GUIHandles.YesNoPerfOutcomePlot, BpodSystem.GUIHandles.DisplayNTrials, 'update', BpodSystem.Data.nTrials+1,TrialTypes_seq, Outcomes);
            
            %get % rewarded is past RewardsForLastNTrials trials (can probably be combined with outcomes above)
            Rewards = 0;
            for x = max([1 BpodSystem.Data.nTrials-(RewardsForLastNTrials-1)]):BpodSystem.Data.nTrials
                if BpodSystem.Data.TrialSettings(x).GUI.ProtocolType==S.GUI.ProtocolType & isfield(BpodSystem.Data.RawEvents.Trial{x}.States,'Reward')
                    if ~isnan(BpodSystem.Data.RawEvents.Trial{x}.States.Reward(1))
                        Rewards = Rewards + 1;
                    end
                end
            end
            S.ProtocolHistory(end,3) = Rewards / RewardsForLastNTrials;
            %             catch ME
            %                 warning('Data save error!!!');
            %                 bad = 1;
            %             end
        end
        if bad==0
            SaveBpodSessionData(); % Saves the field BpodSystem.Data to the current data file
            BpodSystem.ProtocolSettings = S;
            SaveBpodProtocolSettings();
        else
            warning('Data not saved!!!');
        end
    end
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
    
end
end


function manual_Z_Move(hObject, eventdata)
Z_Move(get(hObject,'String'));
end

function Z_Move(position)
global motors_properties;
% Motor_Move(position, motors_properties.Z_motor_num);
end


function manual_Lx_Move(hObject, eventdata)
% Lx_Move(get(hObject,'String'));
end

function Lx_Move(position)
global motors_properties;
% Motor_Move(position, motors_properties.Lx_motor_num);
end

function manual_Ly_Move(hObject, eventdata)
% Ly_Move(get(hObject,'String'));
end

function Ly_Move(position)
global motors_properties;
% Motor_Move(position, motors_properties.Ly_motor_num);
end


