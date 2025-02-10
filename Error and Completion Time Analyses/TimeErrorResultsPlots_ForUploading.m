%% This code uses the computed number of error, error percentage and task completion time to plot the results
project_path = "C:\Users\hanna\OneDrive\MATLAB\lab\PhD\ErrorPrediction";
SavePath = fullfile(project_path, "TimeAccuracy");

AllParticipants = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'T', 'U'];

AllTimes = zeros(3, 6, 18);
AllErrors = zeros(3, 6, 18);
NumErrors = zeros(3, 6, 18);

for pp = 1:length(AllParticipants)
    participant = AllParticipants(pp);

    cd(SavePath)
    Times_VR = load(['TotalTimeUpdated3_', participant, '_vertical_right', '.mat']).Times_VR;
    ErrorTimes_VR = load(['ErrorTimeUpdated3_', participant, '_vertical_right', '.mat']).ErrorTimes_VR;
    NumErrors_VR = load(['NumberOfErrorsUpdated3_', participant, '_vertical_right', '.mat']).NumErrors_VR;

    Times_HL = load(['TotalTimeUpdated3_', participant, '_horizontal_left', '.mat']).Times_HL;
    ErrorTimes_HL = load(['ErrorTimeUpdated3_', participant, '_horizontal_left', '.mat']).ErrorTimes_HL;
    NumErrors_HL = load(['NumberOfErrorsUpdated3_', participant, '_horizontal_left', '.mat']).NumErrors_HL;

    Times_VL = load(['TotalTimeUpdated3_', participant, '_vertical_left', '.mat']).Times_VL;
    ErrorTimes_VL = load(['ErrorTimeUpdated3_', participant, '_vertical_left', '.mat']).ErrorTimes_VL;
    NumErrors_VL = load(['NumberOfErrorsUpdated3_', participant, '_vertical_left', '.mat']).NumErrors_VL;

    Times_HR = load(['TotalTimeUpdated3_', participant,'_horizontal_right', '.mat']).Times_HR;
    ErrorTimes_HR = load(['ErrorTimeUpdated3_', participant, '_horizontal_right', '.mat']).ErrorTimes_HR;
    NumErrors_HR = load(['NumberOfErrorsUpdated3_', participant, '_horizontal_right', '.mat']).NumErrors_HR;

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
%% Plotting
color1=brighten([132, 15, 115]/255,-0.5);
%% All 18 meetings - Time
Data = AllTimes;
Reshaped = reshape(Data, 18, 18)';
CIs = bootci(2000, @nanmean, Reshaped);
Stages = {1:3,4:6,7:9,10:12,13:15,16:18};
fig = figure;
hold on

for ii = 1:6
    x = [Stages{ii} fliplr(Stages{ii})];
    h1 = fill(x,[CIs(1,Stages{ii}),fliplr(CIs(2,Stages{ii}))],'r','facealpha',0.4,'linestyle','none');
    set(h1,'facecolor',color1);
    p1a = plot(Stages{ii}, Reshaped(:,Stages{ii}),'-','color',[color1, 0.25]);
    p1 = plot(Stages{ii}, nanmean(Reshaped(:, Stages{ii})),'color',color1,'LineWidth',5);
end

