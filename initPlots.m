function initPlots(fig)
h = guidata(fig);

h.fig(2) = figure(533);

set(h.fig(2), 'Units', 'Normalized', 'Position', [0.275 0.045 0.6 0.86]);

h.ax(1) = axes;
set(h.ax(1), 'Units', 'Normalized', 'Position', [0.125 0.05 0.4 0.5], 'Color', [1 1 1]);

h.ax(2) = axes;
set(h.ax(2), 'Units', 'Normalized', 'Position', [0.125 0.6 0.4 0.35], 'Color', [1 1 1]);

h.ax(3) = axes;
set(h.ax(3), 'Units', 'Normalized', 'Position', [0.6 0.05 0.375 0.5], 'Color', [1 1 1]);

h.ax(4) = axes;
set(h.ax(4), 'Units', 'Normalized', 'Position', [0.6 0.6 0.375 0.35], 'Color', [1 1 1]);

guidata(fig, h);
