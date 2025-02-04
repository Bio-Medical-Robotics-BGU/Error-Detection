%% This code reads a video with the detected tower movements and tower segments displayed on it and allows for
% running frame by frame, and correcting the labels if needed.

% Options:

% 1. change error detection label
% 2. change tower segment label

%replace the following line with the directories to the saved videos and
%segmentation
close all;    
clear all;
clc;


project_path = "C:\Users\hanna\OneDrive\MATLAB\lab\PhD\ErrorPrediction";

MovesPath = fullfile(project_path, "AllMoves");
SegmentsPath = fullfile(project_path, "TowerSegments");
VideoPath = fullfile(project_path, "ResultVideos");

participant = input("Which user would you like?\n", 's');
month = input("Which month would you like (1-6)?\n", 's');
tt = input("Which session time would you like (a-c)?\n", 's');
i = input("Which tower would you like (1-4)? \n 1. Vertical Right \n 2. Horizontal Left \n 3. Vertical Left \n 4. Horizontal Right \n");
% Tower Parameters
if i == 1 % vertical right
    tower = 'vertical_right';
elseif i == 2  % horizontal left
    tower = 'horizontal_left';
elseif i == 3  % vertical left
    tower = 'vertical_left';
else % i=4, horizontal right
    tower = 'horizontal_right';
end %end of setting up tower parameters
%% Reading files
cd(VideoPath)
vidReader = VideoReader(['DetectedErrorsUpdated_RingSegments_', participant, month, tt, '_', tower, '.mp4.avi']);

cd(MovesPath)
Moves = load(['MovesUpdated_', participant, '_', month, '_', tt, '_', tower, '.mat']).data;


figure
plot(Moves)

cd(SegmentsPath)
Segments = load(['TowerSegments_', participant, '_', month, '_', tt, '_', tower, '.mat']).data;
figure
plot(Segments)


%% Running over video frames
figure;
currAxes = axes;

j = 1;

while j<= vidReader.NumFrames


    image(read(vidReader, j), 'Parent', currAxes);
    if Moves(j) == 1
        title('error')
    end

    k = waitforbuttonpress;
    cur_char = double(get(gcf,'CurrentCharacter'));

    %move backward and forward between frames

    if cur_char == 29 %right arrow
        j = j + 1;
    end

    if cur_char == 28 %left arrow
        j = j - 1;
    end

    %fix detected collisions

    if cur_char == 32 % space bar - then we want to delete entire detected move
        bb = bwlabel(Moves);
        todelete = find(bb == bb(j));
        Moves(todelete) = 0;
    end

    if cur_char == 110 % n - then we want to swtich 1 to 0
        Moves(j) = 0;
    end

    if cur_char == 109 % m - then we want to add a bunch of samples to the move
        bb2 = bwlabel(1 - Moves);
        toadd = find(bb2 == bb2(j));
        Moves(toadd) = 1;
    end

    if cur_char == 98 % b - then we want to swtich 0 to 1
        Moves(j) = 1;
    end


    %fix detected tower segment  

    if cur_char == 49 % 1 - switch segment label to 1
        Segments(j) = 1;
    end
    if cur_char == 50 % 2 - switch segment label to 2
        Segments(j) = 2;
    end
    if cur_char == 51 % 3 - switch segment label to 3
        Segments(j) = 3;
    end
    if cur_char == 52 % 4 - switch segment label to 4
        Segments(j) = 4;
    end
end % end of running over the tower frames

cd(MovesPath)
save(['MovesFixed_', participant, '_', month, '_', tt, '_', tower], 'Moves')
cd(SegmentsPath)
save(['TowerSegmentsFixed_', participant, '_', month, '_', tt, '_', tower], 'Segments')

figure
plot(Moves)
figure
plot(Segments)

