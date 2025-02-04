%% This is the main detection code.

%replace the following line with the directories to the saved videos and
%segmentation
project_path = "D:\OneDrive\MATLAB\lab\PhD\ErrorPrediction";

BagPath = fullfile(project_path, "CamBags");
SegPath = fullfile(project_path, "AllSegmentations");

VelSavePath = fullfile(project_path, "TowerVels");
MovesSavePath = fullfile(project_path, "AllMoves");
KinSavePath = fullfile(project_path, "TowerKinematics");
RingSavePath = fullfile(project_path, "RingLocations");
SegmentsSavePath = fullfile(project_path, "TowerSegments");
VideoSavePath = fullfile(project_path, "ResultVideos");

AllParticipants = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U'];
AllMonths = ['1', '2', '3', '4', '5', '6']; 
AllTimes = ['a', 'b', 'c'];

%%
parfor pp = 1:length(AllParticipants)
    participant = AllParticipants(pp);

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
            
            
            %for logging warnings:
            cd(project_path)
            diaryname = ['WarningLog', participant, month, tt];
            diary(diaryname)

            disp(['subj_', participant, '_', month, '_', tt, ': Start'])
            tic

            % 1. loading segmentation
            cd(SegPath)
            segmentation = load(['subj_', participant, '_', month, '_', tt, '_Ringtowertransfer_Segmentation.mat']);
            segmentation = segmentation.Segmentation;

            if any(diff(segmentation.TimeStamp)<0) %if the order is not ascending
                warning(['Segmentation order not as expected: ', participant, month, tt])
            end

            % 2. loading Cam RosBag
            cd(BagPath)
            bag = rosbag(['subj_', participant, '_', month, '_', tt, '_Ringtowertransfer_CAM.bag']);%loading bag file with compressed images
            bagSelection =  select(bag, 'Topic','/image_view_left/output/compressed');
            allMsgs = readMessages(bagSelection);
            t = bagSelection.MessageList.Time;
            
            disp('all loaded')
            
            %3. creating a temporary folder for the images:
            TempDirPath =  fullfile(project_path, ['TempImageFolder', participant, '_', month, '_', tt]);
            mkdir(TempDirPath);

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
                      
                
%                 if isfile(fullfile(VideoSavePath, ['DetectedErrorsUpdated_RingSegments_', participant, month, tt, '_', tower, '.mp4.avi']))
%                     continue
%                 end
                                
                %creating optical flow object
                opticFlow = opticalFlowHS;

                %saving velocities and detected tower size
                Vels = zeros(length(start_ind:end_ind), 1);
                NumPixels = zeros(length(start_ind:end_ind), 1);
                RingCentroids = zeros(length(start_ind:end_ind), 2);
                TowerSegments = zeros(length(start_ind:end_ind), 1);

                TextPosition = [1,1]; %For the information presented on each frame
                box_color = "white";
                
                disp('Starting to run over images')

                % 5. run over tower frames
                for FrameNum = start_ind:end_ind
                    try
                        frameRGB = readImage(allMsgs{FrameNum});

                        text_str = [ 'Time: ' num2str(t(FrameNum) - t(start_ind)) ' [sec], Sample #' num2str(FrameNum)];

                        frameRGB = insertText(frameRGB,TextPosition,text_str,'FontSize',22,...
                            'BoxColor','white', ...
                            'TextColor','Black');

                        %saving image to temporary folder for making the
                        %movie after in which the results of this code will
                        %be displayed

                        imwrite(frameRGB, fullfile(TempDirPath, sprintf('%06d.png', FrameNum)));

                        % a. take the magnitudes the flow is for the whole image
                        frameGray = rgb2gray(frameRGB);
                        flow = estimateFlow(opticFlow,frameGray);

                        % b. find relevant indices
                        cd(project_path)
                        tower_inds = FindTower(frameRGB, tower);

                        % c. taking magnitudes in relevant indices for the tower
                        tower_flows = flow.Magnitude(tower_inds);

                        Vels(FrameNum - start_ind + 1) = sum(tower_flows);
                        NumPixels(FrameNum - start_ind + 1) = length(tower_inds);

                        % d. find ring in image / create ring location
                        % vector
                        cd(project_path)
                        [~, centroid] = FindRing(frameRGB, tower_inds, tower);
                        RingCentroids(FrameNum - start_ind + 1, :) = [centroid(1), centroid(2)];

                        % e. Identify semgnet of tower
                        cd(project_path)
                        TowerSegments(FrameNum - start_ind + 1) = TowerSegment([centroid(1), centroid(2)], tower);

                    catch
                        warning(['subj_', participant, '_', month, '_', tt, ': Image number ' num2str(FrameNum) ' has a problem'])
                    end
                end %end of this tower's frames

                cd(VelSavePath)
                parsave(['SumVels_', participant, '_', month, '_', tt, '_', tower], Vels)
                parsave(['NumPixels_', participant, '_', month, '_', tt, '_', tower], NumPixels)

                cd(RingSavePath)
                parsave(['RingCentroids_', participant, '_', month, '_', tt, '_', tower], RingCentroids)

                % 6. Find movements of tower i
                cd(project_path)
                Moves = FindErrorsFromVels(Vels);
                
                % If there are robot shutdowns - making all those samples
                % be errors
                if any(strcmp(segmentation.Event, 'Robot shut down')) %if there was a robot shut down
                    
                    ShutDowns = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Robot shut down')));
                    Restarts = segmentation.VideoFrameNumber(find(strcmp(segmentation.Event, 'Back to task')));
                    
                    %if the shutdown was in this tower
                    if ((ShutDowns >= start_ind) && (Restarts <= end_ind))
                        Moves(ShutDowns - start_ind + 1 : Restarts - start_ind + 1) = 1;
                        disp(['There was a shut down in ', participant, '_', month, '_', tt, '_', tower])
                    end
                    
                end
                
                %if there is a move near the end -> until the end (ONLY IN
                %VERTICAL TOWERS)
                if contains(tower, 'vertical')
                    DiffMoves = diff(Moves);
                    MoveEnds = find(DiffMoves == -1);
                    if sum(Moves(end - 10 : end)) > 0
                        Moves(MoveEnds(end) : end) = 1;
                    end
                end
                
                cd(MovesSavePath)
                parsave(['MovesUpdated_', participant, '_', month, '_', tt, '_', tower], Moves)
                
                

                % 7. Find ring location tower segment
                cd(project_path)
                try
                    FinalSegments = CleanSegments(TowerSegments, tower);
                    if ~isempty(setdiff(unique(FinalSegments), [1, 2, 3, 4]))
                        warning(['subj_', participant, '_', month, '_', tt, '_', tower, ':Tower segments has a problem'])
                    end
                    cd(SegmentsSavePath)
                    parsave(['TowerSegments_', participant, '_', month, '_', tt, '_', tower], FinalSegments)
                    
                catch
                    disp(['Error in ', participant, '_', month, '_', tt, '_', tower])
                    break
                end
               
                % 8. Create video for displaying results:
                % This video colors the tower red when a movement is
                % detected.
                % The ring switches color based on the detected tower
                % segment

                % 9. run over tower frames
                
                disp('starting to create video')
                % creating video object for displaying results
                video = VideoWriter(fullfile(VideoSavePath, ['DetectedErrorsUpdated_RingSegments_', participant, month, tt, '_', tower, '.mp4'])); %create the video object
                open(video); %open the file for writing
                
                for FrameNum = start_ind:end_ind
                    cd(TempDirPath)
                    frameRGB = imread(sprintf('%06d.png', FrameNum));

                    r2 = frameRGB(:, :, 1);
                    g2 = frameRGB(:, :, 2);
                    b2 = frameRGB(:, :, 3);

                     cd(project_path)
                     tower_inds = FindTower(frameRGB, tower);

                    if Moves(FrameNum - start_ind + 1) == 1
                        r2(tower_inds) = 255;
                        g2(tower_inds) = 0;
                        b2(tower_inds) = 0;
                    end
                    
                    cd(project_path)
                    try
                        [ring_inds, ~] = FindRing(frameRGB, tower_inds, tower);

                        if FinalSegments(FrameNum - start_ind + 1) == 1 %gray
                            r2(ring_inds) = 191;
                            g2(ring_inds) = 191;
                            b2(ring_inds) = 191;
                        elseif FinalSegments(FrameNum - start_ind + 1) == 2 %yellow
                            r2(ring_inds) = 255;
                            g2(ring_inds) = 217;
                            b2(ring_inds) = 102;
                        elseif FinalSegments(FrameNum - start_ind + 1) == 3 %blue
                            r2(ring_inds) = 157;
                            g2(ring_inds) = 195;
                            b2(ring_inds) = 230;
                        else %4 - purple
                            r2(ring_inds) = 201;
                            g2(ring_inds) = 162;
                            b2(ring_inds) = 230;
                        end
                    catch
                        hello = 1;
                    end

                    new_im = cat(3, r2, g2, b2);

                    imshow(new_im)
                    % hold on
                    % rectangle('Position', [982, 575, 1270 - 982, 945 - 575], 'LineWidth', 2, 'EdgeColor', 'y')

                    pause(10^-3)
                    writeVideo(video, new_im); %write the image to file
                end
                close(video); %close the video file

            end %end of running over all four towers

            disp(['subj_', participant, '_', month, '_', tt, ': Finished (',num2str(toc),' sec).']);
            delete(fullfile(TempDirPath,'\*'));
            rmdir(TempDirPath);

        end %end of running on participant's 3 sessions

    end %end of running on participant's 6 months

end %end of running on all participants

diary off
