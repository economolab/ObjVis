function initPlots(fig)
h = guidata(fig);

h.fig(2) = figure(533);

set(h.fig(2), 'Units', 'Normalized', 'Position', [0.2020    0.0354    0.7500    0.8597]);

h.ax(1) = axes;
set(h.ax(1), 'Units', 'Normalized', 'Position', [0.05 0.05 0.3 0.5], 'Color', [1 1 1]);

h.ax(2) = axes;
set(h.ax(2), 'Units', 'Normalized', 'Position', [0.05 0.6 0.3 0.35], 'Color', [1 1 1]);

h.ax(3) = axes;
set(h.ax(3), 'Units', 'Normalized', 'Position', [0.4 0.05 0.3 0.5], 'Color', [1 1 1]);

h.ax(4) = axes;
set(h.ax(4), 'Units', 'Normalized', 'Position', [0.4 0.6 0.3 0.35], 'Color', [1 1 1]);

h.ax(5) = axes;
set(h.ax(5), 'Units', 'Normalized', 'Position', [0.75 0.6 0.2 0.35], 'Color', [1 1 1]);

h.ax(6) = axes;
set(h.ax(6), 'Units', 'Normalized', 'Position', [0.75 0.2 0.2 0.35], 'Color', [1 1 1]);

guidata(fig, h);
