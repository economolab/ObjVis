function changeQuality(~, ~, fig)

h = guidata(fig);

f = msgbox(['Changing quality and saving to ' h.datafn]);


probe = get(h.probeList, 'Value');
unit = get(h.unitList, 'Value');

h.obj.clu{probe}(unit).quality = h.quality.String;

obj = h.obj;

save(h.datafn,'obj','-v7.3')

curString = h.unitList.String{unit};
parts = strsplit(curString,' ');
parts{3} = h.quality.String;

str = [parts{1} ' ' parts{2} ' ' parts{3} '  ' parts{4} ' ' parts{5}];

h.unitList.String{unit} = str;

delete(f)
