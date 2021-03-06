function findModeGUI(~,~,fig)

h = guidata(fig);
p.parentfig = fig;

p.fig = figure(534);
set(p.fig, 'Units', 'Pixels', 'Position', [507 206 1466 1081], 'Color', h.bcol);

% axes to plot projections onto mode
p.modeax(1) = axes;
set(p.modeax(1), 'Units', 'Normalized', 'Position', [0.1 0.55 0.8 0.38], 'Color', [1 1 1]);

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

p.modeax(1).XLim = [tmin tmax];
p.modeax(1).XLabel.String = 'Time (s)';
p.modeax(1).XLabel.FontSize = 15;

% set conditions to use to find mode
tabdat = cell(10, 4);

tabdat(1, :) = {'R&hit', 0, 1, 'GoCue';};
tabdat(2, :) = {'L&hit', 0, 1, 'GoCue';};
          
p.condTable = uitable(p.fig, 'Data' ,tabdat,'ColumnWidth',{200, 50, 50, 85}, 'Units','Normalized',...
    'Position', [0.099,0.35,0.3,0.155], ...
    'ColumnName', {'Condition', 'Tstart', 'Tend', 'Talign'}, 'ColumnEditable', true, ...
    'ColumnFormat', ({[]}));

% what computation (e.g. hitr - missl + missr - hitl)
xx = 0.21;
yy = 0.1;
p.modeComputation = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
    [xx+0.205047748976807,yy+0.222941720629048,0.139427012278308,0.024976873265495], 'String', 'mu(:,1) - mu(:,2)');
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position', ...
    [xx+0.208458390177353,yy+0.25,0.139427012278308,0.028852913968549], 'String', 'Computation',...
    'FontSize',12,'BackgroundColor', h.bcol);

% % set time points to use (relative to go cue)
% uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position',...
%     [0.583901773533424,0.407955596669752,0.028649386084584,0.024976873265495], 'String', 'tmin:', ...
%     'FontSize', 12, 'BackgroundColor', h.bcol);
% uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position',...
%     [0.581855388813097,0.369102682701205,0.035470668485675,0.024976873265495], 'String', 'tmax:', ...
%     'FontSize', 12, 'BackgroundColor', h.bcol);
% uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position',...
%     [0.570668485675307,0.445883441258094,0.139427012278308,0.040703052728957], 'String', 'Time Limits (Relative to Go Cue)', ...
%     'FontSize', 12, 'BackgroundColor', h.bcol);
% 
% h.modetmin = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
%     [0.619099590723056,0.40920444033303,0.052796725784448,0.030203515263642], 'String', num2str(tmin));
% h.modetmax = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
%     [0.619781718963165,0.366651248843669,0.053478854024557,0.030203515263642], 'String', num2str(tmax));

% set projections to use
tabdat = cell(10, 5);

tabdat(1, :) = {'R&hit', 0, 0, 1, 'GoCue'};
tabdat(2, :) = {'L&hit', 1, 0, 0, 'GoCue'};

p.projTable = uitable(p.fig, 'Data' ,tabdat,'ColumnWidth',{200, 40, 40, 40, 60}, 'Units','Normalized',...
    'Position', [0.099,0.175,0.3,0.155], ...
    'ColumnName', {'Projections', 'Red', 'Green', 'Blue'}, 'ColumnEditable', true, ...
    'ColumnFormat', ({[]}));

p.singleTrialCheckbox = uicontrol('Style', 'checkbox', 'Units', 'Normalized', ...
    'Position', [0.1 0.07 0.1, 0.025], 'Value', 0, 'String', 'Plot single trials', ...
    'BackgroundColor', h.bcol);

% cluster qualities to use
qualities = {h.obj.clu{h.probeList.Value}.quality};
for i = 1:numel(qualities)
    if isempty(qualities{i})
        qualities{i} = 'Poor'; % assume unlabeled cell is Poor
    end
end
xx = 0.48;
yy = 0.2;
qualities = unique(qualities)';
p.quality = uicontrol(p.fig, 'Style', 'listbox', 'Units', 'Normalized', 'Position', ...
    [xx + 0.1,yy+0.12,0.07,0.15],...
    'String', qualities , 'Value', 1:numel(qualities), 'BackgroundColor', [1 1 1], ...
    'Max', numel(qualities)+1, 'Min', 1);
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position', ...
    [xx+0.06,yy+0.27,0.14,0.025], 'String', 'Cluster Quality',...
    'FontSize',12,'BackgroundColor', h.bcol);

% low firing rate threshold
xx = 0.21;
yy = 0.18;
uicontrol('Style', 'Text', 'Units', 'Normalized', 'Position', ...
    [xx+0.208458390177353,yy+0.259944495837188,0.139427012278308,0.038852913968549], 'String', 'Remove clusters with mean FR less than:',...
    'FontSize',12,'BackgroundColor', h.bcol);
p.lowFR = uicontrol('Style', 'Edit', 'Units', 'Normalized', 'Position', ...
    [xx+0.205047748976807,yy+0.222941720629048,0.139427012278308,0.024976873265495], 'String', '1');

p.saveModeSettings = uicontrol('Style', 'pushbutton', 'Units', 'Normalized', 'Position', [0.1 0.14 0.06 0.03], 'String', 'Save', ...
    'Callback', {@saveModeSettings, p.fig}, 'FontSize', 10);
p.loadModeSettings = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.17 0.14 0.06 0.03], 'String', 'Load', ...
    'Callback', {@loadModeSettings, p.fig}, 'FontSize', 10);

% EXECUTE
uicontrol(p.fig, 'Style', 'pushbutton', 'Units', 'Normalized', 'Position', ...
    [0.099,0.1,0.3,0.03], 'String', 'Find Mode', ...
    'Callback', {@findMode, p.fig(1)}, 'FontSize', 15, 'FontWeight', 'Bold');


guidata(p.fig, p);


end % findModeGUI