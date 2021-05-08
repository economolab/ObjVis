function filterInfo(~, ~, fig)

h = guidata(fig);

varnames = getStructVarNames(h);

f = figure(2352);

set(f, 'Units', 'Normalized', 'Position', [0.85 0.05 0.125 0.8]);
uicontrol(f, 'Style', 'listbox', 'Units', 'Normalized', 'Position', ...
    [0.05 0.05 0.9 0.9], 'String', varnames , 'Value', 1, 'BackgroundColor', [1 1 1], ...
    'Max', 3, 'Min', 1);

