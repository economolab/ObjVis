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
axes(h.ax(5));
f = fill([-thr thr thr -thr], [0 0 mx mx], [1 0.8 0.8]);
set(f, 'Linestyle', 'none');
hold(h.ax(5), 'on');
b = bar(h.ax(5), ISIcoord, Nisi);
set(b, 'LineStyle', 'none', 'BarWidth', 1, 'FaceColor', 'b');
