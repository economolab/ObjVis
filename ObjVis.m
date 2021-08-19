function ObjVis()
close all;

%% add paths
addAllPaths();

%% Setup GUI
bcol = [1 1 1];

% Main Figure
h.fig(1) = figure(532);
set(h.fig(1), 'Units', 'Pixels', 'Position', [15 50 500 800], 'Color', bcol);

% load object
h.loadData = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [15 10 120 40], 'String', 'Load Object', ...
    'Callback', {@loadObject, h.fig(1)}, 'FontSize', 12, 'FontWeight', 'Bold');

% link all axes
h.linkAxes = uicontrol(h.fig(1), 'Style', 'checkbox', 'Units', 'Pixels', 'Position', [160 10 120 40], 'String', 'Link All Axes', ...
     'Callback', {@linkBox, h.fig(1)}, 'FontSize', 12, 'FontWeight', 'Bold');

% trial type filters
h.addFilter = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [15 150 75 30], 'String', 'Add', ...
    'Callback', {@addFilter, h.fig(1)}, 'FontSize', 10);
h.filterInfo = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [100 150 75 30], 'String', 'Remove', ...
    'Callback', {@removeFilter, h.fig(1)}, 'FontSize', 10);
h.filterInfo = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [185 150 75 30], 'String', 'Save', ...
    'Callback', {@saveFilter, h.fig(1)}, 'FontSize', 10);
h.filterInfo = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [270 150 75 30], 'String', 'Load', ...
    'Callback', {@loadFilter, h.fig(1)}, 'FontSize', 10);
h.filterInfo = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [350 150 75 30], 'String', 'Info', ...
    'Callback', {@filterInfo, h.fig(1)}, 'FontSize', 10);

% align data
h.align = 0;
h.alignMenu = uicontrol(h.fig(1), 'Style', 'popupmenu', 'Units', 'Pixels', 'Position', [15 100 75 30], 'String', {''}, ...
    'FontSize', 10);
h.alignButton = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [100 100 125 30], 'String', 'Align To Event', ...
    'Callback', {@alignData, h.fig(1)}, 'FontSize', 10);
h.unalignButton = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [230 100 75 30], 'String', 'Unalign', ...
    'Callback', {@unalignData, h.fig(1)}, 'FontSize', 10);

% pca
h.pcaButton = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [15 60 85 30], 'String', 'PCA', ...
    'Callback', {@my_pca, h.fig(1)}, 'FontSize', 10);

% select units, probes
h.unitList = uicontrol(h.fig(1), 'Style', 'listbox', 'Units', 'Pixels', 'Position', ...
    [15 340 160 325], 'String', {'no units'} , 'Value', 1, 'BackgroundColor', [1 1 1], ...
    'Max', 3, 'Min', 1, 'Callback',  {@unitSelect, h.fig(1)});

h.probeList = uicontrol(h.fig(1), 'Style', 'listbox', 'Units', 'Pixels', 'Position', ...
    [15 700 120 75], 'String', {'no probes'} , 'Value', 1, 'BackgroundColor', [1 1 1], ...
    'Max', 3, 'Min', 1, 'Callback',  {@probeSelect, h.fig(1)});

% setup filter table
tabdat = {'R&hit', 0, 0, 1, true, 'epoch'; ...
         'L&hit', 1, 0, 0, true, 'epoch'};
     
h.filterTable = uitable(h.fig(1), 'Data' ,tabdat,'ColumnWidth',{150,40,40,40,60,75}, 'Position', [15 195, 450, 125], ...
    'ColumnName', {'Filter','Red', 'Green', 'Blue', 'Enabled', 'Epoch'}, 'ColumnEditable', true, ...
    'CellEditCallback', {@tableChange, h.fig(1)}, 'ColumnFormat', ({[],[],[],[],[]}));

% time
uicontrol('Style', 'Text', 'Units', 'Pixels', 'Position', [375 47 50 25], 'String', 'Min:', ...
    'FontSize', 12, 'BackgroundColor', bcol);
uicontrol('Style', 'Text', 'Units', 'Pixels', 'Position', [375 77 50 25], 'String', 'Max:', ...
    'FontSize', 12, 'BackgroundColor', bcol);
uicontrol('Style', 'Text', 'Units', 'Pixels', 'Position', [360 105 140 25], 'String', 'Time limits', ...
    'FontSize', 12, 'BackgroundColor', bcol);

h.tmin = uicontrol('Style', 'Edit', 'Units', 'Pixels', 'Position', ...
    [425 50 50 25], 'String', -0.5, 'Callback', {@updateAxes, h.fig});
