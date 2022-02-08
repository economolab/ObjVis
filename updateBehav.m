function updateBehav(~, ~, fig)

h = guidata(fig);

if ~isfield(h, 'filt')
    tableChange([], [], fig);
    h = guidata(fig);
end

ev = h.obj.bp.ev;

hold(h.ax(3), 'off');
trialOffset = 0;

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

for i = h.filt.N:-1:1
    
    if ~h.filterTable.Data{i, 5}
        continue;
    end
    
    trix = find(h.filt.ix(:,i));
    
    for j = 1:numel(trix)
        trialOffset = trialOffset+1;
                    
        lickL =  ev.lickL{trix(j)};
        lickR =  ev.lickR{trix(j)};
        
        sample = h.obj.bp.ev.sample(trix(j));
        delay = h.obj.bp.ev.delay(trix(j));
        goCue = h.obj.bp.ev.goCue(trix(j));
        
        
        if h.align && h.psthDataList.Value == 2
            evName = h.alignMenu.String{h.alignMenu.Value};
            plot(h.ax(3), [sample-ev.(evName)(trix(j)) sample-ev.(evName)(trix(j))], trialOffset+[-0.5 0.5], 'c-', 'LineWidth', 1);
            plot(h.ax(3), [delay-ev.(evName)(trix(j)) delay-ev.(evName)(trix(j))], trialOffset+[-0.5 0.5], 'c-', 'LineWidth', 1);
            plot(h.ax(3), [goCue-ev.(evName)(trix(j)) goCue - ev.(evName)(trix(j))], trialOffset+[-0.5 0.5], 'y-', 'LineWidth', 1);
            
            if ~isempty(lickL)
                plot(h.ax(3), lickL-ev.(evName)(trix(j)) , trialOffset*ones(size(lickL)), '.', 'Color', h.filt.clr(i,:));
            end

            if ~isempty(lickR)
                plot(h.ax(3), lickR-ev.(evName)(trix(j)), trialOffset*ones(size(lickR)), '.', 'Color', h.filt.clr(i,:));
            end
        else
            plot(h.ax(3), [sample sample], trialOffset+[-0.5 0.5], 'c-', 'LineWidth', 1);
            plot(h.ax(3), [delay delay], trialOffset+[-0.5 0.5], 'c-', 'LineWidth', 1);
            plot(h.ax(3), [goCue goCue], trialOffset+[-0.5 0.5], 'y-', 'LineWidth', 1);
            
            if ~isempty(lickL)
                plot(h.ax(3), lickL, trialOffset*ones(size(lickL)), '.', 'Color', h.filt.clr(i,:));
            end

            if ~isempty(lickR)
                plot(h.ax(3), lickR, trialOffset*ones(size(lickR)), '.', 'Color', h.filt.clr(i,:));
            end
        end
        
        hold(h.ax(3), 'on');
        
        
    end
    plot(h.ax(3), [tmin tmax], 0.5+trialOffset+[0 0], '-', 'LineWidth', 2, 'Color', [0.5 0.5 0.5]);

end
axis(h.ax(3), 'tight');

xlim(h.ax(3), [tmin, tmax]);
set(h.ax(3), 'XGrid', 'On', 'YGrid', 'On');