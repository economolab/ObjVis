function loadObject(~, ~, fig)

h = guidata(fig);

[fn, pth] = uigetfile('*.mat', 'Select Object File');
if numel(pth) == 1
    return;
end

tmp = load(fullfile(pth, fn));
h.obj = tmp.obj;
clear tmp;

Nprobes = numel(h.obj.clu);

str = cell(Nprobes, 1);
for i = 1:Nprobes
    str{i} = ['Probe ' num2str(i)];
end
set(h.probeList, 'Value', 1, 'String', str);


Ncam = numel(h.obj.traj);
for i = 1:Ncam
    str{i} = ['Camera ' num2str(i)];
end
set(h.cameraList, 'Value', 1, 'String', str);

h.datafn = fullfile(pth, fn);

% get event names for aligning data
f = h.obj.bp.ev;
tempNames = fieldnames(f);
% only get events that are stored in doubles (can handle cells later)
j = 1;
for i = 1:numel(tempNames)
    if ~iscell(h.obj.bp.ev.(tempNames{i}))
        eventNames{j} = tempNames{i};
        j = j + 1;
    end
end
eventNames{end+1} = 'moveOnset';
eventNames{end+1} = 'firstLick';
eventNames{end+1} = 'lastLick';
set(h.alignMenu, 'Value', 1, 'String', eventNames);

guidata(fig, h);
probeSelect([], [], fig);
updateBehav([], [], fig);
cameraSelect([], [], fig);