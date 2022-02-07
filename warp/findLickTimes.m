function lickTm = findLickTimes(obj,nLicks)


lickTm = cell(obj.bp.Ntrials,1);
for trix = 1:obj.bp.Ntrials
    
    % get all times when animal licked lickport on current trial
    if obj.bp.R(trix) % if right trial
        lickTimes = obj.bp.ev.lickR{trix};
    elseif obj.bp.L(trix) % if left trial
        lickTimes = obj.bp.ev.lickL{trix};
    else
        error(['Trial ' num2str(trix) ' is neither a left or right trial. Make sure bpod data is correct or that session is a 2afc session'])
    end
    
    % time of go cue for current trial
    gc = obj.bp.ev.goCue(trix);
    
    % only keep lick times post go cue to align data to
    lickTimes = lickTimes(lickTimes > gc);
    
    % keep first params.nLicks only
    if numel(lickTimes) >= nLicks % check if there are params.nLicks licks in current trial
        lickTm{trix} = lickTimes(1:nLicks);
    else % if not, grab all lick times
        lickTm{trix} = lickTimes;
    end
    
end

end