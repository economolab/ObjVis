function updateVideo(~, ~, fig)

h = guidata(fig);

camRate = 400;

camera = get(h.cameraList, 'Value');
feat = get(h.featureList, 'Value');
vid = h.obj.traj{camera};

var(1) = get(h.feat_popupmenu(1), 'Value');
var(2) = get(h.feat_popupmenu(2), 'Value');

sm = str2double(get(h.vidSmoothing, 'String'));
offset = str2double(get(h.vidOffset, 'String'));

tmin = str2double(get(h.tmin, 'String'));
tmax = str2double(get(h.tmax, 'String'));

hold(h.ax(4), 'off');
yoff = 0;
for i = 1:h.filt.N
    
    if ~h.filterTable.Data{i, 5}
        continue;
    end
    trix = find(h.filt.ix(:,i));

    for j = 1:numel(trix)
        
        p = vid(trix(j)).ts(:, 3, feat);
        
        Nframes = size(vid(trix(j)).ts, 1);
        dat = zeros(Nframes, 2);
        
        for k = 1:2
            switch var(k)
                case 1
                    dat(:,k) = (1:Nframes)./camRate;
                case 2
                    dat(:,k) = MySmooth(vid(trix(j)).ts(:, 1, feat), sm);
                    dat(p<0.9, k) = NaN;
                case 3
                    dat(:,k) = MySmooth(vid(trix(j)).ts(:, 2, feat), sm);
                    dat(p<0.9, k) = NaN;
            end
        end
        
        % plot
        if h.align
            evName = h.alignMenu.String{h.alignMenu.Value};
            plot(h.ax(4), dat(:,1) - h.obj.bp.ev.(evName)(trix(j)), yoff + dat(:,2), '-', 'Color', h.filt.clr(i,:));
        else
            plot(h.ax(4), dat(:,1), yoff + dat(:,2), '-', 'Color', h.filt.clr(i,:));
        end
        hold(h.ax(4), 'on');
        yoff = yoff+offset;
    end
end

xlabel(h.ax(4), h.feat_popupmenu(1).String{h.feat_popupmenu(1).Value});
ylabel(h.ax(4), h.feat_popupmenu(2).String{h.feat_popupmenu(2).Value});
title(h.ax(4), h.featureList.String{h.featureList.Value});

axis(h.ax(4), 'tight');
set(h.ax(4), 'XGrid', 'On', 'YGrid', 'On');

if var(1)==1
    xlim(h.ax(4), [tmin, tmax]);
end