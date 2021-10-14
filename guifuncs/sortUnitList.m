function sortUnitList(~, ~, fig)
% to get this to actually work, have to change how we get the current unit
% currently not used
h = guidata(fig);

probe = get(h.probeList, 'Value');

Nunits = numel(h.obj.clu{probe});

str = cell(Nunits, 1);
nspikes = zeros(Nunits,1);
for i = 1:Nunits
    nspikes(i) = numel(h.obj.clu{probe}(i).tm);
    str{i} = ['Unit ' num2str(i) ': ' h.obj.clu{probe}(i).quality ...
              '  #spks: ' num2str(nspikes(i))];
end
[~,idx] = sort(nspikes,'descend');
set(h.unitList, 'Value', 1, 'String', str(idx));

