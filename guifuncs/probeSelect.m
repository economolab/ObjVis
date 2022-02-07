function probeSelect(~, ~, fig)

h = guidata(fig);

probe = get(h.probeList, 'Value');

% if you change probes, let's assume that the data is not aligned/warped
h.aligned = 0;
h.warped = 0;

Nunits = numel(h.obj.clu{probe});

str = cell(Nunits, 1);
nspikes = zeros(Nunits,1);
for i = 1:Nunits
    nspikes(i) = numel(h.obj.clu{probe}(i).tm);
    str{i} = ['Unit ' num2str(i) ': ' h.obj.clu{probe}(i).quality ...
              '  #spks: ' num2str(nspikes(i))];
end
set(h.unitList, 'Value', 1, 'String', str);

updateAxes([], [], fig);
