function moveOn = findMoveOnset(obj)
%findMoveOnset Uses video data to determine time of movement onset

% finds times where jaw is stationary throughout a trial. The first
% nonstationary time before the go cue is movement onset time

%% load data

% vars
dt = 1/400;
view = 1; % side cam
feat = 2; % jaw
coord = 1; % x coord
sm = 7; % smoothing window

vid = obj.traj{view};

figure

moveOn = nan(obj.bp.Ntrials,1);
for j = 1:obj.bp.Ntrials
        
    p = vid(j).ts(:, 3, feat);

    Nframes = size(vid(j).ts, 1);
    dat = zeros(Nframes, 2);
    dat(:,1) = (1:Nframes)./(1/dt);
    dat(:,2) = MySmooth(vid(j).ts(:,coord,feat), sm);
    dat(p<0.9,2) = NaN;
%     dat(:,2) = normalize(dat(:,2),'norm');
    
    val = zeros(Nframes, 1);
    binsize = 0.5; % in seconds
    for ii = (1/dt * binsize):Nframes % for each half second bin
        val(ii) = std(dat(ii-(1/dt*binsize-1):ii,2)); % variance in jaw move in bin
    end
    % % then find first ~mov working backwards from go cue
    mov = val > 0.15*max(val);
    stationary = find(~mov);
%     [~,gocueidx] = min(abs(dat(:,1)-obj.bp.ev.goCue(j)));
%     movidx = find(find(~mov)<gocueidx);
%     moveOn(j) = movidx(end)+1;
    
%     mo = movidx(end) + 1;
    subplot(2,1,1)
    plot(dat(:,1),dat(:,2)); hold on
    plot(dat(stationary,1),dat(stationary,2),'.');
%     plot(dat(mo,1),dat(mo,2),'g.','MarkerSize',15)
    hold off
    subplot(2,1,2)
    plot(dat(:,1),val); hold on
    plot(dat(stationary,1),val(stationary),'.');
    hold off
    pause

end

moveOn = moveOn * dt;

end % findMoveOnset
