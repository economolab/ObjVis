function obj = warpVideo(obj,jawStart,med,pfit)

dt = 1/400;
dt = 0;

for view = 1:numel(obj.traj)

    for trix = 1:obj.bp.Ntrials
        obj.traj{view}(trix).frameTimes_warped = obj.traj{view}(trix).frameTimes - 0.5;
        
        ft = obj.traj{view}(trix).frameTimes_warped;
        gc = obj.bp.ev.goCue(trix);
        ls = jawStart{trix}; % current trial lick(lix) start times
        % if no licks found in current trial, move on to the next trial
        if numel(ls) == 0
            continue
        end
        
%         for lix = 1:numel(ls) % lick index for current trial
%             p_cur = pfit{trix,lix}; % current fit parameters for current trial and lick number
%             
%             % find spike ix b/w to warp
%             if lix == 1 && lix == numel(lix) % only 1 lick
%                 mask = (ft>=gc) & (ft<=(ls(1)+median(diff(med.lickStart))));
%             elseif lix == 1
%                 mask = (ft>=gc) & (ft<=(ls(2)-dt));
%             elseif lix == numel(ls)
%                 mask = (ft>=ls(lix)) & (ft<=(ls(lix)+median(diff(med.lickStart))) );
%             else
%                 mask = (ft>=ls(lix)) & (ft<=(ls(lix+1)-dt) );
%             end
%             
%             % warp video data
%             warptm = polyval(p_cur,ft(mask));
%             obj.traj{view}(trix).frameTimes_warped(mask) = warptm;
%             
%         end

%         knots = [median(obj.bp.ev.goCue); med.lickStart(1:numel(ls))];
%         ix1 = find(ft>=pfit{trix}(1), 1, 'first');
%         ix2 = find(ft>=pfit{trix}(end), 1, 'first');
%         
%         newtime = ft;
%         newtime(ix1:ix2) = interp1(pfit{trix}, knots, ft(ix1:ix2), 'linear');
%         newtime(1:ix1-1) = newtime(1:ix1-1) - (pfit{trix}(1)-knots(1));
%         newtime(ix2+1:end) = newtime(ix2+1:end) - (pfit{trix}(end)-knots(end));
%         obj.traj{view}(trix).frameTimes_warped = newtime;
%         
        
        

        
%         ix1 = find(ft>=pfit{trix}(1), 1, 'first');
%         ix2 = find(ft>=pfit{trix}(end), 1, 'first');
        
%         newtime = ft;
        newtime = interp1(pfit{trix, 1}, pfit{trix, 2}, ft, 'linear');
%         newtime(1:ix1-1) = newtime(1:ix1-1) - (pfit{trix}(1)-knots(1));
%         newtime(ix2+1:end) = newtime(ix2+1:end) - (pfit{trix}(end)-knots(end));
        obj.traj{view}(trix).frameTimes_warped = newtime;
        


    end
end

end % warpVideo
