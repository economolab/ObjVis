function [psth,tm] = getPSTH(fig,varargin)
% inputs: fig
%         vargin -> clu

h = guidata(fig);
probe = get(h.probeList, 'Value');
tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));
dt = 0.005;
edges = tmin:0.005:tmax;
tm = edges + dt./2;
tm = tm(1:end-1);
sm = str2double(get(h.smoothing, 'String'));

if nargin > 1
    clu = varargin{1};
    % if 2nd input specified (should be a numeric unit number), then get
    % psth for that cluster only
    ttPSTH = zeros(length(tm),numel(h.filt.N));
    for i = 1:h.filt.N

        trix = find(h.filt.ix(:,i));
        spkix = ismember(h.obj.clu{probe}(clu).trial, trix);

        if h.align
            N = histc(h.obj.clu{probe}(clu).trialtm_aligned(spkix), edges);
        else
            N = histc(h.obj.clu{probe}(clu).trialtm(spkix), edges);
        end

        N = N(1:end-1);

        ttPSTH(:,i) = MySmooth(N./numel(trix)./dt, sm);  % trial-averaged separated by trial type
    end
    
    psth = ttPSTH;
    
else
    % get trial-averaged psth for each filter for all clusters

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
    
    psth = ttPSTH;

end

end % getPSTH



