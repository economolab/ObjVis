function probeSelect(~, ~, fig)

h = guidata(fig);

probe = get(h.probeList, 'Value');

Nunits = numel(h.obj.clu{probe});

str = cell(Nunits, 1);
for i = 1:Nunits
    str{i} = ['Unit ' num2str(i) ': ' h.obj.clu{probe}(i).quality];
end
set(h.unitList, 'Value', 1, 'String', str);

updateAxes([], [], fig);
