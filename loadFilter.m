function loadFilter(~, ~, fig)

h = guidata(fig);

defdir = fileparts(h.datafn);

[fn,pathnm] = uigetfile('*.mat','Select file name', defdir);
if length(fn)<2
    return;
end

S = load(fullfile(pathnm, fn));
set(h.filterTable, 'Data', S.tabdat);


guidata(fig, h);
tableChange([], [], fig);