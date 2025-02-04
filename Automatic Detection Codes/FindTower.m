function tower_inds = FindTower(im, tower)
%This function receives an image, and current tower
%and returns the relevant indices

% Tower Parameters
if strcmp(tower , 'vertical_right')
    % relevant part of image
    y1 = 575;
    y2 = 945;
    x1 = 982;
    x2 = 1270;

elseif strcmp(tower , 'horizontal_left')
    % relevant part of image
    y1 = 875;
    y2 = 1160;
    x1 = 160;
    x2 = 600;

elseif strcmp(tower , 'vertical_left')
    % relevant part of image
    y1 = 575;
    y2 = 945;
    x1 = 694;
    x2 = 982;

else %horizontal right
    % relevant part of image
    y1 = 860;
    y2 = 1145;
    x1 = 1357;
    x2 = 1797;

end %end of setting up tower parameters

%find green indices in image

r = double(im(:, :, 1));
g = double(im(:, :, 2));

%option 2:
HSV = rgb2hsv(im).*255;
[h,s,v] = imsplit(HSV);
cond1 = intersect(find(h >= 70), find(h <= 130));
cond2 = intersect(find(s >= 90), find(v <= 120));
greens = intersect(cond1, cond2);

%the area of the tower
rows = y1:y2;
columns = x1:x2;

ind1 = repmat(rows', 1, numel(columns));
ind2 = repmat(columns, numel(rows), 1);
inds = sub2ind(size(r), ind1, ind2);

%intersecting between the area of the tower and the green indices in the
%image
area_greens = intersect(inds(:), greens);

%cleaning small detected green areas that are not part of the tower
bwim = (zeros(size(r)));
bwim(area_greens) = 1;

[L, n] = bwlabel(bwim);

[counts, groupnames] = groupcounts(L(:));
%take second to biggest, because the most will be zero - where the image is
%black
[sorted_counts, sorted_inds] = sort(counts, 'descend');
%taking care of the split problem
big_enough = find(sorted_counts > 100);
big_enough = setdiff(big_enough, 1);

rel_num = groupnames(sorted_inds(big_enough)); %the number representing the desired clump in L

tower_inds = find(ismember(L, rel_num));

end