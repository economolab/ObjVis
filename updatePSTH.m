function updatePSTH(fig, clu)

h = guidata(fig);

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

edges = tmin:0.005:tmax;
dt = mean(diff(edges));

tm = edges + dt./2;
tm = tm(1:end-1);

hold(h.ax(2), 'Off');

sm = str2double(get(h.smoothing, 'String'));

for i = 1:h.filt.N
    
    if ~h.filterTable.Data{i, 5}
        continue;
    end
   
    trix = find(h.filt.ix(:,i));
    spkix = ismember(clu.trial, trix);
    
    N = histc(clu.trialtm(spkix), edges);
    N = N(1:end-1);
    
    psth = MySmooth(N./numel(trix)./dt, sm);

    plot(h.ax(2), tm, psth, '-', 'Linewidth', 2, 'Color', h.filt.clr(i,:));
    hold(h.ax(2), 'On');
    axis(h.ax(2), 'tight');
    
end
sample = median(h.obj.bp.ev.sample(any(h.filt.ix, 2)));
delay = median(h.obj.bp.ev.delay(any(h.filt.ix, 2)));
goCue = median(h.obj.bp.ev.goCue(any(h.filt.ix, 2)));

yl = ylim(h.ax(2));

plot(h.ax(2), [sample sample], yl, 'c-', 'LineWidth', 1);
plot(h.ax(2), [delay delay], yl, 'c-', 'LineWidth', 1);
plot(h.ax(2), [goCue goCue], yl, 'k-', 'LineWidth', 1);

ylabel(h.ax(2), 'Firing rate (Hz)');

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));
xlim(h.ax(2), [tmin, tmax]);