function reformatted = reformatObj(h)
% input: h -> guidate
% output: reformatted, struct of all psths trial separated by currently
% specified filters in ObjVis controls

trials = getTrialsToUse(h);

probe = get(h.probeList, 'Value');
clusters = getClustersToUse(h.obj,probe);

dt = 0.005; 

% how many seconds before and after move onset to get psths
moveOnset = findMoveOnset(h.obj);
beforeMove = 4;
afterMove = 4;
numTimepoints = length([-beforeMove:dt:afterMove]);
psth = get_psth(h.obj,dt,numTimepoints,trials,clusters, ...
                moveOnset,beforeMove,afterMove); % {numClusters,1} -> each entry is {1xnumTrialTypes}
    
tag.psth = psth;
tag.time = -beforeMove:dt:afterMove;
tag.dt = dt;
tag.trials = trials;
tag.trialTypes = {h.filterTable.Data{:,1}};
tag.clusters = clusters;
tag.moveOnset = moveOnset;

reformatted = tag;

end

function trialsToUse = getTrialsToUse(h)
    % change this so that filters are inputs
    
    trialsToUse = cell(1,size(h.filt.ix,2));
    for i = 1:numel(trialsToUse)
        trialsToUse{i} = find(h.filt.ix(:,i));
    end
    
end % getTrialsToUse

function clustersToUse = getClustersToUse(obj,probe)
% get clusters of quality not equal to 'Poor' to use for analysis
    numClusters = numel(obj.clu{probe});
    clustersToUse = zeros(1,numClusters);
    ct = 1;
    for cluster = 1:numClusters
        if ~strcmp(obj.clu{1}(cluster).quality,'Poor')
            clustersToUse(ct) = cluster;
            ct = ct + 1;
        end
    end
    % remove unused space
    clustersToUse(clustersToUse==0) = [];    
end % getClustersToUse

function psth = get_psth(obj,dt,ntime,trials,clusters,moveOn,before,after)
    numClusters = length(clusters);
    psth = cell(numClusters, 1); 
    for cluIdx = 1:numClusters
        cluster = clusters(cluIdx);
        psth{cluIdx} = cell(1,numel(trials)); 
        data = obj.clu{1}(cluster);
        for tt = 1:numel(trials) % trial type 
            psth{cluIdx}{tt} = zeros(ntime,numel(trials{tt}));
            for trialIdx = 1:numel(trials{tt})
                trial = trials{tt}(trialIdx);
                moveonset = moveOn(trial);
                if isnan(moveonset)
                    moveonset = obj.bp.ev.goCue(trial);
                end
%                 moveonset = obj.bp.ev.goCue(trial);  %align all to go cue
                time = (moveonset-before):dt:(moveonset+after);
                trialtm = data.trialtm(ismember(data.trial, trial));
                psth{cluIdx}{tt}(:,trialIdx) = histc(trialtm,time);
            end
        end
    end
end
