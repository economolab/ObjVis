function allActivityModes(fig)

% find all 7 activity modes as described in :
% Thalamus drives diverse responses in frontal cortex during decision-making
% Weiguo Yang, Sri Laasya Tipparaju, Guang Chen, Nuo Li

% 1. stimulus mode: defined during stimulus (sample) period
%       ((hitR - missL) + (missR - hitL)) / sqrt(sum(sd for each tt ^2));
% 2. choice mode: defined during delay period
%       ((hitR - missR) + (missL - hitL)) / sqrt(sum(sd for each tt ^2));
% 3. action mode: defined during mvmt init (0.1 to 0.3 s rel to go cue)
%       (hitR - hitL) / sqrt(sum(sd for each tt ^2));
% 4. outcome mode: defined during response epoch (0 to 1.3 s rel go cue)
%       ((hitR - missL) + (missR - hitL)) / sqrt(sum(sd for each tt ^2));
% 5. ramping mode: in correct trials
%       (hit_presample - hit_delay) / sqrt(sum(sd for each tt ^2));
% 6. go mode: 0.1 sec before or after go cue
%       (hit_after - hit_before) / sqrt(sum(sd for each tt ^2));
% 7. response mode: 
%    a. find eigenvectors of basline subtracted PSTHs using SVD
%       aa. matrix was of size (n x (2t)), where left and right trials concatenated
%       in time
%    b. response mode = eigenvector with largest eigenvalue


% % TODO: 
% 1. find 7 modes
% 2. only use portion of trials to find modes and other portion to project
% 3. visualize
% 4. subtract out modes found using 2afc from aw context. See what's left.

h = guidata(fig);

probe = h.probeList.Value;

dt = 0.005;

[psth,tm] = getPSTH(fig);

stimMode = getStimMode(h,{'R&hit','L&hit','R&miss','L&miss'});
plotModeProj(stimMode,psth,tm,'stimulus mode');



end % allActivityModes

function edges = findedges(obj,dt,epoch,trial)
    % find histogram bin edges for a specific trial and epoch
    % used to find activity modes / coding vectors when trial and/or epoch
    % lengths differ between trials
    switch epoch
        case 'presample'
            e1 = obj.bp.ev.sample(trial) - 0.5; % 0.5 second before sample
            e2 = obj.bp.ev.sample(trial);
        case 'sample'
            e1 = obj.bp.ev.sample(trial);
            e2 = obj.bp.ev.delay(trial);
        case 'delay'
            e1 = obj.bp.ev.delay(trial);
            e2 = obj.bp.ev.goCue(trial);
        case 'goCue'
            e1 = obj.bp.ev.goCue(trial);
            e2 = obj.bp.ev.goCue(trial) + 1; 
        case 'reward'
            e1 = obj.bp.ev.reward(trial);
            e2 = obj.bp.ev.reward(trial) + 1;
    end
   % define edges based on e1 and e2 for the current trial
   edges = e1:dt:e2;
   
end % findedges

function plotModeProj(mode,psth,tm,ptitle)
% project psth for hitR and hitL onto mode
proj1 = psth(:,:,1) * mode;
proj2 = psth(:,:,2) * mode;

figure;
plot(tm,proj1,'b'); hold on
plot(tm,proj2,'r');
title(ptitle)
end % plotModeProj

function stimMode = getStimMode(h,ttype)
% 1. stimulus mode: defined during stimulus (sample) period
%       ((hitR - missL) + (missR - hitL)) / sqrt(sum(sd for each tt ^2));
probe = h.probeList.Value;
epoch = 'sample';
dt = 0.005;

% deal with trial types
varnames = getStructVarNames(h);
for i = 1:numel(varnames)
    eval([varnames{i} ' = h.obj.bp.' varnames{i} ';']);
    
    if eval(['numel(' varnames{i} ')==h.obj.bp.Ntrials && isrow(' varnames{i} ')'])
        eval([varnames{i} '=' varnames{i} ''';']);
    end
end

filt.N = numel(ttype);
filt.ix = zeros(h.obj.bp.Ntrials, filt.N);
for i = 1:numel(ttype)
    curfilt = ttype{i};
    filt.ix(:,i) = eval(curfilt);
end

nTrials = max(sum(filt.ix));
psth = nan(500,numel(h.obj.clu{probe}),nTrials,filt.N);
epochMean = nan(numel(h.obj.clu{probe}),nTrials,filt.N);
% for each cluster
for clu = 1:numel(h.obj.clu{probe})
    % for each filt
    for cond = 1:filt.N
        trix = find(filt.ix(:,cond));
        % for each trial in filt
        for trial = 1:numel(trix)
            % get spike times for trial
            tr = trix(trial);
            spkix = ismember(h.obj.clu{probe}(clu).trial, tr);
            % calculate edges (idxs corresponding to epoch period for trial)
            edges = findedges(h.obj,dt,epoch,tr);
            % calculate psth for that trial
            psth(1:numel(edges),clu,trial,cond) = histc(h.obj.clu{probe}(clu).trialtm(spkix), edges);
            % mean of psth(trial) == avg firing rate for trial during epoch
            epochMean(clu,trial,cond) = nanmean(psth(:,clu,trial,cond),1);
        end
    end
    % calculate pval with mann u whitney test
    pval(clu) = ranksum(epochMean(clu,:,1), epochMean(clu,:,2));
    for ii = 1:filt.N
        mu(clu,ii) = nanmean(epochMean(clu,:,ii));
        sd(clu,ii) = nanstd(epochMean(clu,:,ii));
    end
end

stimMode = ((mu(:,1)-mu(:,4)) + (mu(:,3)-mu(:,2)))./ sqrt(sum(sd.^2,2));
stimMode(isnan(stimMode)) = 0;
pvalThresh = 1; 

stimMode = stimMode.*(pval' < pvalThresh);
stimMode = stimMode./sum(abs(stimMode)); % (ncells,1)

end % getStimMode


























