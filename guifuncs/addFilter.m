function addFilter(~, ~, fig)

h = guidata(fig);

tabdat = get(h.filterTable, 'Data');
rows = size(tabdat, 1);

prompt = {'Enter filter:','Red', 'Green', 'Blue', 'Enable'};
dlgtitle = 'New filter';
dims = [1 35];
definput = {'early', '0', '0', '0', '1'};

answer = inputdlg(prompt,dlgtitle,dims,definput);

newrow{1} = answer{1};
newrow{2} = str2double(answer(2));
newrow{3} = str2double(answer(3));
newrow{4} = str2double(answer(4));
newrow{5} = logical(str2double(answer(5)));

tabdat(rows+1, 1:5) = newrow;
set(h.filterTable, 'Data', tabdat);

guidata(fig, h);
tableChange([], [], fig);