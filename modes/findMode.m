function findMode(~,~,fig)

h = guidata(fig);

% PARSE GUI DATA
probe = h.probeList.Value;
dt = 0.005;
tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));
edges = tmin:dt:tmax - mode(h.obj.bp.ev.goCue);
time = edges + dt/2;
time = time(1:end-1);
modetmin = str2double(get(h.modetmin, 'String'));
modetmax = str2double(get(h.modetmax, 'String'));
modeConditions = h.condTable.Data;
projConditions = h.projTable.Data;
computation = h.modeComputation.String;
quality = h.quality.String';
smooth = str2double(get(h.smoothing, 'String'));
lowFR = str2double(get(h.lowFR,'String'));

% PREPROCESS
% get trials to use (for projections)
trialid = findTrials(h, projConditions);
% get clusters to use (for everything)
cluQuality = {h.obj.clu{probe}(:).quality}';
cluid = findClusters(cluQuality, quality);
% align spikes to go cue
h.obj = alignSpikes(h.obj,probe,'goCue');
% get trial avg psth and single trial data
h.obj = getSeq(h.obj,edges,time,dt,probe,cluid,trialid,projConditions,smooth);
% remove low fr clusters
[h.obj, cluid] = removeLowFRClusters(h.obj,cluid,lowFR);

% FIND MODE
% get trials to use (for mode)
trials = getTrialsForModeID(h,modeConditions);
% slice trialpsth from modetmin to modetmax and find mean during time
% period for all trials and modeConditions
[~,e1] = min(abs(time - modetmin));
[~,e2] = min(abs(time - modetmax));
nTrialsCond = sum(trials.ix);
epochMean = nan(numel(cluid),max(nTrialsCond),trials.N);
for i = 1:trials.N
    nTrials = nTrialsCond(i);
    epochMean(:,1:nTrials,i) = nanmean(h.obj.trialpsth(e1:e2,:,logical(trials.ix(:,i))),1);
end
% get epoch stats (mean and std dev across trials for each cluster)
mu = nan(numel(cluid),trials.N);
sd = nan(size(mu));
for cluix = 1:numel(cluid) % for each cluster
    for cnd = 1:trials.N
        mu(cluix,cnd) = nanmean(epochMean(cluix,:,cnd));
        sd(cluix,cnd) = nanstd(epochMean(cluix,:,cnd));
    end
end

% calculate mode according to 'computation' variable
cd = eval(computation)./sqrt(sum(sd.^2,2));
cd(isnan(cd)) = 0;
cd = cd./sum(abs(cd)); % (ncells,1)

% PLOT
sample = mode(h.obj.bp.ev.sample) - mode(h.obj.bp.ev.goCue);
delay  = mode(h.obj.bp.ev.delay) - mode(h.obj.bp.ev.goCue);
zeroEv  = 0; % corresponds to goCue

for j = 1:numel(projConditions)
    latent = mySmooth(h.obj.psth(:,:,j)*cd,smooth);
    plot(h.modeax(1),time,latent,'LineWidth',2);
    hold on
end
xline(sample,'k--','LineWidth',0.5);
xline(delay,'k--','LineWidth',0.5);
xline(zeroEv,'k--','LineWidth',0.5);
xlim([time(1),time(end)])
legend(projConditions,'Location','best');
hold off


end % findMode
%%
function trialNums = findTrials(h, conditions)

obj = h.obj;

if ~isfield(obj.bp.autowater, 'nums')
    tmp = obj.bp.autowater;
    obj.bp = rmfield(obj.bp, 'autowater');
    obj.bp.autowater.nums = tmp + (tmp-1)*-2;
end

varnames = getStructVarNames(h);
for i = 1:numel(varnames)
    eval([varnames{i} ' = obj.bp.' varnames{i} ';']);
    
    if eval(['numel(' varnames{i} ')==obj.bp.Ntrials && isrow(' varnames{i} ')'])
        eval([varnames{i} '=' varnames{i} ''';']);
    end
end

mask = zeros(obj.bp.Ntrials, numel(conditions));


for i = 1:numel(conditions)
    mask(:,i) = eval(conditions{i});
    trialNums{i} = find(mask(:,i));
end

end % findTrials
%%
function idx = findClusters(qualityList, qualities)
% find idx where qualityList contains at least one of the patterns in
% qualities

% handle unlabeled cluster qualities
for i = 1:numel(qualityList)
    if isempty(qualityList{i})
        qualityList(i) = {'nan'};
    end
end

[~,mask] = patternMatchCellArray(qualityList, qualities, 'any');

idx = find(mask);
end % findClusters
%%
function obj = alignSpikes(obj,probe,alignEvent)

% align spikes to params.alignEvent
for clu = 1:numel(obj.clu{probe})
    event = obj.bp.ev.(alignEvent)(obj.clu{probe}(clu).trial);
    obj.clu{probe}(clu).trialtm_aligned = obj.clu{probe}(clu).trialtm - event;
end

end % alignSpikes
%%
function obj = getSeq(obj,edges,time,dt,probe,cluid,trialid,projConditions,smooth)

% get psths by condition
obj.psth = zeros(numel(time),numel(cluid),numel(projConditions));
for i = 1:numel(cluid)
    curClu = cluid(i);
    for j = 1:numel(projConditions)
        trix = trialid{j};
        spkix = ismember(obj.clu{probe}(curClu).trial, trix);
        
        N = histc(obj.clu{probe}(curClu).trialtm_aligned(spkix), edges);
        N = N(1:end-1);
        
        obj.psth(:,i,j) = mySmooth(N./numel(trix)./dt, smooth);  % trial-averaged separated by trial type
        
    end
end

% get single trial data
obj.trialpsth = zeros(numel(time),numel(cluid),obj.bp.Ntrials);
for i = 1:numel(cluid)
    curClu = cluid(i);
    for j = 1:obj.bp.Ntrials
        
        spkix = ismember(obj.clu{probe}(curClu).trial, j);
        
        N = histc(obj.clu{probe}(curClu).trialtm_aligned(spkix), edges);
        N = N(1:end-1);
        if size(N,2) > size(N,1)
            N = N'; % make sure N is a column vector
        end
        
        obj.trialpsth(:,i,j) = mySmooth(N./dt,smooth);
        
    end
end


end % getSeq
%%
function [obj,cluid] = removeLowFRClusters(obj,cluid,lowFR)
% % Remove low-firing rate units, e.g., all those firing less than 5
%   spikes per second on average across all trials.
%
%   The fitted observation noise (diagonal element of R) for a
%   low-firing rate unit will be small, so the neural trajectory may
%   show a deflection each time the neuron spikes.

meanFRs = mean(mean(obj.psth,3));
use = meanFRs > lowFR;

% remove low fr clusters
cluid = cluid(use);
obj.psth = obj.psth(:,use,:);
obj.trialpsth = obj.trialpsth(:,use,:);

end % removeLowFRClusters
%%
function trials = getTrialsForModeID(h,cond)

obj = h.obj;

varnames = getStructVarNames(h);
for i = 1:numel(varnames)
    eval([varnames{i} ' = obj.bp.' varnames{i} ';']);
    
    if eval(['numel(' varnames{i} ')==obj.bp.Ntrials && isrow(' varnames{i} ')'])
        eval([varnames{i} '=' varnames{i} ''';']);
    end
end

trials.N = numel(cond);
trials.ix = zeros(obj.bp.Ntrials, trials.N);
for i = 1:numel(cond)
    curfilt = cond{i};
    trials.ix(:,i) = eval(curfilt);
end
end % getTrials



















