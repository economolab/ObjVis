function preprocessed = preprocess_null_potent(tag)
% smooth, normalize, mean-center the data
% get covariance matrices of preparatory and movement epochs

%% get trial-averaged psths for all cells, separated by trial type, and smooth

smooth_window = 500;
% trial-avg psths of all cells in format {tt1_psth, tt2_psth, ...}, 
% tt - trial type
% psth = (time,cells)
psth = get_psth(tag,smooth_window);

% remove any cells (columns) that have nans or infs (shouldn't be any)
psth = remove_inf_nan_cells(psth);

psth_tavg = psth;

%% soft-normalize 
% firing rate of a neuron, x in (t,1), is transformed as:
% x_norm = x / (lambda + max(x) - min(x))
lambda = 1 / 100; % spike rate times delta t
psth = cellfun(@(x) x./(lambda+max(x)-min(x)),psth,'UniformOutput',false);
% regular z-scoring
% psth = cellfun(@(x) normalize(x),psth,'UniformOutput',false);

%% mean-center
% compute mean activity of each neuron across conditions at each time point
% subtract mean from each condition's response
psth = mean_center(psth); % mean-center across conditions

%% define epochs
prepInterval = 1; % defined as number of seconds before move onset to move onset
moveInterval = 1; % defined as move onset to number of seconds after move onset
dt = tag.dt; % time step
[prepIdx,moveIdx] = get_epochs(tag,prepInterval,moveInterval,dt);

% combine data
% Nprep = [left_psth(prepIdx,:);right_psth(prepIdx,:)] (ct,n)
% Nmove = [left_psth(moveIdx,:);right_psth(moveIdx,:)]
[N,time] = split_data({psth{1},psth{2}},prepIdx,moveIdx,dt); % previously N,time

%% get covariance matrices
C = cellfun(@(x) cov(x), N, 'UniformOutput', false);  %{prep,move}

% cutout = 0.001;

% figure(1001)
% for i = 1:numel(C)
%     subplot(1,2,i)
%     plot_cov(C{i},cutout); 
%     if i==1; title('Prep Epoch Covariance'); 
%     else; title('Move Epoch Covariance'); end
% end

%% save

tag.tavg_psth = psth_tavg;
tag.psth = psth;
tag.cov = C; % {prep,move}

preprocessed = tag;

end % preprocess_null_potent

%% Helper Functions

function psth = get_psth(tag,smooth_window)
% get psths for every cluster, separated by trial type
    psth = cell(1,numel(tag.trialTypes));
    % for every trial type
    for tt = 1:numel(psth)
        psth{tt} = zeros(numel(tag.time),numel(tag.psth));
        % for every cluster
        for clu = 1:numel(tag.psth)
            psth{tt}(:,clu) = MySmooth(mean(tag.psth{clu}{tt},2),smooth_window);
        end
    end

end % get_psth


function psth_norm = my_normalize(psth,tag)
% firing rate of a neuron, x in (t,1), is normalized as:
% x_norm = (x - mean(x(baselineIdx)) / std(x(baselineIdx))
    % get baseline idx from tag
    baselineIdx = tag.epoch.ix{1};
    psth_norm = cell(1,numel(psth));
    for tt = 1:numel(psth) % for each trial type
        psth_norm{tt} = zeros(size(psth{tt}));
        for cellIdx = 1:size(psth{tt},2) % for every cell
            mu = mean(psth{tt}(baselineIdx,cellIdx));
            stdev = std(psth{tt}(baselineIdx,cellIdx));
            psth_norm{tt}(:,cellIdx) = (psth{tt}(:,cellIdx) - mu) / stdev;
        end
    end
end % my_normalize

function [prepIdx,moveIdx] = get_epochs_full(tag,prepInterval,moveInterval,dt)
% get the time index of the prep and move epochs
    prepInterval = prepInterval / dt; 
    moveInterval = moveInterval / dt; 
    % find index of go cue
    [~,t0_idx] = min(abs(tag.time-0));
    % define epochs relative to go cue index
    prepIdx = floor(t0_idx-prepInterval:t0_idx);
    moveIdx = floor(t0_idx:t0_idx+moveInterval);
end % get_epochs_full

function [prepIdx,moveIdx] = get_epochs(tag,prepInterval,moveInterval,dt)
% get the time index of the prep and move epochs
    prepInterval = prepInterval / dt; 
    moveInterval = moveInterval / dt; 
    % find index of move onset
    [~,t0_idx] = min(abs(tag.time-0));
    % define epochs relative to move onset index
    % +/- 1 just for some padding around move onset
    prepIdx = floor(t0_idx-prepInterval:t0_idx);
    moveIdx = floor(t0_idx:t0_idx+moveInterval);
end % get_epochs

function [N,time] = split_data(psth,prepIdx,moveIdx,dt)
% combine data such that 
% Nprep = [left_psth(prepIdx,:);right_psth(prepIdx,:)] (ct,n)
% Nmove = [left_psth(moveIdx,:);right_psth(moveIdx,:)]
% N = {Nprep,Nmove}
    N = cell(1,2);
    N{1} = [psth{1}(prepIdx,:);psth{2}(prepIdx,:)]; % prep
    N{2} = [psth{1}(moveIdx,:);psth{2}(moveIdx,:)]; % move
% return a new time vector
    time = -(length(prepIdx)*dt):dt:0;
    time = [time dt:dt:((length(moveIdx)*dt)-dt)];
end % split_data

function psth_scrubbed = remove_inf_nan_cells(psth)
    psth_scrubbed = cell(1,numel(psth));
    for tt = 1:numel(psth)
        [~,c_nan] = find(isnan(psth{tt}));
        [~,c_inf] = find(isinf(psth{tt}));
        to_delete = unique([c_nan,c_inf]);
        psth{tt}(:,to_delete) = [];
        psth_scrubbed{tt} = psth{tt};
    end
end % remove_inf_nan_cells

function plot_cov(data,cutout)
    num_to_cut = ceil( numel(data) * cutout / 2);
    sorted_data = sort(data(:));
    cmin = sorted_data( num_to_cut );
    cmax = sorted_data( end - num_to_cut + 1);
    imagesc(data, [cmin, cmax]);
    colorbar;
end % plot_cov

function centered = mean_center(psth)
% compute mean activity of each neuron across conditions at each time point
% subtract mean from each condition's response
    centered = psth;
    for cluIdx = 1:size(psth{1},2)
        for t = 1:size(psth{1},1)
            % mean across conditions at time t
            mean_cond_t = mean( [psth{1}(t,cluIdx) psth{2}(t,cluIdx)] );
            centered{1}(t,cluIdx) = centered{1}(t,cluIdx) - mean_cond_t;
            centered{2}(t,cluIdx) = centered{2}(t,cluIdx) - mean_cond_t;
        end
    end
end % mean_center















