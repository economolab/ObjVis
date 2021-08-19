function removeFilter(~, ~, fig)

h = guidata(fig);

prompt = {'Filter(s) to remove'};
dlgtitle = 'Remove filter';
dims = [1 35];
definput = {'1'};

answer = inputdlg(prompt,dlgtitle,dims,definput);
nums = str2num(answer{1});

tabdat = get(h.filterTable, 'Data');
rows = 1:size(tabdat, 1);

keep = ~ismember(rows, nums);

tabdat = tabdat(keep, :);
set(h.filterTable, 'Data', tabdat);

guidata(fig, h);
tableChange([], [], fig);