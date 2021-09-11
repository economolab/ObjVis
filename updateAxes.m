function updateAxes(~, ~, fig)
h = guidata(fig);

if ~isfield(h, 'filt')
    tableChange([], [], fig);
end

if ~ishandle(h.fig(2))
    initPlots(h.fig(1));
    h = guidata(fig);
end

probe = get(h.probeList, 'Value');
unit = get(h.unitList, 'Value');

clu = h.obj.clu{probe}(unit);

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

if tmin>=tmax
    tmin = 0;
    tmax = 5;
    
    set(h.tmin, 'String', num2str(tmin));
    set(h.tmax, 'String', num2str(tmax));
end

updateRaster(fig, clu);
updatePSTH(fig, clu);
updateVideo([],[],fig);
updateISI(fig, clu);
updateWav(fig, clu);
figure(h.fig(1))

if h.linkAxes.Value && (h.feat_popupmenu(1).Value==1)
    linkaxes(h.ax(1:4), 'x');
else
    linkaxes(h.ax(1:3), 'x');
end

set(h.ax, 'XGrid', 'On', 'YGrid', 'On');
set(h.ax, 'FontSize', 12);





