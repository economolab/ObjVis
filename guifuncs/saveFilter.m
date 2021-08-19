function saveFilter(~, ~, fig)

h = guidata(fig);
tabdat = get(h.filterTable, 'Data');

[defdir, deffn] = fileparts(h.datafn);
outfn = fullfile(defdir, [deffn '_filters-' date '.mat']);
[fn,pth] = uiputfile('*.mat','Select file name', outfn);

if ~fn
    return
end

save(fullfile(pth, fn), 'tabdat');
