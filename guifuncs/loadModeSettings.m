function loadModeSettings(~, ~, fig)
p = guidata(fig);
h = guidata(p.parentfig);

defdir = fileparts(h.datafn);

[fn,pathnm] = uigetfile('*.mat','Select file name', defdir);
if length(fn)<2
    return;
end

S = load(fullfile(pathnm, fn));


set(p.condTable, 'Data', S.cdat);
set(p.projTable, 'Data', S.pdat);
set(p.modeComputation, 'String', S.comp);
set(p.lowFR, 'String', S.fRate);
set(p.quality, 'Value', S.quality);

guidata(fig, p);
