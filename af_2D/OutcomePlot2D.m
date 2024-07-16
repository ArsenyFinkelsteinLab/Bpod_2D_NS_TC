function OutcomePlot2D(AxesHandle, TextBoxHandle, Action, varargin)
global BpodSystem S
switch Action
    case 'init'
        %initialize pokes plot
        SideList = varargin{1};
        nTrialsToShow = str2num(get(TextBoxHandle,'string')); %default number of trials to display
        axes(AxesHandle);
        %plot in specified axes
        if nTrialsToShow>length(SideList)
            Xdata = 1:length(SideList);
            Ydata = SideList;
        else
            Xdata = 1:nTrialsToShow;
            Ydata = SideList(Xdata);
        end
        if S.GUI.ProtocolType==1 || S.GUI.ProtocolType==2
            BpodSystem.GUIHandles.FutureTrialLine = line([Xdata,Xdata],[Ydata,Ydata],'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','b', 'MarkerSize',6);
            BpodSystem.GUIHandles.CurrentTrialCircle = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
            BpodSystem.GUIHandles.CurrentTrialCross = line([0,0],[0,0], 'LineStyle','none','Marker','+','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
            BpodSystem.GUIHandles.UnpunishedErrorLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace',[1 1 1], 'MarkerSize',6);
            BpodSystem.GUIHandles.PunishedErrorLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
            BpodSystem.GUIHandles.RewardedCorrectLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
            BpodSystem.GUIHandles.UnrewardedCorrectLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace',[1 1 1], 'MarkerSize',6);
            BpodSystem.GUIHandles.NoResponseLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','k','MarkerFace',[1 1 1], 'MarkerSize',6);
            BpodSystem.GUIHandles.EarlyLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
            BpodSystem.GUIHandles.NoEarlyLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
            BpodSystem.GUIHandles.AutolearnLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
            BpodSystem.GUIHandles.AntibiasLine = line([0,0],[0,0], 'LineStyle','none','Marker','o','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        end
        
        set(AxesHandle,'TickDir', 'out','YLim', [0, 3], 'YTick', [1 2],'YTickLabel', {'Hit','Ignore'}, 'FontSize', 16);
        xlabel(AxesHandle, 'Trial#', 'FontSize', 18);
        %hold(AxesHandle, 'on');
        xlim([max([0 length(Ydata)-nTrialsToShow]) max([length(Ydata) nTrialsToShow])]);
        BpodSystem.GUIHandles.perfAll = uicontrol('Style', 'text', 'String', 'Perf:	nan %','Position',[1220 150 150 20], 'FontSize', 12);
        BpodSystem.GUIHandles.perf20 = uicontrol('Style', 'text', 'String', 'Perf20: nan %','Position',[1220 120 150 20], 'FontSize', 12);
        BpodSystem.GUIHandles.perfR = uicontrol('Style', 'text', 'String', 'Perf R: nan %','Position',[1220 90 150 20], 'FontSize', 12);
        BpodSystem.GUIHandles.perfL = uicontrol('Style', 'text', 'String', 'Perf L: nan %','Position',[1220 60 150 20], 'FontSize', 12);
    case 'update'
        nTrialsToShow = str2num(get(TextBoxHandle,'string')); %default number of trials to display
        CurrentTrial = varargin{1};
        OutcomeRecord = varargin{3};

        if CurrentTrial<1
            CurrentTrial = 1;
        end
        % recompute xlim
        [mn, mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow);
        %Plot past trials
        if ~isempty(OutcomeRecord)
            indxToPlot = mn:CurrentTrial-1;
            %Plot Correct, rewarded
            CorrectTrialsIndx = (OutcomeRecord(indxToPlot) == 1);
            Xdata = indxToPlot(CorrectTrialsIndx); Ydata = OutcomeRecord(CorrectTrialsIndx);
            set(BpodSystem.GUIHandles.RewardedCorrectLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
            %Plot DidNotChoose
            DidNotChooseTrialsIndx = (OutcomeRecord(indxToPlot) == 2);
            Xdata = indxToPlot(DidNotChooseTrialsIndx); Ydata = OutcomeRecord(DidNotChooseTrialsIndx);
            set(BpodSystem.GUIHandles.NoResponseLine, 'xdata', [Xdata,Xdata], 'ydata', [Ydata,Ydata]);
            
            Perf_all = sum(OutcomeRecord==1)/length(OutcomeRecord);
            set(BpodSystem.GUIHandles.perfAll, 'String', ['Perf:	',num2str(Perf_all*100),' %']);
            if length(OutcomeRecord)>=20
                Perf_20 = sum(OutcomeRecord(end-19:end)==1)/20;
            else
                Perf_20 = sum(OutcomeRecord==1)/length(OutcomeRecord);
            end
            set(BpodSystem.GUIHandles.perf20, 'String', ['Perf20: ',num2str(Perf_20*100),' %']);
            
               end
    case 'next_trial'
        CurrentTrialType = varargin{1};
        if isempty(BpodSystem.Data.TrialTypes)
            nTrial = 0;
        else
            % nTrial = BpodSystem.Data.nTrialsToShow;
            nTrial = length([BpodSystem.Data.TrialTypes]);

        end
        set(BpodSystem.GUIHandles.CurrentTrialCircle, 'xdata', [nTrial+1 nTrial+1], 'ydata', [0,0]);
        set(BpodSystem.GUIHandles.CurrentTrialCross, 'xdata', [nTrial+1 nTrial+1], 'ydata', [0,0]);
end
end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end