function saveModeSettings(~, ~, fig)

p = guidata(fig);
h = guidata(p.parentfig);

cdat = get(p.condTable, 'Data');
pdat = get(p.projTable, 'Data');
comp = get(p.modeComputation, 'String');
fRate = get(p.lowFR, 'String');
quality = get(p.quality, 'Value');



[defdir, deffn] = fileparts(h.datafn);
outfn = fullfile(defdir, [deffn '_modes-' date '.mat']);
[fn,pth] = uiputfile('*.mat','Select file name', outfn);

if ~fn
    return
end

save(fullfile(pth, fn), 'cdat','pdat','comp','fRate','quality');
