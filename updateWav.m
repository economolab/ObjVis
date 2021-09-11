function updateWav(fig, clu)

h = guidata(fig);

if ~isfield(clu,'spkWavs')
    x = h.ax(6).XLim(1);
    y = h.ax(6).YLim(2)/3;
    text(h.ax(6),x,y,'spike waveforms not found',...
        'FontSize', 20)
    return
end

wavs = squeeze(clu.spkWavs);
meanWav = mean(wavs,2);

plot(h.ax(6),wavs,'Color',[0,0,0,0.3],'LineWidth',1.5)
hold(h.ax(6),'on')
plot(h.ax(6),meanWav,'m','LineWidth',3)
hold(h.ax(6),'off')
title(h.ax(6),'Waveforms')
