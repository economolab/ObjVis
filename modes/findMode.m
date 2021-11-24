function findMode(~,~,fig)
p = guidata(fig);
h = guidata(p.parentfig);

% PARSE GUI DATA
probe = h.probeList.Value;


tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

dt = 0.005;
edges = tmin:dt:tmax;
time = edges + dt/2;
time = time(1:end-1);

ctable = p.condTable.Data;
ptable = p.projTable.Data;

modeConditions = ctable(:, 1);
modetmin = cell2mat(ctable(:, 2));
modetmax = cell2mat(ctable(:, 3));
modeAlign = ctable{1, 4};
use = ~cellfun(@isempty, modeConditions);

modeConditions = modeConditions(use);
modetmin = modetmin(use);
modetmax = modetmax(use);

projConditions = ptable(:,1);
use = ~cellfun(@isempty, projConditions);

projConditions = projConditions(use);
clrs = cell2mat(ptable(use, 2:4));

projAlign = ptable{1, 5};

computation = p.modeComputation.String;
quality = p.quality.String(p.quality.Value)'; %????
smooth = str2double(get(h.smoothing, 'String'));
lowFR = str2double(get(p.lowFR,'String'));


% PREPROCESS
% get trials to use (for projections)
trialid = findTrials(h, projConditions);
% get clusters to use (for everything)
cluQuality = {h.obj.clu{probe}(:).quality}';
cluid = findClusters(cluQuality, quality);

% align spikes to go cue
modeobj = alignSpikes(h.obj,probe,modeAlign);
projobj = alignSpikes(h.obj,probe,projAlign);
% get trial avg psth and single trial data
modeobj = getSeq(modeobj,edges,time,dt,probe,cluid,trialid,projConditions,smooth);
projobj = getSeq(projobj,edges,time,dt,probe,cluid,trialid,projConditions,smooth);

% remove low fr clusters
modeuse = findLowFRClusters(modeobj,lowFR);
projuse = findLowFRClusters(projobj,lowFR);

use = modeuse | projuse;

[modeobj,~] = removeLowFRClusters(modeobj,use,cluid);
[projobj,cluid] = removeLowFRClusters(projobj,use,cluid);



% FIND MODE
% get trials to use (for mode)
trials = getTrialsForModeID(h,modeConditions);
% slice trialpsth from modetmin to modetmax and find mean during time
% period for all trials and modeConditions
e1 = zeros(trials.N, 1);
e2 = zeros(trials.N, 1);
nTrialsCond = sum(trials.ix);
epochMean = nan(numel(cluid),max(nTrialsCond),trials.N); % (clu,trials,cond)

for i = 1:trials.N
    [~,e1(i)] = min(abs(time - modetmin(i)));
    [~,e2(i)] = min(abs(time - modetmax(i)));
    nTrials = nTrialsCond(i);
    epochMean(:,1:nTrials,i) = squeeze(nanmean(modeobj.trialpsth(e1(i):e2(i),:,logical(trials.ix(:,i))),1));
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

lat.single = nan(size(projobj.trialpsth, 1), size(projobj.trialpsth, 3));
lat.avg = nan(size(projobj.trialpsth, 1), numel(projConditions));

if get(p.singleTrialCheckbox, 'Value')
    for j = 1:size(projobj.trialpsth, 3)
        ts = projobj.trialpsth(:,:,j);
        lat.single(:, j) = MySmooth(ts*cd,smooth);
    end
end

if get(p.singleTrialCheckbox, 'Value')
    for j = 1:size(projobj.trialpsth, 3)
        for i = 1:numel(projConditions)
            if ismember(j, trialid{i})
                c = clrs(i, :);
                c = c+(1-c)*0.5;
                plot(p.modeax(1),time,lat.single(:,j),'LineWidth',0.5, 'Color', c);
                hold on;
            end
        end
    end
end

for i = 1:numel(projConditions)
    lat.avg(:,i) = MySmooth(projobj.psth(:,:,i)*cd,smooth);
end

for i = 1:numel(projConditions)
    plot(p.modeax(1),time,lat.avg(:,i),'LineWidth',2, 'Color', clrs(i,:));
    hold on;
end
xline(sample,'k--','LineWidth',0.5);
xline(delay,'k--','LineWidth',0.5);
xline(zeroEv,'k--','LineWidth',0.5);
xlim([time(1),time(end)])
% legend(projConditions,'Location','best');
hold off

% % 
derivthresh = 0.3;  %If the velocity of the jaw crosses this threshold, the jaw is considered to be moving
jaw = nan(numel(edges), size(modeobj.trialpsth, 3));

traj = h.obj.traj{1};
for i = 1:size(modeobj.trialpsth, 3)
    if isnan(traj(i).NdroppedFrames )
        continue;
    end
    ts = MySmooth(traj(i).ts(:, 2, 2), 21);
    tsinterp = interp1(traj(i).frameTimes-0.5-mode(h.obj.bp.ev.goCue), ts, edges);   %Linear interpolation of jaw position to keep number of time points consistent across trials
    basederiv = nanmedian(diff(tsinterp));          %Find the median jaw velocity (aka baseline)
    
    %Find when the difference between the jaw velocity and the
    %baseline jaw
    %velocity is above a given threshold (when is jaw moving?)
    jaw(2:end, i) = abs(diff(tsinterp)-basederiv);%
end

ix = 400:600;
jawVel = mean(jaw(ix, :), 1);
proj = mean(lat.single(ix, :), 1);


figure; hold on;
plot(jawVel(trialid{1}), proj(trialid{1}), 'b.');
plot(jawVel(trialid{2}), proj(trialid{2}), 'r.');
xlabel('Avg jaw velocity');
ylabel('Choice mode');
legend('R trials','L trials');


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
    tmp = obj.bp.autowater.nums;
    obj.bp.autowater = rmfield(obj.bp.autowater,'nums');
    obj.bp.autowater = tmp;
end

varnames = getStructVarNames(h);
for i = 1:numel(varnames)
    eval([varnames{i} ' = obj.bp.' varnames{i} ';']);
    
    if eval(['numel(' varnames{i} ')==obj.bp.Ntrials && isrow(' varnames{i} ')'])
        eval([varnames{i} '=' varnames{i} ''';']);
    end
end

mask = zeros(obj.bp.Ntrials, numel(conditions));

if isfield(autowater, 'nums')
    tmp = autowater.nums;
    autowater = rmfield(autowater, 'nums');
    autowater = tmp + (tmp-1)*-2;
end

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
        if size(N,1) < size(N,2)
            N = N';
        end
        obj.psth(:,i,j) = MySmooth(N./numel(trix)./dt, smooth);  % trial-averaged separated by trial type
        
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

        obj.trialpsth(:,i,j) = MySmooth(N./dt,smooth);

    end
end


end % getSeq
%%
function use = findLowFRClusters(obj,lowFR)
% % Remove low-firing rate units, e.g., all those firing less than 5
%   spikes per second on average across all trials.
%
%   The fitted observation noise (diagonal element of R) for a
%   low-firing rate unit will be small, so the neural trajectory may
%   show a deflection each time the neuron spikes.

meanFRs = mean(mean(obj.psth,3));
use = meanFRs > lowFR;

end % removeLowFRClusters

function [obj,cluid] = removeLowFRClusters(obj,use,cluid)
% % Remove low-firing rate units, e.g., all those firing less than 5
%   spikes per second on average across all trials.
%
%   The fitted observation noise (diagonal element of R) for a
%   low-firing rate unit will be small, so the neural trajectory may
%   show a deflection each time the neuron spikes.

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



















