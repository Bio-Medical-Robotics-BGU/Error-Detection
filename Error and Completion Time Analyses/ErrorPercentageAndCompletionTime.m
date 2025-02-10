%% This code computes the percentage of errors and the total time for each tower and each participant

%replace the following line with the directories to the saved videos and
%segmentation
project_path = "C:\Users\hanna\OneDrive\MATLAB\lab\PhD\ErrorPrediction";

SegPath = fullfile(project_path, "AllSegmentations");
MatPath = fullfile(project_path, "AllMatFiles");

MovesPath = fullfile(project_path, "AllMoves");
SegmentsPath = fullfile(project_path, "TowerSegments");

SavePath = fullfile(project_path, "TimeAccuracy");

AllParticipants = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'T', 'U'];
AllMonths = ['1', '2', '3', '4', '5', '6'];
AllTimes = ['a', 'b', 'c'];

%%
cd(project_path)
for pp = 1:length(AllParticipants)
    participant = AllParticipants(pp);
    disp(participant)

    ErrorTimes_VR = nan(3, 6);
    ErrorTimes_HL = nan(3, 6);
    ErrorTimes_VL = nan(3, 6);
    ErrorTimes_HR = nan(3, 6);

    ErrorStamps_VR = nan(3, 6);
    ErrorStamps_HL = nan(3, 6);
    ErrorStamps_VL = nan(3, 6);
    ErrorStamps_HR = nan(3, 6);

    Times_VR = nan(3, 6);
    Times_HL = nan(3, 6);
    Times_VL = nan(3, 6);
    Times_HR = nan(3, 6);

    Stamps_VR = nan(3, 6);
    Stamps_HL = nan(3, 6);
    Stamps_VL = nan(3, 6);
    Stamps_HR = nan(3, 6);

    NumErrors_VR = nan(3, 6);
    NumErrors_HL = nan(3, 6);
    NumErrors_VL = nan(3, 6);
    NumErrors_HR = nan(3, 6);

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

            try

                % 1. loading segmentation
                cd(SegPath)
                segmentation = load(['subj_', participant, '_', month, '_', tt, '_Ringtowertransfer_Segmentation.mat']).Segmentation;

                cd(MatPath)
                VidTimeStamps = load(['subj_', participant, '_', month, '_', tt, '_Ringtowertransfer.mat']).D.VideoTimeStamps;

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

                % 4. Run over the four towers
                for i = 1:4

                    % Tower Parameters
                    if i == 1 % vertical right
                        % frame numbers of relevant part of video
                        start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Right ring caught for the first time')));
                        end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Right ring outside the tower')));
                        tower = 'vertical_right';
                        start_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Right ring caught for the first time')));
                        end_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Right ring outside the tower')));

                    elseif i == 2  % horizontal left
                        % frame numbers of relevant part of video
                        start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Start inserting ring to left bottom tower')));
                        end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Ring placed - Bottom left tower')));
                        tower = 'horizontal_left';
                        start_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Start inserting ring to left bottom tower')));
                        end_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Ring placed - Bottom left tower')));

                    elseif i == 3  % vertical left
                        % frame numbers of relevant part of video
                        start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Left ring caught for the first time')));
                        end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Left ring outside the tower')));
                        tower = 'vertical_left';
                        start_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Left ring caught for the first time')));
                        end_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Left ring outside the tower')));

                    else % i=4, horizontal right
                        % frame numbers of relevant part of video
                        start_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Start inserting ring to right bottom tower')));
                        end_ind = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Finish Task')));
                        tower = 'horizontal_right';
                        start_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Start inserting ring to right bottom tower')));
                        end_stamp = segmentation.TimeStamp(find(strcmp(segmentation.Event, 'Finish Task')));

                    end %end of setting up tower parameters

                    if length(start_ind) > 1
                        start_ind = start_ind(1);
                        start_stamp = start_stamp(1);
                    end
                    if length(end_ind) > 1
                        end_ind = end_ind(end);
                        end_stamp = end_stamp(end);
                    end

                    %loading moves and segments
                    cd(MovesPath)
                    Moves = load(['MovesFixed_', participant, '_', month, '_', tt, '_', tower, '.mat']).Moves;

                    %computing total time
                    TotalStamps = length(Moves);
                    assert (length(Moves) == (end_ind - start_ind + 1))
                    %compute time from timestamps
                    TotalTime = end_stamp - start_stamp;

                    %computing error length
                    ErrorStamps = sum(Moves);

                    %computing error time by finding the timestamps of the
                    %begining and end of each detected move. To do this,
                    %first detect each seperate move. Then, take the
                    %timestamps for each.
                    ErrorTime = 0;
                    [L1, n1] = bwlabel(Moves);
                    for j = 1:n1
                        ThisError = find(L1 == j);
                        first = ThisError(1);
                        last = ThisError(end);
                        ErrorTime = ErrorTime + (VidTimeStamps(last + start_ind - 1) - VidTimeStamps(first + start_ind - 1));
                    end

                    %number of errors
                    NumErrors = n1;


                    if exist('ShutDowns','var')
                        if (any(ShutDowns > start_ind) && any(ShutDowns < end_ind))
                            %then it might be in this tower.
                            % Otherwise it happened before / after this tower
                            ind = intersect(find(ShutDowns > start_ind), find(ShutDowns < end_ind));
                            if Restarts(ind) < end_ind
                                warning(['shut down ', participant, month, tt, ' ', tower])
                                shutdowninds = ShutDowns(ind):Restarts(ind);

                                TotalStamps = TotalStamps - length(shutdowninds);
                                TotalTime = TotalTime - (RestartStamps(ind) - ShutDownStamps(ind));

                                ErrorStamps = ErrorStamps - sum(Moves(shutdowninds - start_ind + 1));
                                ErrorTime = ErrorTime - (RestartStamps(ind) - ShutDownStamps(ind));
                                if (sum(Moves(shutdowninds - start_ind + 1)) ~= length(shutdowninds))
                                    warning(['shut down not all detected errors ', participant, month, tt, ' ', tower])
                                end

                            end
                        end
                    end

                    if (NumErrors < 0)
                        warning(['Negative number of errors ', participant, month, tt, ' ', tower])
                    end


                    if i == 1 % vertical right
                        ErrorTimes_VR(ttt, mm) = ErrorTime;
                        Times_VR(ttt, mm) = TotalTime;
                        Stamps_VR(ttt, mm) = TotalStamps;
                        ErrorStamps_VR(ttt, mm) = ErrorStamps;
                        NumErrors_VR(ttt, mm) = NumErrors;

                    elseif i == 2  % horizontal left
                        ErrorTimes_HL(ttt, mm) = ErrorTime;
                        Times_HL(ttt, mm) = TotalTime;
                        Stamps_HL(ttt, mm) = TotalStamps;
                        ErrorStamps_HL(ttt, mm) = ErrorStamps;
                        NumErrors_HL(ttt, mm) = NumErrors;

                    elseif i == 3  % vertical left
                        ErrorTimes_VL(ttt, mm) = ErrorTime;
                        Times_VL(ttt, mm) = TotalTime;
                        Stamps_VL(ttt, mm) = TotalStamps;
                        ErrorStamps_VL(ttt, mm) = ErrorStamps;
                        NumErrors_VL(ttt, mm) = NumErrors;

                    else % i=4, horizontal right
                        ErrorTimes_HR(ttt, mm) = ErrorTime;
                        Times_HR(ttt, mm) = TotalTime;
                        Stamps_HR(ttt, mm) = TotalStamps;
                        ErrorStamps_HR(ttt, mm) = ErrorStamps;
                        NumErrors_HR(ttt, mm) = NumErrors;


                    end %end of saving


                end %end of running over 4 towers
            catch
                warning(['NaNs ', participant, month, tt])
                continue

            end


        end %end of running on participant's 3 sessions

    end %end of running on participant's 6 months
    cd(SavePath)
    save(['ErrorTime_', participant, '_vertical_right'], 'ErrorTimes_VR');
    save(['TotalTime_', participant, '_vertical_right'], 'Times_VR');
    save(['TotalStamps_', participant, '_vertical_right'], 'Stamps_VR');
    save(['ErrorStamps_', participant, '_vertical_right'], 'ErrorStamps_VR');
    save(['NumberOfErrors_', participant, '_vertical_right'], 'NumErrors_VR');

    save(['ErrorTime_', participant, '_horizontal_left'], 'ErrorTimes_HL');
    save(['TotalTime_', participant, '_horizontal_left'], 'Times_HL');
    save(['TotalStamps_', participant, '_horizontal_left'], 'Stamps_HL');
    save(['ErrorStamps_', participant, '_horizontal_left'], 'ErrorStamps_HL');
    save(['NumberOfErrors_', participant, '_horizontal_left'], 'NumErrors_HL');

    save(['ErrorTime_', participant, '_vertical_left'], 'ErrorTimes_VL');
    save(['TotalTime_', participant, '_vertical_left'], 'Times_VL');
    save(['TotalStamps_', participant, '_vertical_left'], 'Stamps_VL');
    save(['ErrorStamps_', participant, '_vertical_left'], 'ErrorStamps_VL');
    save(['NumberOfErrors_', participant, '_vertical_left'], 'NumErrors_VL');

    save(['ErrorTime_', participant, '_horizontal_right'], 'ErrorTimes_HR');
    save(['TotalTime_', participant,'_horizontal_right'], 'Times_HR');
    save(['TotalStamps_', participant, '_horizontal_right'], 'Stamps_HR');
    save(['ErrorStamps_', participant, '_horizontal_right'], 'ErrorStamps_HR');
    save(['NumberOfErrors_', participant, '_horizontal_right'], 'NumErrors_HR');

end %end of running on all participants


