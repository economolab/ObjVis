function loadFilter(~, ~, fig)

h = guidata(fig);

defdir = fileparts(h.datafn);

[fn,pathnm] = uigetfile('*.mat','Select file name', defdir);
if length(fn)<2
    return;
end

S = load(fullfile(pathnm, fn));
set(h.filterTable, 'Data', S.tabdat);
h.filt.N = size(h.filterTable.Data, 1);

% get event names for aligning data
f = h.obj.bp.ev;
tempNames = fieldnames(f);
% only get events that are stored in doubles
j = 1;
for i = 1:numel(tempNames)
    if ~iscell(h.obj.bp.ev.(tempNames{i}))
        eventNames{j} = tempNames{i};
        j = j + 1;
    end
end
% add additional events
eventNames{end+1} = 'moveOnset';
eventNames{end+1} = 'firstLick';
eventNames{end+1} = 'lastLick';

% set epoch names in projection table epochs
temp = cell(1,h.filt.N);
temp(:) = {'presample'};
temp = temp;
h.filterTable.Data(:,6) = temp;
epochNames = {'presample' eventNames{2:5}};
h.filterTable.ColumnFormat = ({[],[],[],[],[],epochNames});


guidata(fig, h);
tableChange([], [], fig);