function findModeGUI(~,~,fig)

h = guidata(fig);

h.fig(3) = figure(534);
set(h.fig(3), 'Units', 'Pixels', 'Position', [507 206 1466 1081], 'Color', h.bcol);

% axes to plot projections onto mode
h.modeax(1) = axes;
set(h.modeax(1), 'Units', 'Normalized', 'Position', [0.1 0.55 0.8 0.38], 'Color', [1 1 1]);

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

h.modeax(1).XLim = [tmin tmax];
h.modeax(1).XLabel.String = 'Time (s)';
h.modeax(1).XLabel.FontSize = 15;

% set conditions to use to find mode
tabdat = {'R&hit';'L&hit';[];[];[];[];[];[];[];[]};

h.condTable = uitable(h.fig(3), 'Data' ,tabdat,'ColumnWidth',{300}, 'Units','Normalized',...
    'Position', [0.099,0.325,0.227,0.155], ...
    'ColumnName', {'Condition'}, 'ColumnEditable', true, ...
    'ColumnFormat', ({[]}));

% what computation (e.g. hitr - missl + missr - hitl)
h.modeComputation = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
    [0.370122783083219,0.410129509713233,0.139427012278308,0.030203515263642], 'String', 'mu(:,1) - mu(:,2)');
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position', ...
    [0.370122783083219,0.450508788159112,0.139427012278308,0.024976873265495], 'String', 'Computation',...
    'FontSize',12,'BackgroundColor', h.bcol);

% set time points to use (relative to go cue)
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position',...
    [0.583901773533424,0.407955596669752,0.028649386084584,0.024976873265495], 'String', 'tmin:', ...
    'FontSize', 12, 'BackgroundColor', h.bcol);
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position',...
    [0.581855388813097,0.369102682701205,0.035470668485675,0.024976873265495], 'String', 'tmax:', ...
    'FontSize', 12, 'BackgroundColor', h.bcol);
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position',...
    [0.570668485675307,0.445883441258094,0.139427012278308,0.040703052728957], 'String', 'Time Limits (Relative to Go Cue)', ...
    'FontSize', 12, 'BackgroundColor', h.bcol);

h.modetmin = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
    [0.619099590723056,0.40920444033303,0.052796725784448,0.030203515263642], 'String', num2str(tmin));
h.modetmax = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
    [0.619781718963165,0.366651248843669,0.053478854024557,0.030203515263642], 'String', num2str(tmax));

% set projections to use
tabdat = {'R&hit';'L&hit';[];[];[];[];[];[];[];[]};

h.projTable = uitable(h.fig(3), 'Data' ,tabdat,'ColumnWidth',{300}, 'Units','Normalized',...
    'Position', [0.720418826739428,0.324074930619798,0.227,0.155000000000001], ...
    'ColumnName', {'Projections'}, 'ColumnEditable', true, ...
    'ColumnFormat', ({[]}));

% cluster qualities to use
qualities = {h.obj.clu{h.probeList.Value}.quality};
for i = 1:numel(qualities)
    if isempty(qualities{i})
        qualities{i} = 'Poor'; % assume unlabeled cell is Poor
    end
end
qualities = unique(qualities)';
h.quality = uicontrol(h.fig(3), 'Style', 'listbox', 'Units', 'Normalized', 'Position', ...
    [0.099000000000002,0.119634597594823,0.073578444747612,0.155000000000002],...
    'String', qualities , 'Value', 1:numel(qualities), 'BackgroundColor', [1 1 1], ...
    'Max', numel(qualities)+1, 'Min', 1);
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position', ...
    [0.064529331514324,0.277520814061055,0.139427012278308,0.024976873265495], 'String', 'Cluster Quality',...
    'FontSize',12,'BackgroundColor', h.bcol);

% low firing rate threshold
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position', ...
    [0.208458390177353,0.259944495837188,0.139427012278308,0.038852913968549], 'String', 'Remove clusters with mean FR less than:',...
    'FontSize',12,'BackgroundColor', h.bcol);
h.lowFR = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
    [0.205047748976807,0.222941720629048,0.139427012278308,0.024976873265495], 'String', '1');

% EXECUTE
uicontrol(h.fig(3), 'Style', 'pushbutton', 'Units', 'Normalized', 'Position', ...
    [0.373897680763985,0.264569842738206,0.261845839017734,0.036891766882522], 'String', 'Find Mode', ...
    'Callback', {@findMode, h.fig(1)}, 'FontSize', 15, 'FontWeight', 'Bold');


guidata(h.fig(1), h);



end % findModeGUI