%% This code uses the computed number of error, error percentage and task completion time to plot the results
project_path = "C:\Users\hanna\OneDrive\MATLAB\lab\PhD\ErrorPrediction";
SavePath = fullfile(project_path, "TimeAccuracy");

AllParticipants = ['A', 'B', 'C', 'E', 'F', 'G', 'I', 'J', 'K', 'L', 'M', 'O', 'P', 'Q', 'T', 'U'];

AllTimes = zeros(3, 6, length(AllParticipants));
AllErrors = zeros(3, 6, length(AllParticipants));
NumErrors = zeros(3, 6, length(AllParticipants));

for pp = 1:length(AllParticipants)
    participant = AllParticipants(pp);

    cd(SavePath)
    Times_VR = load(['TotalTime_', participant, '_vertical_right', '.mat']).Times_VR;
    ErrorTimes_VR = load(['ErrorTime_', participant, '_vertical_right', '.mat']).ErrorTimes_VR;
    NumErrors_VR = load(['NumberOfErrors_', participant, '_vertical_right', '.mat']).NumErrors_VR;

    Times_HL = load(['TotalTime_', participant, '_horizontal_left', '.mat']).Times_HL;
    ErrorTimes_HL = load(['ErrorTime_', participant, '_horizontal_left', '.mat']).ErrorTimes_HL;
    NumErrors_HL = load(['NumberOfErrors_', participant, '_horizontal_left', '.mat']).NumErrors_HL;

    Times_VL = load(['TotalTime_', participant, '_vertical_left', '.mat']).Times_VL;
    ErrorTimes_VL = load(['ErrorTime_', participant, '_vertical_left', '.mat']).ErrorTimes_VL;
    NumErrors_VL = load(['NumberOfErrors_', participant, '_vertical_left', '.mat']).NumErrors_VL;

    Times_HR = load(['TotalTime_', participant,'_horizontal_right', '.mat']).Times_HR;
    ErrorTimes_HR = load(['ErrorTime_', participant, '_horizontal_right', '.mat']).ErrorTimes_HR;
    NumErrors_HR = load(['NumberOfErrors_', participant, '_horizontal_right', '.mat']).NumErrors_HR;

    %error percentage from time
    AllTowerTimes = Times_VR + Times_HL + Times_VL + Times_HR;
    AllTimes(:, :, pp) = AllTowerTimes;
    
    AllErrorTimes = ErrorTimes_VR + ErrorTimes_HL + ErrorTimes_VL + ErrorTimes_HR;

    if isempty(any(any(isnan(AllErrorTimes))))
        assert(all(all(AllErrorTimes <= AllTowerTimes)))
    end

    ErrorPercents = AllErrorTimes./AllTowerTimes;
    if any(any(ErrorPercents> 1)) 
        disp('bad')
        break
    end
    AllErrors(:, :, pp) = ErrorPercents;
    
    NumErrors(:, :, pp) = NumErrors_VR + NumErrors_HL + NumErrors_VL + NumErrors_HR;
    
end

find(isnan(AllTimes))

%% Preparing data for fitrm:
VariableNames = {'Shift1SessionA','Shift1SessionB','Shift1SessionC',...
'Shift2SessionA','Shift2SessionB','Shift2SessionC',...
'Shift3SessionA','Shift3SessionB','Shift3SessionC',...
'Shift4SessionA','Shift4SessionB','Shift4SessionC',...
'Shift5SessionA','Shift5SessionB','Shift5SessionC',...
'Shift6SessionA','Shift6SessionB','Shift6SessionC'};

PaperTable=[];
%% Time
MetricName = 'Completion Time';
TimeFlat = reshape(AllTimes, 18, length(AllParticipants)); %each column is a participant
TimeFlat = TimeFlat'; %each row is a participant
T = array2table(TimeFlat,'VariableNames',VariableNames); %each row is a participant
%log
T = log(T);

