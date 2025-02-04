%% This code judges the performance of the detection algorithm by comparing the algorithm results
% to any corrections made
%% Paths
project_path = "C:\Users\hanna\OneDrive\MATLAB\lab\PhD\ErrorPrediction";
MovesPath = fullfile(project_path, "AllMoves");
SegPath = fullfile(project_path, "AllSegmentations");
SegmentsPath = fullfile(project_path, "TowerSegments");

%% Creating Tables
AllParticipants = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'T', 'U'];
AllMonths = ['1', '2', '3', '4', '5', '6'];
AllTimes = ['a', 'b', 'c'];
Towers = {'vertical_right', 'horizontal_left', 'vertical_left', 'horizontal_right'};
vnames = {'Participant', 'Month', 'Session', 'Tower', 'TP', 'TN', 'FP', 'FN'};
SummaryTable = array2table(zeros(0,length(vnames)), 'VariableNames',vnames);

for pp = 1:length(AllParticipants)
    participant = AllParticipants(pp);
    disp(participant)

    for mm = 1:length(AllMonths)
        month = AllMonths(mm);

        for ttt = 1:length(AllTimes)
            tt = AllTimes(ttt);

            if (participant == 'D' && month == '3' && tt == 'b')
                continue
            end

            if (participant == 'N' && month == '5' && tt == 'a')
                continue
            end
            if (participant == 'N' && month == '5' && tt == 'b')
                continue
            end
            if (participant == 'N' && month == '6' && tt == 'a')
                continue
            end
            if (participant == 'N' && month == '6' && tt == 'b')
                continue
            end

            %loading segmentation
            cd(SegPath)
            segmentation = load(['subj_', participant, '_', month, '_', tt, '_Ringtowertransfer_Segmentation.mat']).Segmentation;

            if any(strcmp(segmentation.Event, 'Robot shut down')) %if there was a robot shut down
                ShutDowns = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Robot shut down')));
                Restarts = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Back to task')));

                ShutDownStamps = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Robot shut down')));
                RestartStamps = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Back to task')));
            else
                if exist('ShutDowns','var')
                    clearvars ShutDowns Restarts ShutDownStamps RestartStamps
                end

            end

            for i = 1:length(Towers)
                if i == 1 % vertical right
                    % frame numbers of relevant part of video
                    start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Right ring caught for the first time')));
                    end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Right ring outside the tower')));
                    tower = 'vertical_right';
                   
                elseif i == 2  % horizontal left
                    % frame numbers of relevant part of video
                    start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Start inserting ring to left bottom tower')));
                    end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Ring placed - Bottom left tower')));
                    tower = 'horizontal_left';
                    
                elseif i == 3  % vertical left
                    % frame numbers of relevant part of video
                    start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Left ring caught for the first time')));
                    end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Left ring outside the tower')));
                    tower = 'vertical_left';
                  
                else % i=4, horizontal right
                    % frame numbers of relevant part of video
                    start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Start inserting ring to right bottom tower')));
                    end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Finish Task')));
                    tower = 'horizontal_right';
                   
                end %end of setting up tower parameters

                if length(start_ind) > 1
                    start_ind = start_ind(1);
                end
                if length(end_ind) > 1
                    end_ind = end_ind(end);
                end


                % Loading data
                cd(MovesPath)
                Moves = load(['MovesUpdated_', participant, '_', month, '_', tt, '_', tower, '.mat']).data;
                MovesFixed = load(['MovesFixed_', participant, '_', month, '_', tt, '_', tower, '.mat']).Moves;
                assert(length(Moves) == length(MovesFixed));

                if contains(tower, 'horizontal')
                    cd(SegmentsPath)
                    Segments = load(['TowerSegmentsFixed_', participant, '_', month, '_', tt, '_', tower, '.mat']).Segments;

                    assert(length(Segments) == length(MovesFixed));
                    notones = find(Segments ~= 1);

                else
                    notones = 1:length(Moves)';
                end


                if exist('ShutDowns','var')
                    if (any(ShutDowns > start_ind) && any(ShutDowns < end_ind))
                        %then it might be in this tower.
                        % Otherwise it happened before / after this tower
                        ind = intersect(find(ShutDowns > start_ind), find(ShutDowns < end_ind));
                        if Restarts(ind) < end_ind
                            warning(['shut down ', participant, month, tt, ' ', tower])
                            shutdowninds = ShutDowns(ind):Restarts(ind);

                            rm = shutdowninds - start_ind + 1;
                            keep = setdiff(1:length(Moves), rm)';
                           
                        else
                            keep = [1:length(Moves)]';
                        end
                    else
                        keep = [1:length(Moves)]';
                    end
                else
                    keep = [1:length(Moves)]';
                end

                allkeep = intersect(notones, keep);

                Moves = Moves(allkeep);
                MovesFixed = MovesFixed(allkeep);


                %Fixed is true labels
                true1 = find(MovesFixed == 1);
                true0 = find(MovesFixed == 0);

                %The algorithm results
                pred1 = find(Moves == 1);
                pred0 = find(Moves == 0);

                TP = length(intersect(true1, pred1));
                TN = length(intersect(true0, pred0));
                FP = length(intersect(pred1, true0));
                FN = length(intersect(pred0, true1));

                assert(TP + FN == length(true1))
                assert(TN + FP == length(true0))



                SummaryTable = [SummaryTable; {{0}, {0}, {0}, {0}, 0, 0, 0, 0}];
                SummaryTable(height(SummaryTable), 1) = {participant};
                SummaryTable(height(SummaryTable), 2) = {month};
                SummaryTable(height(SummaryTable), 3) = {tt};
                SummaryTable(height(SummaryTable), 4) = {tower};
                SummaryTable(height(SummaryTable), 5) = array2table(TP);
                SummaryTable(height(SummaryTable), 6) = array2table(TN);
                SummaryTable(height(SummaryTable), 7) = array2table(FP);
                SummaryTable(height(SummaryTable), 8) = array2table(FN);


            end

        end
    end
end

%% Metrics
TP = table2array(sum(SummaryTable(:, 'TP')));
TN = table2array(sum(SummaryTable(:, 'TN')));
FP = table2array(sum(SummaryTable(:, 'FP')));
FN = table2array(sum(SummaryTable(:, 'FN')));

Acc = (TP + TN) / (TP + TN + FP + FN);
TPR = TP / (TP + FN);
TNR = TN / (TN + FP);

F1 = 2*TP / (2*TP + FP + FN);