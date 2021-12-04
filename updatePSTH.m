function updatePSTH(fig, clu)

h = guidata(fig);

cla(h.ax(2))

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

dt = 0.005;
edges = tmin:0.005:tmax;

tm = edges + dt./2;
tm = tm(1:end-1);

hold(h.ax(2), 'on');

sm = str2double(get(h.smoothing, 'String'));

psth = zeros(numel(tm), h.filt.N);
stdev = zeros(numel(tm), h.filt.N);
for i = 1:h.filt.N
    
    if ~h.filterTable.Data{i, 5}
        continue;
    end
   
    trix = find(h.filt.ix(:,i));
    spkix = ismember(clu.trial, trix);
    
    if h.align
        N = histc(clu.trialtm_aligned(spkix), edges);
    else
        N = histc(clu.trialtm(spkix), edges);
    end
    
    N = N(1:end-1);
    

    if size(N,1) < size(N,2)
        N = N';
    end
    
    psth(:,i) = MySmooth(N./numel(trix)./dt, sm);

    if ~h.filterTable.Data{i, 6}
        %  plot psth alone (no error bars)
        plot(h.ax(2), tm, psth(:, i), '-', 'Linewidth', 2, 'Color', h.filt.clr(i,:));
    else
        % plot psth + error bars from single trial data
        trialpsth = zeros(numel(tm), numel(trix));
        for j = 1:numel(trix)
            
            spkix = ismember(clu.trial, trix(j));
            
            if h.align
                N = histc(clu.trialtm_aligned(spkix), edges);
            else
                N = histc(clu.trialtm(spkix), edges);
            end
            N = N(1:end-1);
            if size(N,2) > size(N,1)
                N = N'; % make sure N is a column vector
            end
            
            trialpsth(:,j) = mySmooth(N./dt,sm);
            
        end
        stdev(:,i) = std(trialpsth,[],2);
        
        shadedErrorBar(tm, psth(:,i), stdev(:,i), {'Color',h.filt.clr(i,:),'LineWidth',2},0.5, h.ax(2));
    end
    
    hold(h.ax(2), 'on');
    axis(h.ax(2), 'tight');
    
end

sample = median(h.obj.bp.ev.sample(any(h.filt.ix, 2)));
delay = median(h.obj.bp.ev.delay(any(h.filt.ix, 2)));
goCue = median(h.obj.bp.ev.goCue(any(h.filt.ix, 2)));

yl = ylim(h.ax(2));

if ~h.align
    plot(h.ax(2), [sample sample], yl, 'c-', 'LineWidth', 1);
    plot(h.ax(2), [delay delay], yl, 'c-', 'LineWidth', 1);
    plot(h.ax(2), [goCue goCue], yl, 'k-', 'LineWidth', 1);
else
     plot(h.ax(1), [0 0], yl, 'k-', 'LineWidth', 1);
end

ylabel(h.ax(2), 'Firing rate (Hz)');
title(h.ax(2), h.unitList.String{h.unitList.Value});

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));
xlim(h.ax(2), [tmin, tmax]);