%Testing Normality 
h_Lilliefors = nan(size(VariableNames));
p_Lilliefors = nan(size(VariableNames));
T_Lillie = T((sum(isnan(table2array(T)')))==0,:);
for iCondition = 1:length(VariableNames)
    [h_Lilliefors(iCondition),p_Lilliefors(iCondition)] = lillietest(T_Lillie.(VariableNames{iCondition}));
end

cd(project_path)
Adjusted_Holm_p_Lilliefors = holm(p_Lilliefors, VariableNames, T, MetricName);

%Model
StatisticsTable2 = RM_Model(T);

AddToToPaperTable = cell(2,4);
AddToToPaperTable(1,4) = {MetricName};
for RowNum=1:3
    AddToToPaperTable(1:2,RowNum)={[num2str(StatisticsTable2.F(RowNum)),'(',num2str(StatisticsTable2.df1(RowNum)),',',num2str(StatisticsTable2.df2(RowNum)),')'];...
        num2str(StatisticsTable2.p(RowNum))};
end
PaperTable = [PaperTable;AddToToPaperTable];

%% Error percentage
MetricName = 'Error Percentage';
ErrorsFlat = reshape(AllErrors, 18, length(AllParticipants)); %each column is a participant
ErrorsFlat = ErrorsFlat'; %each row is a participant
T = array2table(ErrorsFlat,'VariableNames',VariableNames); %each row is a participant

%Testing Normality 
h_Lilliefors = nan(size(VariableNames));
p_Lilliefors = nan(size(VariableNames));
T_Lillie = T((sum(isnan(table2array(T)')))==0,:);
for iCondition = 1:length(VariableNames)
    [h_Lilliefors(iCondition),p_Lilliefors(iCondition)] = lillietest(T_Lillie.(VariableNames{iCondition}));
end

cd(project_path)
Adjusted_Holm_p_Lilliefors = holm(p_Lilliefors, VariableNames, T, MetricName);

%Model
StatisticsTable2 = RM_Model(T);

AddToToPaperTable = cell(2,4);
AddToToPaperTable(1,4) = {MetricName};
for RowNum=1:3
    AddToToPaperTable(1:2,RowNum)={[num2str(StatisticsTable2.F(RowNum)),'(',num2str(StatisticsTable2.df1(RowNum)),',',num2str(StatisticsTable2.df2(RowNum)),')'];...
        num2str(StatisticsTable2.p(RowNum))};
end
PaperTable = [PaperTable;AddToToPaperTable];

%% Num Errors
MetricName = 'Number of Errors';
NumErrorsFlat = reshape(NumErrors, 18, length(AllParticipants)); %each column is a participant
NumErrorsFlat = NumErrorsFlat'; %each row is a participant
T = array2table(NumErrorsFlat,'VariableNames',VariableNames); %each row is a participant

%log
T = log(T);

%Testing Normality 
h_Lilliefors = nan(size(VariableNames));
p_Lilliefors = nan(size(VariableNames));
T_Lillie = T((sum(isnan(table2array(T)')))==0,:);
for iCondition = 1:length(VariableNames)
    [h_Lilliefors(iCondition),p_Lilliefors(iCondition)] = lillietest(T_Lillie.(VariableNames{iCondition}));
end

cd(project_path)
Adjusted_Holm_p_Lilliefors = holm(p_Lilliefors, VariableNames, T, MetricName);

%Model
StatisticsTable2 = RM_Model(T);

AddToToPaperTable = cell(2,4);
AddToToPaperTable(1,4) = {MetricName};
for RowNum=1:3
    AddToToPaperTable(1:2,RowNum)={[num2str(StatisticsTable2.F(RowNum)),'(',num2str(StatisticsTable2.df1(RowNum)),',',num2str(StatisticsTable2.df2(RowNum)),')'];...
        num2str(StatisticsTable2.p(RowNum))};
end
PaperTable = [PaperTable;AddToToPaperTable];

PaperTable(strcmp(PaperTable,'0'))={'<0.001'};
writecell(PaperTable, fullfile(project_path,'PaperTable.csv'))
