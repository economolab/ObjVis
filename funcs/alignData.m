function alignData(~, ~, fig)


h = guidata(fig);

% mark that we've aligned data
h.align = 1;
h.psthDataList.Value = 2;

probe = get(h.probeList, 'Value');

evList = get(h.alignMenu, 'String');
evName = evList{get(h.alignMenu, 'Value')};
f = msgbox(['Aligning Data to ' evName]);

if strcmp(evName,'moveOnset')
    h.obj.bp.ev.(evName) = findMoveOnset(h.obj);
end

if strcmp(evName, 'jawOnset')
%     ontime = NaN(h.obj.bp.Ntrials, 1);
% %     figure;
% %     offset = 0;
%     for i = 1:h.obj.bp.Ntrials
%         
%         if isnan(h.obj.traj{1}(i).NdroppedFrames)
%             ontime(i) = h.obj.bp.ev.goCue(i);
%             continue;
%         end
%         
% 
%         
%         jaw = MySmooth(h.obj.traj{1}(i).ts(:, 2, 2), 9);
%         ts=diff(MySmooth(jaw, 21));
% %         sig = envelope(ts,40, 'peak');
%         sig = movvar(ts, 100);
%         
%         N = numel(jaw);
%       
%         sig = [0; sig];
% 
%         t = h.obj.traj{1}(i).frameTimes - 0.5;
%         goCue = h.obj.bp.ev.goCue(i);
% %         delay = h.obj.bp.ev.delay(i);
%         ix = find(sig<0.03&t<goCue, 1, 'last');
% %         ix = find(sig>0.04, 1, 'first');
%         if isempty(ix)
%             ontime(i) = h.obj.bp.ev.goCue(i);
%         else
%             ontime(i) = t(ix);
%         end
%             
%         
% %         plotsig = diff(MySmooth(jaw, 21));
% %         plot(offset+(1:N-1), plotsig);
% %         hold on; plot(offset+ix, plotsig(ix), 'k.', 'MarkerSize', 20);
%         
%         
%         
% %         offset = offset+N;
%         h.obj.bp.ev.(evName) = ontime;
%     end

% half rise time to first peak of jaw onset after go cue
view = 1; % side cam
feat = 2; % jaw

% filter params
opts.f_cut = 60; % cutoff freq for butter filt
opts.f_n   = 2;  % filter order

% peak finding params
opts.minpkdist = 0.06; % number of ms around peaks to reject peaks
opts.minpkprom = 10;   % a threshold for the peak size
h.obj.bp.ev.(evName) = alignJawOnset(view,feat,h.obj,opts);
h.obj.bp.ev.(evName) = h.obj.bp.ev.(evName) - 0.5; % correcting for 0.5 second offset 
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
    % lastLick = max(outL,outR), except when outL||outR == 0
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

guidata(h.fig(1), h);

probe = get(h.probeList, 'Value');
unit = get(h.unitList, 'Value');

clu = h.obj.clu{probe}(unit);

updateRaster(fig, clu);
updatePSTH(fig, clu);
updateBehav([],[],fig);
updateVideo([],[],fig)

delete(f);
f = msgbox('Alignment Completed');
pause(1);
delete(f);

end % alignData