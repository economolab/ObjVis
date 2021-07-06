function codingVector(fig)

% % HOW TO HANDLE TRIALS OF DIFFERING LENGTH 
% what i'm thinking is i'll calculate single trial firing rates, avg over
% the single trial epoch, and then average over trials to get mean firing
% rate for a unit for an epoch.

h = guidata(fig);

probe = h.probeList.Value;
sm = str2double(h.smoothing.String);
epoch = h.filterTable.Data(:,6);

dt = 0.005;

nTrials = max(sum(h.filt.ix));
psth = nan(500,numel(h.obj.clu{probe}),nTrials,h.filt.N);
epochMean = nan(numel(h.obj.clu{probe}),nTrials,h.filt.N);
% for each cluster
for clu = 1:numel(h.obj.clu{probe})
    % for each filt
    for cond = 1:h.filt.N
        trix = find(h.filt.ix(:,cond));
        % for each trial in filt
        for trial = 1:numel(trix)
            % get spike times for trial
            tr = trix(trial);
            spkix = ismember(h.obj.clu{probe}(clu).trial, tr);
            % calculate edges (idxs corresponding to epoch period for trial)
            edges = findedges(h.obj,dt,epoch{cond},tr);
            % calculate psth for that trial
            psth(1:numel(edges),clu,trial,cond) = histc(h.obj.clu{probe}(clu).trialtm(spkix), edges);
            % mean of psth(trial) == avg firing rate for trial during epoch
            epochMean(clu,trial,cond) = nanmean(psth(:,clu,trial,cond),1);
        end
    end
    % calculate pval with mann u whitney test
    pval(clu) = ranksum(epochMean(clu,:,1), epochMean(clu,:,2));
    mu(clu,1) = nanmean(epochMean(clu,:,1));
    mu(clu,2) = nanmean(epochMean(clu,:,2));
    sd(clu,1) = nanstd(epochMean(clu,:,1));
    sd(clu,2) = nanstd(epochMean(clu,:,2));
end

% get coding vector
cv = (mu(:,2)-mu(:,1))./sqrt(sd(:,1).^2 + sd(:,2).^2);
cv(isnan(cv)) = 0;

pvalThresh = 0.005;
cv = cv.*(pval' < pvalThresh);
cv = cv./sum(abs(cv)); % (ncells,1)

% get trial-averaged psths for all clu (time,clu,filt)
[psth,tm] = getPSTH(fig);

% % testing orthog stuff
% figure
% load('cvpresample.mat')
% proj1 = psth(:,:,1) * cv;
% proj2 = psth(:,:,2) * cv;
% subplot(4,1,1)
% plot(tm,proj1,'b'); hold on
% plot(tm,proj2,'r');
% title('presample')
% load('cvgocue.mat')
% proj1 = psth(:,:,1) * cv;
% proj2 = psth(:,:,2) * cv;
% subplot(4,1,2)
% plot(tm,proj1,'b'); hold on
% plot(tm,proj2,'r');
% title('gocue')
% load('cvgocue_orth.mat')
% proj1 = psth(:,:,1) * cv;
% proj2 = psth(:,:,2) * cv;
% subplot(4,1,3)
% plot(tm,proj1,'b'); hold on
% plot(tm,proj2,'r');
% title('orth gocue to presample')
% load('cvpresamp_orth.mat')
% proj1 = psth(:,:,1) * cv;
% proj2 = psth(:,:,2) * cv;
% subplot(4,1,4)
% plot(tm,proj1,'b'); hold on
% plot(tm,proj2,'r');
% title('orth presamp to gocue')




% project onto cv
proj1 = psth(:,:,1) * cv;
proj2 = psth(:,:,2) * cv;

figure;
plot(tm,proj1,'b'); hold on
plot(tm,proj2,'r');


end % Projections

function edges = findedges(obj,dt,epoch,trial)
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





