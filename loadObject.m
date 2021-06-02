function loadObject(~, ~, fig)
global spkOffset
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

for i = 1:numel(h.obj.clu)
    for j = 1:numel(h.obj.clu{i})
        h.obj.clu{i}(j).trialtm = h.obj.clu{i}(j).trialtm - spkOffset;
        
    end
end

h.datafn = fullfile(pth, fn);

guidata(fig, h);
probeSelect([], [], fig);
updateBehav([], [], fig);
cameraSelect([], [], fig);