Ylim = get(gca,'ylim');
ylim([Ylim(1),Ylim(2)+0.10*(Ylim(2)-Ylim(1))]);
NewYlim = get(gca,'ylim');
TextSize = 17;
text(2,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 1','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(5,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 2','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(8,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 3','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(11,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 4','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(14,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 5','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(17,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 6','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')

Ylim = NewYlim;
h = plot([3.5 3.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([6.5 6.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([9.5 9.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([12.5 12.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([15.5 15.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
xlim([1 18]);
xticks(1:1:18)
set(gca, 'FontSize', TextSize, 'FontName', 'Times New Roman')
xlabel('Trial Number', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Completion Time [sec]', 'FontSize', 20, 'FontName', 'Times New Roman')
fig.Position = ([200 200 800 450]);

box on
%% All 18 meetings - Error
Data = 100.*AllErrors;
Reshaped = reshape(Data, 18, 18)';
CIs = bootci(2000, @nanmean, Reshaped);
Stages = {1:3,4:6,7:9,10:12,13:15,16:18};
fig = figure;

hold on

for ii = 1:6
    x = [Stages{ii} fliplr(Stages{ii})];
    h1 = fill(x,[CIs(1,Stages{ii}),fliplr(CIs(2,Stages{ii}))],'r','facealpha',0.4,'linestyle','none');
    set(h1,'facecolor',color1);
    p1a = plot(Stages{ii}, Reshaped(:,Stages{ii}),'-','color',[color1, 0.25]);
    p1 = plot(Stages{ii}, nanmean(Reshaped(:, Stages{ii})),'color',color1,'LineWidth',5);
end

Ylim = get(gca,'ylim');
ylim([0,Ylim(2)+0.10*(Ylim(2)-Ylim(1))]);
NewYlim = get(gca,'ylim');
TextSize = 17;
text(2,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 1','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(5,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 2','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(8,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 3','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(11,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 4','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(14,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 5','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(17,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 6','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')

Ylim = NewYlim;
h = plot([3.5 3.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([6.5 6.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([9.5 9.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([12.5 12.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([15.5 15.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
xlim([1 18]);
xticks(1:1:18)
set(gca, 'FontSize', TextSize, 'FontName', 'Times New Roman')
xlabel('Trial Number', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Error Percentage [%]', 'FontSize', 20, 'FontName', 'Times New Roman')
fig.Position = ([200 200 800 450]);
box on

%% All 18 meetings - Num Errors
Data = NumErrors;
Reshaped = reshape(Data, 18, 18)';
CIs = bootci(2000, @nanmean, Reshaped);
Stages = {1:3,4:6,7:9,10:12,13:15,16:18};
fig = figure;
hold on

for ii = 1:6
    x = [Stages{ii} fliplr(Stages{ii})];
    h1 = fill(x,[CIs(1,Stages{ii}),fliplr(CIs(2,Stages{ii}))],'r','facealpha',0.4,'linestyle','none');
    set(h1,'facecolor',color1);
    p1a = plot(Stages{ii}, Reshaped(:,Stages{ii}),'-','color',[color1, 0.25]);
    p1 = plot(Stages{ii}, nanmean(Reshaped(:, Stages{ii})),'color',color1,'LineWidth',5);
end

Ylim = get(gca,'ylim');
ylim([0,Ylim(2)+0.10*(Ylim(2)-Ylim(1))]);
NewYlim = get(gca,'ylim');
TextSize = 17;
text(2,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 1','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(5,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 2','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(8,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 3','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(11,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 4','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(14,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 5','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')
text(17,Ylim(2)+(NewYlim(2)-Ylim(2))/2,'Shift 6','HorizontalAlignment', 'center','FontSize',TextSize, 'FontName', 'Times New Roman')

Ylim = NewYlim;
h = plot([3.5 3.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([6.5 6.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([9.5 9.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([12.5 12.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = plot([15.5 15.5],Ylim,'--', 'LineWidth', 1.0,'Color', [0.5 0.5 0.5]);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
xlim([1 18]);
xticks(1:1:18)
set(gca, 'FontSize', TextSize, 'FontName', 'Times New Roman')
xlabel('Trial Number', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Number of Errors', 'FontSize', 20, 'FontName', 'Times New Roman')
fig.Position = ([200 200 800 450]);
box on


%% Averaged, by month - Time
Data = AllTimes;
Averaged = nanmean(Data, 3);

cm = [169, 209, 142; 84, 130, 53; 56, 87, 35]./255;

fig = figure;
hold on
for i = 1:size(Averaged, 1)
    plot(Averaged(i, :), '-s', 'color', cm(i, :), 'markerfacecolor', cm(i, :), 'markersize', 8)
end
legend('Before Shift', 'During Shift', 'After Shift')
set(gca, 'FontSize', 17, 'FontName', 'Times New Roman')
xlabel('Shift Number', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Completion Time [sec]', 'FontSize', 20, 'FontName', 'Times New Roman')
fig.Position = ([200 200 450 450]);

%% Averaged, by month - Error
Data = 100.*AllErrors;
Averaged = nanmean(Data, 3);

cm = [169, 209, 142; 84, 130, 53; 56, 87, 35]./255;

fig = figure;
hold on
for i = 1:size(Averaged, 1)
    plot(Averaged(i, :), '-s', 'color', cm(i, :), 'markerfacecolor', cm(i, :), 'markersize', 8)
end
% legend('Before Shift', 'During Shift', 'After Shift')
set(gca, 'FontSize', 17, 'FontName', 'Times New Roman')
xlabel('Shift Number', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Error Percentage [%]', 'FontSize', 20, 'FontName', 'Times New Roman')
ylim([0, 100])
fig.Position = ([200 200 450 450]);

%% Averaged, by month - Num Errors
Data = NumErrors;
Averaged = nanmean(Data, 3);

cm = [169, 209, 142; 84, 130, 53; 56, 87, 35]./255;

fig = figure;
hold on
for i = 1:size(Averaged, 1)
    plot(Averaged(i, :), '-s', 'color', cm(i, :), 'markerfacecolor', cm(i, :), 'markersize', 8)
end
% legend('Before Shift', 'During Shift', 'After Shift')
ylim([9, 20])
set(gca, 'FontSize', 17, 'FontName', 'Times New Roman')
xlabel('Shift Number', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Number of Errors', 'FontSize', 20, 'FontName', 'Times New Roman')
fig.Position = ([200 200 450 450]);


%% Averaged, by shift - Time
Data = AllTimes;
Averaged = nanmean(Data, 3);

cm = [189, 215, 238; 148, 190, 228; 105, 164, 217; 50, 129, 200; 40, 103, 160; 20, 51, 80]./255;

fig = figure;
hold on
for i = 1:size(Averaged, 2)
    plot(Averaged(:, i), '-s', 'color', cm(i, :), 'markerfacecolor', cm(i, :), 'markersize', 8)
end
lgd = legend('1', '2', '3', '4', '5', '6');
lgd.Title.String = 'Shift Number';
lgd.Title.FontSize = 11;
lgd.FontSize = 11;
% lgd.EdgeColor = [1 1 1];

set(gca, 'FontSize', 17, 'FontName', 'Times New Roman')

xticks(1:1:3)
xticklabels({'Before', 'During', 'After'})
ylabel('Completion Time [sec]', 'FontSize', 20, 'FontName', 'Times New Roman')
xlabel('Shift', 'FontSize', 20, 'FontName', 'Times New Roman')
fig.Position = ([200 200 450 450]);

%% Averaged, by shift - Error
Data = 100.*AllErrors;
Averaged = nanmean(Data, 3);

cm = [189, 215, 238; 148, 190, 228; 105, 164, 217; 50, 129, 200; 40, 103, 160; 20, 51, 80]./255;

fig = figure;
hold on
for i = 1:size(Averaged, 2)
    plot(Averaged(:, i), '-s', 'color', cm(i, :), 'markerfacecolor', cm(i, :), 'markersize', 8)
end
% lgd = legend('1', '2', '3', '4', '5', '6');
% lgd.Title.String = 'Shift Number';
% lgd.Title.FontSize = 10;
% lgd.EdgeColor = [1 1 1];
set(gca, 'FontSize', 17, 'FontName', 'Times New Roman')
xticks(1:1:3)
xticklabels({'Before', 'During', 'After'})
xlabel('Shift', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Error Percentage [%]', 'FontSize', 20, 'FontName', 'Times New Roman')
ylim([0, 100])
fig.Position = ([200 200 450 450]);

%% Averaged, by shift - Num Errors
Data = NumErrors;
Averaged = nanmean(Data, 3);

cm = [189, 215, 238; 148, 190, 228; 105, 164, 217; 50, 129, 200; 40, 103, 160; 20, 51, 80]./255;

fig = figure;
hold on
for i = 1:size(Averaged, 2)
    plot(Averaged(:, i), '-s', 'color', cm(i, :), 'markerfacecolor', cm(i, :), 'markersize', 8)
end
% lgd = legend('1', '2', '3', '4', '5', '6');
% lgd.Title.String = 'Shift Number';
% lgd.Title.FontSize = 10;
% lgd.EdgeColor = [1 1 1];
set(gca, 'FontSize', 17, 'FontName', 'Times New Roman')
xticks(1:1:3)
xticklabels({'Before', 'During', 'After'})
xlabel('Shift', 'FontSize', 20, 'FontName', 'Times New Roman')
ylabel('Number of Errors', 'FontSize', 20, 'FontName', 'Times New Roman')
ylim([9, 20])
fig.Position = ([200 200 450 450]);

%% Time - error plot
TimeFlat = reshape(AllTimes, 18, 18); %each column is a participant in order - each row in the column is the 18 visits
ErrorFlat = 100.*reshape(AllErrors, 18, 18); %each column is a participant in order - each row in the column is the 18 visits
c = winter(18);
c = flipud(c);

s = {'o', '+', '*', '.', 'x', '_', '|', 'square', 'diamond', '^', '<', 'v', '>', 'pentagram', 'hexagram'};
s2 = {'o', 'square', 'diamond'};


%average across participants
timemean = nanmean(TimeFlat, 2);
errmean = nanmean(ErrorFlat, 2);
fig = figure;
ax = axes(fig); 
hold on
for i = 1 : 18
    plot(timemean(i), errmean(i), 'marker', 'square', 'MarkerEdgeColor', c(i, :), 'MarkerFaceColor', c(i, :), 'markersize', 12)
end
plot(timemean, errmean, 'color', 'k', 'linewidth', 0.5)
set(gca, 'fontsize', 14, 'fontname', 'Times New Roman')
xlabel('Completion Time [sec]', 'fontsize', 16)
ylabel('Error Percentage [%]', 'fontsize', 16)
xlim([30 120])
ylim([50 80])

axis square

colormap(ax, c); % Set colormap for the Axes to match your color scheme
cb = colorbar(ax); % Attach colorbar to the Axes
cb.Ticks = linspace(0, 1, 2); % Set ticks on the colorbar
cb.TickLabels = arrayfun(@num2str, [1, 18], 'UniformOutput', false); % Label each tick
sz = fig.Position ;


%first and last 
fig2 = figure;
hold on
for p = 1 : length(s)
    for i = [1 , 18]
        plot(TimeFlat(i, p), ErrorFlat(i, p), 'marker', s{p}, 'MarkerEdgeColor', c(i, :))      
    end
    plot(TimeFlat([1 , 18], p), ErrorFlat([1 , 18], p), 'color', 'k', 'linewidth', 0.5)      
end

for p = (length(s) + 1) : 18
    for i = [1 , 18]
        if p == (length(s) + 2)
            if i == 1
                p1 = plot(TimeFlat(i, p), ErrorFlat(i, p), 'marker', s2{p - length(s)}, 'MarkerEdgeColor', c(i, :), 'MarkerFaceColor', c(i, :), 'LineStyle', 'none');
            else
                p2 = plot(TimeFlat(i, p), ErrorFlat(i, p), 'marker', s2{p - length(s)}, 'MarkerEdgeColor', c(i, :), 'MarkerFaceColor', c(i, :), 'LineStyle', 'none');
            end
        else
            plot(TimeFlat(i, p), ErrorFlat(i, p), 'marker', s2{p - length(s)}, 'MarkerEdgeColor', c(i, :), 'MarkerFaceColor', c(i, :))
        end
    end
    plot(TimeFlat([1 , 18], p), ErrorFlat([1 , 18], p), 'color', 'k', 'linewidth', 0.5)
end

%checking how many got worse in error
worse = zeros(1, 18);
for p = 1 : 18
    if ErrorFlat(18, p) >= ErrorFlat(1, p)
        worse(p) = 1;
    end
end
sum(worse)

set(gca, 'fontsize', 14, 'fontname', 'Times New Roman')
xlabel('Completion Time [sec]', 'fontsize', 16)
ylabel('Error Percentage [%]', 'fontsize', 16)

% Set new limits to make the range equal on both axes
ylim([0, 100]);


axis square

%finding line to seperate them
%linear
X = [TimeFlat(1, :)', ErrorFlat(1, :)'; TimeFlat(end, :)', ErrorFlat(end, :)'];
Y = [ones(18,1); -ones(18,1)]; 

%or polynomial
svmModel = fitcsvm(X, Y, 'KernelFunction', 'polynomial', 'PolynomialOrder', 2);

[x1Grid, x2Grid] = meshgrid(linspace(0, xRange, 100), ...
                            linspace(0, xRange, 100));
[~, score] = predict(svmModel, [x1Grid(:), x2Grid(:)]);
decisionBoundary = reshape(score(:,1), size(x1Grid));


[~, p3] = contour(x1Grid, x2Grid, decisionBoundary, [0 0], 'color', [0.6 0.6 0.6], 'LineWidth', 0.5);
legend([p1, p2, p3], {'1', '18', 'Polynomial Boundary'})
fig2.Position = sz ;