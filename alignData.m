function alignData(~, ~, fig)

h = guidata(fig);
h.align = 1;

probe = get(h.probeList, 'Value');
evList = get(h.alignMenu, 'String');
evName = evList{get(h.alignMenu, 'Value')};
if strcmp(evName,'moveOnset')
    h.obj.bp.ev.(evName) = findMoveOnset(h.obj);
end

% create a spiketm vector aligned to event specified in popup menu
for clu = 1:numel(h.obj.clu{probe})
    event = zeros(length(h.obj.clu{probe}(clu).trial),1);
    for t = 1:numel(event)
        event(t) = h.obj.bp.ev.(evName)(h.obj.clu{probe}(clu).trial(t));
    end
    h.obj.clu{probe}(clu).trialtm_aligned = h.obj.clu{probe}(clu).trialtm - event;
end

guidata(h.fig(1), h);

probe = get(h.probeList, 'Value');
unit = get(h.unitList, 'Value');

clu = h.obj.clu{probe}(unit);

updateRaster(fig, clu);


end % alignData