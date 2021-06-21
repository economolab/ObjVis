function updateRaster(fig, clu)

h = guidata(fig);

hold(h.ax(1), 'off');
trialOffset = 0;


tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

for i = h.filt.N:-1:1
    
    if ~h.filterTable.Data{i, 5}
        continue;
    end
   
    trix = find(h.filt.ix(:,i));
    [spkix, trialcnt] = ismember(clu.trial, trix);
    
    sample = median(h.obj.bp.ev.sample(trix));
    delay = median(h.obj.bp.ev.delay(trix));
    goCue = median(h.obj.bp.ev.goCue(trix));
    
    if h.align
        plot(h.ax(1), clu.trialtm_aligned(spkix), trialOffset+trialcnt(spkix), '.', 'Color', h.filt.clr(i,:));
    else
        plot(h.ax(1), clu.trialtm(spkix), trialOffset+trialcnt(spkix), '.', 'Color', h.filt.clr(i,:));
    end
    axis(h.ax(1), 'tight');
    hold(h.ax(1), 'on');
    
    if ~h.align
        plot(h.ax(1), [sample sample], [trialOffset trialOffset+numel(trix)], 'c-', 'LineWidth', 1);
        plot(h.ax(1), [delay delay], [trialOffset trialOffset+numel(trix)], 'c-', 'LineWidth', 1);
        plot(h.ax(1), [goCue goCue], [trialOffset trialOffset+numel(trix)], 'k-', 'LineWidth', 1);
    else
         plot(h.ax(1), [0 0], [trialOffset trialOffset+numel(trix)], 'k-', 'LineWidth', 1);
    end
    
    trialOffset = trialOffset+numel(trix);
    plot(h.ax(1), [tmin tmax], 0.5+trialOffset+[0 0], '-', 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);
end

xlim(h.ax(1), [tmin, tmax]);

if h.align
    evList = get(h.alignMenu, 'String');
    evName = evList{get(h.alignMenu, 'Value')};
    xlabel(h.ax(1), ['Time (s) aligned to ' evName]);
else
    xlabel(h.ax(1), 'Time (sec)');
end
ylabel(h.ax(1), 'Trials');




