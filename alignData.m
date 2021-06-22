function alignData(~, ~, fig)


h = guidata(fig);

h.align = 1;

probe = get(h.probeList, 'Value');

evList = get(h.alignMenu, 'String');
evName = evList{get(h.alignMenu, 'Value')};
f = msgbox(['Aligning Data to ' evName]);

if strcmp(evName,'moveOnset')
    h.obj.bp.ev.(evName) = findMoveOnset(h.obj);
end
if strcmp(evName,'firstLick')
    % get first lick time for left and right licks
    temp = h.obj.bp.ev.lickL;
    idx = ~cellfun('isempty',temp);
    outL = zeros(size(temp));
    outL(idx) = cellfun(@(v)v(1),temp(idx));
    temp = h.obj.bp.ev.lickR;
    idx = ~cellfun('isempty',temp);
    outR = zeros(size(temp));
    outR(idx) = cellfun(@(v)v(1),temp(idx));
    firstLick = zeros(size(temp));
    % firstLick = min(outL,outR), except when outL||outR == 0
    outL(outL==0) = nan;
    outR(outR==0) = nan;
    firstLick = nanmin(outL,outR);
    firstLick(isnan(firstLick)) = 0;
    h.obj.bp.ev.(evName) = firstLick;
end
if strcmp(evName,'lastLick')
    % get last lick time for left and right licks
    temp = h.obj.bp.ev.lickL;
    idx = ~cellfun('isempty',temp);
    outL = zeros(size(temp));
    outL(idx) = cellfun(@(v)v(end),temp(idx));
    temp = h.obj.bp.ev.lickR;
    idx = ~cellfun('isempty',temp);
    outR = zeros(size(temp));
    outR(idx) = cellfun(@(v)v(end),temp(idx));
    lastLick = zeros(size(temp));
    % firstLick = min(outL,outR), except when outL||outR == 0
    outL(outL==0) = nan;
    outR(outR==0) = nan;
    lastLick = nanmax(outL,outR);
    lastLick(isnan(lastLick)) = 0;
    h.obj.bp.ev.(evName) = lastLick;
end

% create a spiketm vector aligned to event specified in popup menu
for clu = 1:numel(h.obj.clu{probe})
    event = h.obj.bp.ev.(evName)(h.obj.clu{probe}(clu).trial);
    h.obj.clu{probe}(clu).trialtm_aligned = h.obj.clu{probe}(clu).trialtm - event;
end

delete(f);
f = msgbox('Alignment Completed');
pause(1);
delete(f);

guidata(h.fig(1), h);

probe = get(h.probeList, 'Value');
unit = get(h.unitList, 'Value');

clu = h.obj.clu{probe}(unit);

updateRaster(fig, clu);
updatePSTH(fig, clu);
updateBehav([],[],fig);
updateVideo([],[],fig)

end % alignData