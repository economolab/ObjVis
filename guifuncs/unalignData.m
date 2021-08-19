function unalignData(~, ~, fig)

h = guidata(fig);
h.align = 0;

guidata(h.fig(1), h);

probe = get(h.probeList, 'Value');
unit = get(h.unitList, 'Value');

clu = h.obj.clu{probe}(unit);

updateRaster(fig, clu);
updatePSTH(fig, clu);

end % alignData