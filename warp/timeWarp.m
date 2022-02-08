function timeWarp(~,~,fig)
p = guidata(fig);
h = guidata(p.parentfig);

% PARSE GUI DATA
probe = h.probeList.Value;

nLicks = str2double(p.nLicks.String);


%% time warping

% get first params.Nlicks lick times, for each trial
lickTm = findLickTimes(h.obj,nLicks);

%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----
%find median lick time for each lick across trials
% only using trials where a lick was present in median calculation
medianLickTm = findMedianLickTimes(lickTm, nLicks);

%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----
% find fit for each trial and each lick
pfit = trialWarpFits(lickTm,medianLickTm,h.obj,nLicks);

%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----%----
% warp spike times for each cluster (only spike times between go cue and first params.nLicks licks get
% warped)
for cluix = 1:numel(h.obj.clu{probe})
    
    disp(['Warping spikes for cluster ' num2str(cluix) ' / ' num2str(numel(h.obj.clu{probe}))])
    h.obj.clu{probe}(cluix).trialtm_warped = h.obj.clu{probe}(cluix).trialtm;

    for trix = 1:h.obj.bp.Ntrials
        % find spike times for current trial
        spkmask = ismember(h.obj.clu{probe}(cluix).trial,trix);
        spkix = find(spkmask);
        spktm = h.obj.clu{probe}(cluix).trialtm(spkmask);
        
        lt = lickTm{trix}; % current trial post go cue lick times
        
        for lix = 1:numel(lt) % lick index
            p_cur = pfit{trix,lix}; % current fit parameters for current trial and lick number
            
            if lix == 1
                % find spike ix b/w go cue and lick(1)
                mask = (spktm>h.obj.bp.ev.goCue(trix) & spktm<lt(lix));
            else
                % find spike ix b/w lick(x-1) and lick(x)
                mask = (spktm>lt(lix-1) & spktm<lt(lix));
            end
            tm = spktm(mask); % spike times between gocue and licks or previous and current lick
            
            % warp
            warptm = polyval(p_cur,tm);
            h.obj.clu{probe}(cluix).trialtm_warped(spkix(mask)) = warptm;
        end
        
    end
    
end

% mark that we've warped data, set warp checkbox to visible and checked,
% turn off others
h.warped = 1;
h.psthDataList.Value = 3;

f = msgbox('Warping Completed');
pause(1);
delete(f);

close(figure(535))

guidata(h.fig(1), h);

probe = get(h.probeList, 'Value');
unit = get(h.unitList, 'Value');

clu = h.obj.clu{probe}(unit);

updateRaster(h.fig(1), clu);
updatePSTH(h.fig(1), clu);
updateBehav([],[],h.fig(1));
updateVideo([],[],h.fig(1))


end % timeWarp
















