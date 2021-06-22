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

psth = zeros(length(tm),numel(h.obj.clu{probe}));
ttPSTH = zeros(length(tm),numel(h.obj.clu{probe}),numel(h.filt.N));
for clu = 1:numel(h.obj.clu{probe})
    for i = 1:h.filt.N
        
        trix = find(h.filt.ix(:,i));
        spkix = ismember(h.obj.clu{probe}(clu).trial, trix);

        if h.align
            N = histc(h.obj.clu{probe}(clu).trialtm_aligned(spkix), edges);
        else
            N = histc(h.obj.clu{probe}(clu).trialtm(spkix), edges);
        end

        N = N(1:end-1);

        ttPSTH(:,clu,i) = MySmooth(N./numel(trix)./dt, sm);  % trial-averaged separated by trial type
    end
end

psth = mean(ttPSTH,3); % trial-averaged over all trial types

% perform pca on trial-averaged data, plot projections
[~,proj,~,~,explained] = pca(psth);
figure;
plot(tm, proj(:,1:5))
legend(string(explained(1:5)))

% perform pca on trial-averaged data separated by trial type, plot
% projections
proj = zeros(length(tm),numel(h.obj.clu{probe}),numel(h.filt.N));
figure;
for i = 1:h.filt.N
    [~,proj(:,:,i),~,~,explained] = pca(ttPSTH(:,:,i));
    subplot(h.filt.N,1,i)
    plot(tm, proj(:,1:5,i))
    legend(string(explained(1:5)))
end

end % my_pca

