function cameraSelect(~, ~, fig)

h = guidata(fig);

camera = get(h.cameraList, 'Value');

Nfeat = numel(h.obj.traj{camera}(1).featNames);

str = cell(Nfeat, 1);
for i = 1:Nfeat
    str{i} = h.obj.traj{camera}(1).featNames{i};
end
set(h.featureList, 'Value', 1, 'String', str);

updateVideo([], [], fig);