h.tmax = uicontrol('Style', 'Edit', 'Units', 'Pixels', 'Position', ...
    [425 80 50 25], 'String', 5.5, 'Callback', {@updateAxes, h.fig});

% smoothing
uicontrol('Style', 'Text', 'Units', 'Pixels', 'Position', [325 10 100 25], 'String', 'Smoothing:', ...
    'FontSize', 12, 'BackgroundColor', bcol);
h.smoothing = uicontrol('Style', 'Edit', 'Units', 'Pixels', 'Position', ...
    [425 10 50 25], 'String', 15, 'Callback', {@updateAxes, h.fig});


% setup video data features
h.feat.N = 2;
h.feat.str = {'','',''};
for i = 1:h.feat.N
    h.feat_popupmenu(i) = uicontrol('Style', 'popupmenu', 'Units', 'pixels', 'Position', ...
        [375 775-35*i 100 25], 'String', h.feat.str,'Callback', ...
        {@updateVideo,gcf}, 'Value', i, 'BackgroundColor', [1 1 1]);
    
    uicontrol('Style', 'text', 'String', ['Feature #' num2str(i)],'Units','pixels' ...
        ,'BackgroundColor',bcol,'Position',[265 775-35*i 100 22],'HorizontalAlignment','Right', ...
        'FontSize', 10, 'FontWeight', 'Bold');
end
uicontrol('Style', 'text', 'String', 'Video Data','Units','pixels' ...
    ,'BackgroundColor',bcol,'Position',[330 770 100 22],'HorizontalAlignment','Center', ...
    'FontSize', 10, 'FontWeight', 'Bold');

h.featureList = uicontrol(h.fig(1), 'Style', 'listbox', 'Units', 'Pixels', 'Position', ...
    [375 525 100 75], 'String', {'no features'} , 'Value', 1, 'BackgroundColor', [1 1 1], ...
    'Max', 3, 'Min', 1, 'Callback',  {@featureSelect, h.fig(1)});

h.cameraList = uicontrol(h.fig(1), 'Style', 'listbox', 'Units', 'Pixels', 'Position', ...
    [375 620 100 75], 'String', {'no cameras'} , 'Value', 1, 'BackgroundColor', [1 1 1], ...
    'Max', 3, 'Min', 1, 'Callback',  {@cameraSelect, h.fig(1)});


uicontrol('Style', 'Text', 'Units', 'Pixels', 'Position', [325 490 90 22], 'String', 'Smoothing:', ...
    'FontSize', 12, 'HorizontalAlignment', 'Right', 'BackgroundColor', bcol);
h.vidSmoothing = uicontrol('Style', 'Edit', 'Units', 'Pixels', 'Position', ...
    [425 490 50 25], 'String', 7, 'Callback', {@updateVideo, h.fig});

uicontrol('Style', 'Text', 'Units', 'Pixels', 'Position', [325 455 90 22], 'String', 'Y offset:', ...
    'FontSize', 12, 'HorizontalAlignment', 'Right', 'BackgroundColor', bcol);
h.vidOffset = uicontrol('Style', 'Edit', 'Units', 'Pixels', 'Position', ...
    [425 455 50 25], 'String', 0, 'Callback', {@updateVideo, h.fig});

% projections 
projTypes = {'Epoch Coding Vector', 'Activity Modes'};
h.projMenu = uicontrol(h.fig(1), 'Style', 'popupmenu', 'Units', 'Pixels', 'Position', [250 337, 100, 30], 'String', projTypes, ...
    'FontSize', 10);
h.projButton = uicontrol(h.fig(1), 'Style', 'pushbutton', 'Units', 'Pixels', 'Position', [360 340, 100, 30], 'String', 'Project', ...
    'Callback', {@projButtonPressed, h.fig(1)}, 'FontSize', 10);



%% Init GUI
guidata(h.fig(1), h);

initPlots(h.fig(1));


end % ObjVis


function addAllPaths()
addpath(genpath(fullfile(pwd, 'null_potent')));
addpath(genpath(fullfile(pwd, 'dim_reduction')));
addpath(genpath(fullfile(pwd, 'coding_vector')));
addpath(genpath(fullfile(pwd, 'activity_modes')));
addpath(genpath(fullfile(pwd, 'utils')));
addpath(genpath(fullfile(pwd, 'guifuncs')));
addpath(genpath(fullfile(pwd, 'funcs')));
end % addAllPaths






