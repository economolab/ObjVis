function updateISI(fig, clu)

h = guidata(fig);

dt = diff(clu.tm);
dt = dt(diff(clu.trial)==0);
if isempty(dt)
    dt = 1;
end

ISIedges = -0.02:0.0005:0.02;
Nisi = histc([dt; -dt], ISIedges);
ISIcoord = ISIedges+mean(diff(ISIedges))./2;

mx = max(Nisi);
mx = 1.05.*mx;

hold(h.ax(5), 'off');
thr = 0.0025;
b = bar(h.ax(5), ISIcoord, Nisi);
hold(h.ax(5), 'on');
f = fill(h.ax(5),[-thr thr thr -thr], [0 0 mx mx], [1 0 0]);
set(b, 'LineStyle', 'none', 'BarWidth', 1, 'FaceColor', 'b');
set(f, 'Linestyle', 'none');
set(f,'FaceAlpha',0.3)
title(h.ax(5),'ISI')



