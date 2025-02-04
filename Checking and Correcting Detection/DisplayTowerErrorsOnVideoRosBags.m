%% This code displays the corrected moves and tower segments in on the video

%replace the following line with the directories to the saved videos and
%segmentation
project_path = "C:\Users\hanna\OneDrive\MATLAB\lab\PhD\ErrorPrediction";

BagPath = fullfile(project_path, "CamBags");
SegPath = fullfile(project_path, "AllSegmentations");

MovesSavePath = fullfile(project_path, "AllMoves");
SegmentsPath = fullfile(project_path, "TowerSegments");
VideoSavePath = fullfile(project_path, "ResultVideos");

AllParticipants = ['F'];
AllMonths = ['1']; 
AllTimes =['c'];

%%
for pp = 1:length(AllParticipants)
    participant = AllParticipants(pp);

    for mm = 1:length(AllMonths)
        month = AllMonths(mm);

        for ttt = 1:length(AllTimes)
            tt = AllTimes(ttt);
                       
            disp(['subj_', participant, '_', month, '_', tt, ': Start'])
            tic

            % 1. loading segmentation
            cd(SegPath)
            segmentation = load(['subj_', participant, '_', month, '_', tt, '_Ringtowertransfer_Segmentation.mat']);
            segmentation = segmentation.Segmentation;

            % 3. loading Cam RosBag
            cd(BagPath)
            bag = rosbag(['subj_', participant, '_', month, '_', tt, '_Ringtowertransfer_CAM.bag']);%loading bag file with compressed images
            bagSelection =  select(bag, 'Topic','/image_view_left/output/compressed');
            allMsgs = readMessages(bagSelection);
            t = bagSelection.MessageList.Time;
            
            disp('all loaded')
            
            %creating a temporary folder for the images:
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
                    
                % if isfile(fullfile(VideoSavePath, ['DetectedErrors_RingSegments_Fixed_', participant, month, tt, '_', tower, '.mp4.avi']))
                %     continue
                % end

                TextPosition = [1,1]; %For the information presented on each frame
                box_color = "white";
                
                disp('Starting to run over images')

                cd(MovesSavePath)
                Moves = load(['MovesFixed_', participant, '_', month, '_', tt, '_', tower, '.mat']).Moves;

                cd(SegmentsPath)
                Segments = load(['TowerSegmentsFixed_', participant, '_', month, '_', tt, '_', tower, '.mat']).Segments;

                % 8. Create video for displaying results:
                % This video colors the tower red when a movement is
                % detected.
                % The ring switches color based on the detected tower
                % segment

                % 9. run over tower frames
                
                disp('starting to create video')
                % creating video object for displaying results
                video = VideoWriter(fullfile(VideoSavePath, ['DetectedErrors_RingSegments_Fixed_', participant, month, tt, '_', tower, '.mp4'])); %create the video object
                open(video); %open the file for writing
                
                for FrameNum = start_ind:end_ind
                    frameRGB = readImage(allMsgs{FrameNum});

                    text_str = [ 'Time: ' num2str(t(FrameNum) - t(start_ind)) ' [sec], Sample #' num2str(FrameNum)];

                    frameRGB = insertText(frameRGB,TextPosition,text_str,'FontSize',22,...
                        'BoxColor','white', ...
                        'TextColor','Black');


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
                    [ring_inds, ~] = FindRing(frameRGB, tower_inds, tower);

                    if Segments(FrameNum - start_ind + 1) == 1 %gray
                        r2(ring_inds) = 191;
                        g2(ring_inds) = 191;
                        b2(ring_inds) = 191;
                    elseif Segments(FrameNum - start_ind + 1) == 2 %yellow
                        r2(ring_inds) = 255;
                        g2(ring_inds) = 217;
                        b2(ring_inds) = 102;
                    elseif Segments(FrameNum - start_ind + 1) == 3 %blue
                        r2(ring_inds) = 157;
                        g2(ring_inds) = 195;
                        b2(ring_inds) = 230;
                    else %4 - purple
                        r2(ring_inds) = 201;
                        g2(ring_inds) = 162;
                        b2(ring_inds) = 230;
                    end
                                      

                    new_im = cat(3, r2, g2, b2);

                    imshow(new_im)
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

