function p = trialWarpFits(lickTm,medianLickTm,obj,nLicks)


p = cell(obj.bp.Ntrials,nLicks);
for trix = 1:obj.bp.Ntrials
    lt = lickTm{trix}; % current trial post go cue lick times
    
    for lix = 1:numel(lt) % lick index
        mlt = medianLickTm(lix); % median lick time for current lick
        
        % warp lick times
        % - 1st lick: warp from goCue:lick(1)
        % - subsequent licks: warp from lick(x-1):lick(x)
        if lix == 1
            x = [obj.bp.ev.goCue(trix) lt(lix)];
            y = [mode(obj.bp.ev.goCue) mlt];
        else
            x = [lt(lix-1) lt(lix)];
            y = [medianLickTm(lix-1) mlt];
        end
        
        % fit original time to warped time (median lick time for current
        % lick)
        p{trix,lix} = polyfit(x,y,1);
        
    end
    
end

end