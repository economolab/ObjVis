function probeSelect(~, ~, fig)

h = guidata(fig);

probe = get(h.probeList, 'Value');

Nunits = numel(h.obj.clu{probe});

str = cell(Nunits, 1);
for i = 1:Nunits
    nspikes = numel(h.obj.clu{probe}(i).tm);
    str{i} = ['Unit ' num2str(i) ': ' h.obj.clu{probe}(i).quality ...
              '  #spks: ' num2str(nspikes)];
end
set(h.unitList, 'Value', 1, 'String', str);

updateAxes([], [], fig);
