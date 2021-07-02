function my_selectivity(~,~,fig)
% calculate selecitivty during delay epoch for all units
% method:
% 1) calculate SR_delay, the spike rate during delay epoch for left or right
% trials
% 2) Right_Selectivity = SR_delay_right - SR_delay_left
% 3) Selectivity = Right_Selectivity if right selective 
%    Selectivity = -Right_Selectivity if left selective

% delay-selective neurons
% % mann u whitney test
% % Prob(SR_delay,right = SR_delay,left) < 0.05
% % ranksum()

% use mike's Projections code -> make a new filter table with projections
% to show and time periods to use

%% CODE

h = guidata(fig);
clu = get(h.unitList, 'Value');

psth = getPSTH(fig,clu);

'hi'



% 
% 
% h = guidata(fig);
% 
% % get psths
% probe = get(h.probeList, 'Value');
% 
% tmin = str2double(get(h.tmin, 'String'));
% tmax = str2double(get(h.tmax, 'String'));
% 
% dt = 0.005;
% edges = tmin:0.005:tmax;
% 
% tm = edges + dt./2;
% tm = tm(1:end-1);
% 
% sm = str2double(get(h.smoothing, 'String'));
% 
% % create a spiketm vector aligned to go cue
% for clu = 1:numel(h.obj.clu{probe})
%     event = h.obj.bp.ev.goCue(h.obj.clu{probe}(clu).trial);
%     h.obj.clu{probe}(clu).trialtm_aligned = h.obj.clu{probe}(clu).trialtm - event;
% end
% 
% ttPSTH = zeros(length(tm),numel(h.obj.clu{probe}),numel(h.filt.N));
% for clu = 1:numel(h.obj.clu{probe})
%     for i = 1:h.filt.N
%         
%         trix = find(h.filt.ix(:,i));
%         spkix = ismember(h.obj.clu{probe}(clu).trial, trix);
% 
%         N = histc(h.obj.clu{probe}(clu).trialtm_aligned(spkix), edges);
% 
%         N = N(1:end-1);
% 
%         ttPSTH(:,clu,i) = MySmooth(N./numel(trix)./dt, sm);  % trial-averaged separated by trial type
%     end
% end
% 
% psth = mean(ttPSTH,3); % trial-averaged over all trial types
% 
% % % % calculate Right Selectivity
% % % rightSelectivity = ttPSTH(:,:,1) - ttPSTH(:,:,2);
% % % leftSelectivity = -rightSelectivity;
% % % 
% % % % plot right selectivity
% % % clu = get(h.unitList, 'Value');
% % % figure(542); 
% % % subplot(2,1,1)
% % % plot(tm, ttPSTH(:,clu,1), 'b'); hold on
% % % plot(tm, ttPSTH(:,clu,2), 'r'); hold off
% % % title('PSTH')
% % % subplot(2,1,2)
% % % plot(tm, rightSelectivity(:,clu), 'b', tm, leftSelectivity(:,clu), 'r'); 
% % % title('Right Trial Selectivity')
% % % xlabel('Time relative to go cue')
% 
% % % % % mann u whitney test
% % % % % unsure if you need to compare all trials or trial averaged data
% % % % % in the test. Seems like this isn't working (this being trial averaged)
% % % % p = zeros(numel(h.obj.clu{probe},1));
% % % % pass = zeros(numel(h.obj.clu{probe},1));
% % % % for clu = 1:numel(h.obj.clu{probe})
% % % %     r = ttPSTH(:,clu,1);
% % % %     l = ttPSTH(:,clu,2);
% % % %     [p(clu),pass(clu)] = ranksum(r, l);
% % % % end
% 
% 
% % calculate Right Trial 2affc / aw Selectivity
% rightSelectivity = ttPSTH(:,:,1) - ttPSTH(:,:,3);
% leftSelectivity = -rightSelectivity;
% 
% % plot right selectivity
% clu = get(h.unitList, 'Value');
% figure(542); 
% % subplot(2,1,1)
% plot(tm, ttPSTH(:,clu,1), 'b'); hold on
% % plot(tm, ttPSTH(:,clu,3), 'r'); hold off
% % title('PSTH')
% % subplot(2,1,2)
% plot(tm, rightSelectivity(:,clu), 'b', tm, leftSelectivity(:,clu), 'r'); 
% title('Right Trial Selectivity')
% xlabel('Time relative to go cue')
% 
% 
% 


end % my_selectivity