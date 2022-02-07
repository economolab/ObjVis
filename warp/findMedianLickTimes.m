function medianLickTm = findMedianLickTimes(lickTm, nLicks)

medianLickTm = nan(nLicks,1);
for i = 1:nLicks
    % find trials with atleast (i-1) licks
    trix_w_licks = cell2mat(cellfun(@(x) (numel(x)>(i-1)), lickTm, 'UniformOutput', false)); 
    % get i_th lick time for each of trix_w_licks
    lickTimes = cell2mat(cellfun(@(x) x(i), lickTm(trix_w_licks), 'UniformOutput', false));
    % calculate median time for i_th lick
    medianLickTm(i) = median(lickTimes);
end

end
