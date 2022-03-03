function p = trialWarpFits_Jaw(jawStart,crosstm, med,obj,nLicks)

dt = 1/400;
dt = 0; 
p = cell(obj.bp.Ntrials, 2);
mls = med.lickStart;

firstKnots = crosstm;
% firstKnot = obj.bp.ev.goCue;

for trix = 1:obj.bp.Ntrials
    ls = jawStart{trix}; % current trial lick start times
    tm = obj.traj{1}(trix).frameTimes-0.5;
    
    if isempty(ls)
        continue;
    end
    
%     for lix = 1:numel(ls) % lick index
        
        
        
        % median values for current lick
        
        % warp lick times
        % if first lick: warp from go cue to just before 2nd lick start
        % if lick2 or lick>2: warp from start of current lick to just
        % before start of next lick
        % if last lick: warp from start of last lick to median(diff(mls))
        % [lickRate]
%         if numel(ls)==1 % only 1 lick
%             x = [obj.bp.ev.goCue(trix) ls(1)];%+median(diff(mls))];
%             y = [mode(obj.bp.ev.goCue) mls(1)];%+median(diff(mls))];
%         elseif lix == 1
%             x = [obj.bp.ev.goCue(trix) ls(2)-dt];
%             y = [mode(obj.bp.ev.goCue) mls(2)-dt];
%         elseif lix == numel(ls)
%             x = [ls(lix) tm(end)];%+median(diff(mls))];
%             y = [mls(lix) tm(end)];%+median(diff(mls))];
%         else
%             x = [ls(lix) ls(lix+1)-dt]; 
%             y = [mls(lix) mls(lix+1)-dt];
%         end
        
        % fit original time to warped time
%         p{trix,lix} = polyfit(x,y,1);

%         knots = zeros(numel(ls)+3, 1);
%         knots(1) = median(obj.bp.ev.goCue)-pfit{trix}(1);
%         knots(2:end-1) = [median(obj.bp.ev.goCue); med.lickStart(1:numel(ls))];
%         knots(end) = knots(end-1) + (ft(end) - pfit{trix}(end));
%         
%         p = [ft(1); pfit{trix}; ft(end)];


        
        
        p{trix, 1} = [tm(1); firstKnots(trix); ls; tm(end)];
        
        p{trix, 2} = [median(firstKnots)-firstKnots(trix); ... %start of trial
            median(firstKnots); ... %go cue
            mls(1:numel(ls)); ... %first N average licks time
            mls(numel(ls)) + (tm(end) - ls(end))]; %average time of Nth lick plus time elapsed after last lick to end of trial
            
            
        
%     end
    
end

end