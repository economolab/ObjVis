function my_pca(~,~,fig)

h = guidata(fig);

% just do pca on all data

% first get trial-averaged psths
probe = get(h.probeList, 'Value');

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

dt = 0.005;
edges = tmin:0.005:tmax;

tm = edges + dt./2;
tm = tm(1:end-1);

sm = str2double(get(h.smoothing, 'String'));

ttPSTH = zeros(length(tm),numel(h.obj.clu{probe}),numel(h.filt.N));
for clu = 1:numel(h.obj.clu{probe})
    for i = 1:h.filt.N
        
        trix = find(h.filt.ix(:,i));
        spkix = ismember(h.obj.clu{probe}(clu).trial, trix);
        if spkix == false
            continue
        elseif isempty(spkix)
            continue
        end

        if h.align
            N = histc(h.obj.clu{probe}(clu).trialtm_aligned(spkix), edges);
        else
            N = histc(h.obj.clu{probe}(clu).trialtm(spkix), edges);
        end

        N = N(1:end-1);
        if size(N,1) < size(N,2)
            N = N';
        end
        
        ttPSTH(:,clu,i) = MySmooth(N./numel(trix)./dt, sm);  % trial-averaged separated by trial type

    end
end

psth = mean(ttPSTH,3); % trial-averaged over all trial types

% perform pca on trial-averaged data, plot projections
[~,proj,~,~,explained] = pca(psth);

nComp = 5;

alphas = maptorange(explained(1:nComp), [min(explained(1:nComp)) max(explained(1:nComp))], [0.35 1]);
widths = maptorange(explained(1:nComp), [min(explained(1:nComp)) max(explained(1:nComp))], [2 4]);
% map = pink;
% clrs = round(maptorange(1:nComp, [1 nComp], [1 size(map,1)]));

figure;
for i = 1:nComp
    f(i) = plot(tm, proj(:,i)); hold on
%     f(i).Color(1:3) = map(clrs(i),:);
    f(i).Color(4) = alphas(i);
    f(i).LineWidth = widths(i);
end
title(['All units projected onto first ' num2str(nComp) ' PCs'])
hold off
xlim([tmin tmax])

end % my_pca

%% Helper Functions

function targetvalue = maptorange(sourcevalue, sourcerange, targetrange, varargin)
%                       Copyright 2017 Laurens R Krol
%                       Team PhyPA, Biological Psychology and Neuroergonomics,
%                       Berlin Institute of Technology

% parsing input
p = inputParser;
addRequired(p, 'sourcevalue', @isnumeric);
addRequired(p, 'sourcerange', @(x) (all(numel(x) == 2) && isnumeric(x)));
addRequired(p, 'targetrange', @(x) (all(numel(x) == 2) && isnumeric(x)));
addParamValue(p, 'restrict', 1, @isnumeric);
addParamValue(p, 'exp', 1, @isnumeric);
parse(p, sourcevalue, sourcerange, targetrange, varargin{:})
restrict = p.Results.restrict;
exp = p.Results.exp;
% mapping
if numel(sourcevalue) > 1
    % recursively calling this function
    for i = 1:length(sourcevalue)
        sourcevalue(i) = maptorange(sourcevalue(i), sourcerange, targetrange, varargin{:});
        targetvalue = sourcevalue;
    end
else
    % converting source value into a percentage
    sourcespan = sourcerange(2) - sourcerange(1);
    if sourcespan == 0, error('Zero-length source range'); end
    valuescaled = (sourcevalue - sourcerange(1)) / sourcespan;
    valuescaled = valuescaled^exp;
    % taking given percentage of target range as target value
    targetspan = targetrange(2) - targetrange(1);
    targetvalue = targetrange(1) + (valuescaled * targetspan);
    if restrict
        % restricting value to the target range
        if targetvalue < min(targetrange)
            targetvalue = min(targetrange);
        elseif targetvalue > max(targetrange)
            targetvalue = max(targetrange);
        end
    end
end
end % maptorange

