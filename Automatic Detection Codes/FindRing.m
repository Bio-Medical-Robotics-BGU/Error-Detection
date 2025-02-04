function [ring_inds, centroid] = FindRing(im, tower_inds, tower)
% The function finds the ring and returns the ring indices. It additionally
% returns the center of mass of the detected ring

% Tower Parameters
if strcmp(tower , 'vertical_right')
    % relevant part of image
    y1 = 565;
    y2 = 990;
    x1 = 960;
    x2 = 1320;

elseif strcmp(tower , 'horizontal_left')
    % relevant part of image
    y1 = 875;
    y2 = 1160;
    x1 = 160;
    x2 = 600;

elseif strcmp(tower , 'vertical_left')
    % relevant part of image
    y1 = 565;
    y2 = 990;
    x1 = 645;
    x2 = 1005;

else %horizontal right
    % relevant part of image
    y1 = 860;
    y2 = 1145;
    x1 = 1357;
    x2 = 1797;

end %end of setting up tower parameters

%find green indices in image
g = double(im(:, :, 2));

blacks = find(g <= 30);
%the area of the tower
rows = y1:y2;
columns = x1:x2;

ind1 = repmat(rows', 1, numel(columns)); 
ind2 = repmat(columns, numel(rows), 1); 
inds = sub2ind(size(g), ind1, ind2);

%intersecting between the area of the tower and the green indices in the
%image
area_blacks = intersect(inds(:), blacks);

%cleaning small detected black areas that are not part of the ring
bwim = (zeros(size(g)));
bwim(area_blacks) = 1;

%taking only those bigger than a threshold of 200
BW2 = bwareafilt(logical(bwim),[100 5000]);

[L, n] = bwlabel(BW2);

% adding another constraint - taking only detected areas that are close to
% tower
[r_tower, c_tower] = ind2sub(size(im), tower_inds); %this is the detected location of the tower in this image
    
for i = 1:n %run over detected black areas and find which are close enough to the detecte tower
    [r_black, c_black] = find(L == i); %the i_th detected blob
    D = pdist2([r_tower c_tower], [r_black c_black],'euclidean'); % euclidean distance
    
    try
        [r2, c2] = find(D == min(D(:)));
    
        point_1 = [r_tower(r2(1)) c_tower(r2(1))]; %if there are multiple points that have the minimum distance, 
        %then take only the first as it doesn't matter which points these are,
        %or how many there are, only that the two blobs are close enough, and
        %that only requires one point that meets the minimum distance criterea.
    
        point_2 = [r_black(c2(1)) c_black(c2(1))];
    
        distance = sqrt((point_1(1) - point_2(1)).^2 + (point_1(2) - point_2(2)).^2);
    
        if distance > 10 %then delete the blob
            L(find(L == i)) = 0;
        end
    catch
        continue
    end

end %end of running over detected blobs

ring_inds = find(L ~= 0);

% Find center of mass of detected area - we want a point to comapre to
% where the ring is relative to the tower

if ~isempty(ring_inds)
    bwim = (zeros(size(g)));
    bwim(ring_inds) = 1;
    
    measurements = regionprops(bwim, 'Centroid');
    centroid = measurements.Centroid;
else
    centroid = [-1, -1];
end

end