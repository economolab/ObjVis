function tableChange(~, ~, fig)

h = guidata(fig);

varnames = getStructVarNames(h);
for i = 1:numel(varnames)
    eval([varnames{i} ' = h.obj.bp.' varnames{i} ';']);
    
    if eval(['numel(' varnames{i} ')==h.obj.bp.Ntrials && isrow(' varnames{i} ')'])
        eval([varnames{i} '=' varnames{i} ''';']);
    end
end

h.filt.N = size(h.filterTable.Data, 1);
h.filt.clr = zeros(h.filt.N, 3);
h.filt.ix = zeros(h.obj.bp.Ntrials, h.filt.N);

for i = 1:h.filt.N
    
    filt = h.filterTable.Data{i, 1};
    h.filt.ix(:, i) = eval(filt);
    
    h.filt.clr(i,:) = [h.filterTable.Data{i, 2} h.filterTable.Data{i, 3} h.filterTable.Data{i, 4}];
    
    if any(h.filt.clr(i,:)>1) || any(h.filt.clr(i,:)<0)
        h.filt.clr(i,:) = [0 0 0];
        h.filterTable.Data{i, 2} = 0;
        h.filterTable.Data{i, 3} = 0;
        h.filterTable.Data{i, 4} = 0;
    end
end

guidata(fig, h);

updateAxes([], [], fig);
updateBehav([], [], fig);
updateVideo([], [], fig);