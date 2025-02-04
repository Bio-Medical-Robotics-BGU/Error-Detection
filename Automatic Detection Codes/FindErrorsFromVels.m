function Moves = FindErrorsFromVels(Vels)
% This code uses STFT and a threshold to detect the movements
% of the towers from the velocity magnitude computed using optical flow

windowSize = 5;
b = (1/windowSize)*ones(1,windowSize);
a = 1;

thresh = 20;
numneeded = 2;
overl = 2;

Filtered_Vels = filter(b, a, Vels);

Vel_deriv = diff(Filtered_Vels);

%compute STFT
[s,~,~] =  stft(Vel_deriv, 'Window', gausswin(overl + 1), 'OverlapLength', overl);

vals = mag2db(abs(s).^2);

Cond = (vals > thresh);
keep = find(sum(Cond) >= numneeded);
Moves = zeros(length(Vels), 1);
Moves(keep) = 1;

%getting rid of initial artifact movement
if sum(Moves(1:10)) > 0 && sum(Moves(11:15)) == 0
    Moves(1:10) = 0;
end

% combining close detected movements (primarily cleans)
DiffMoves = diff(Moves);

MoveEnds = find(DiffMoves == -1);
MoveStarts = find(DiffMoves == 1);
if (length(MoveStarts) < length(MoveEnds)) && Moves(1) == 1
    MoveStarts = [1; MoveStarts];
end

for i = 1:length(MoveEnds) - 1
    if MoveStarts(i+1) - MoveEnds(i) < 10 %combine all movements within 10 samples of each other
        Moves(MoveEnds(i) + 1:MoveStarts(i+1)) = 1;
    end
    
end

%cleaning not real movements
for i = 3:length(Moves) - 2
    if Moves(i) == 1
        if ((Moves(i - 2) == 0 && Moves(i + 2) == 0) || (Moves(i - 1) == 0 && Moves(i + 1) == 0))
            Moves(i) = 0;
        end
    end
end


DiffMoves = diff(Moves);

MoveEnds = find(DiffMoves == -1);
MoveStarts = find(DiffMoves == 1);


%due to the delay from the filtering

for i = 1:length(MoveStarts)
    if MoveStarts(i) <= (length(Moves) - 3)
        Moves(MoveStarts(i): (MoveStarts(i) + 2)) = 0;
    end
end

for i = 1:length(MoveEnds)
    if (MoveEnds(i) >= 3)
        Moves((MoveEnds(i) - 2): MoveEnds(i)) = 0;
    end
end


end % end of function