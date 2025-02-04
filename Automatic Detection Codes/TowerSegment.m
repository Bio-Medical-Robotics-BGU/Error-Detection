function [segment] = TowerSegment(centroid, tower)
%This function receives the ring centroid and tower and returns which of the
%four tower segments the ring is currently in.

% Tower Parameters
if strcmp(tower , 'vertical_right')
    co1 = 907;
    co2 = 823; %875 - ((875 - 770) / 2)
    co3 = 696; %750 - ((750 - 643) / 2)

    %vertical towers use the y axis - centroid(2)
    if centroid(2) >= co1
        segment = 1;
    elseif (centroid(2) < co1 && centroid(2) >= co2)
        segment = 2;
    elseif (centroid(2) < co2 && centroid(2) >= co3)
        segment = 3;
    else % centroid(2) < co3
        segment = 4;
    end
  
elseif strcmp(tower , 'horizontal_left')
    co1 = 285; %225 + ((344 - 225) / 2)
    co2 = 422; %360 + ((484 - 360) / 2)
    co3 = 531; 

    %horizontal towers use the x axis - centroid(1)
    if centroid(1) < co1
        segment = 4;
    elseif (centroid(1) >= co1 && centroid(1) < co2)
        segment = 3;
    elseif (centroid(1) >= co2 && centroid(1) < co3)
        segment = 2;
    elseif (centroid(1) >= co3 && centroid(2) < 1050)%but it's too high to be in segment 1
        segment = 2;
    else % centroid(1) >= co3
        segment = 1;
    end

elseif strcmp(tower , 'vertical_left')
    co1 = 913;
    co2 = 828; %880 - ((880 - 776) / 2)
    co3 = 702; %755 - ((755 - 650) / 2)

     %vertical towers use the y axis - centroid(2)
    if centroid(2) >= co1
        segment = 1;
    elseif (centroid(2) < co1 && centroid(2) >= co2)
        segment = 2;
    elseif (centroid(2) < co2 && centroid(2) >= co3)
        segment = 3;
    else % centroid(2) < co3
        segment = 4;
    end
  
else %horizontal right
    co1 = 1645; %1699 - ((1699 - 1594) / 2)
    co2 = 1519; %1577 - ((1577 - 1462) / 2)
    co3 = 1421; 
  
     %horizontal towers use the x axis - centroid(1)
    if centroid(1) >= co1
        segment = 4;
    elseif (centroid(1) < co1 && centroid(1) >= co2)
        segment = 3;
    elseif (centroid(1) < co2 && centroid(1) >= co3)
        segment = 2;
    elseif (centroid(1) < co3 && centroid(2) < 1040)%but it's too high to be in segment 1
        segment = 2;
    else % centroid(1) < co3
        segment = 1;
    end

end %end of setting up tower parameters


end