function clean_segs = CleanSegments(segs, tower)
% This function receives the tower segments the ring was in for one tower
% and cleans in the event of jumps back and forth between segments

if (strcmp(tower , 'horizontal_right') || strcmp(tower , 'horizontal_left')) %4, 3, 2, 1
    segs = flipud(segs);
    t = 1; %horizontal
else 
    t = 2; %vertical
end  
    

diffed = diff(segs);
unis = unique(diffed);


if ~isempty(setdiff(unis, [0, 1]))
    goods = [find(diffed == 0); find(diffed == 1)];    
    errs = setdiff(1:(length(segs) - 1), goods);
    
    if length(errs) == 1
        if (errs == 1 && t == 2)
            segs(1) = 1;
        elseif (errs == length(segs) && t == 1)
            segs(end) = 4;
        end
    end

    for i = 1:length(errs)
        try
            segs(errs(i) - 2:errs(i) + 2) = mode(segs(errs(i) - 2:errs(i) + 2));
            
        catch
            try
                segs(errs(i) - 1:errs(i) + 1) = mode(segs(errs(i) - 1:errs(i) + 1));
            catch
                if errs(i) == 1
                    segs(1) = 1;
                elseif errs(i) == length(segs)
                    segs(end) = 4;
                end
            end
        end
        
    end
    
end
clean_segs = segs;

if (strcmp(tower , 'horizontal_right') || strcmp(tower , 'horizontal_left')) %4, 3, 2, 1
    clean_segs = flipud(clean_segs);
end

end