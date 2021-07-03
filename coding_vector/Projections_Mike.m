function Projections_Mike()
%Generate the plots used for Fig. 5a,b, Fig. 6a-c, EDFig. 7a,b and EDFig 10a,b.

global sm minCorrect maxTrials bootiter minError

sm = 19;
minCorrect = 50;
maxTrials = 50;
bootiter = 100;
minError = -1;

[tag, parent] = defineDataset();
tag = loadAndProcessData(parent, tag);

param.ttplot = [1 2];
param.selZwid = 1.545;
param.projZwid = 1;
param.pol = 0;
param.gr = [1 2];
param.filter = ones(tag.N.cells, 1);


param.baseix = tag.epoch.ix{1};
param.tint = {tag.epoch.t{2}; tag.epoch.t{2}};       param.ttype = {1; 2};  
cdir{1} = getProjection(tag, param, []);
param.tint = {tag.epoch.t{4}; tag.epoch.t{4}};         param.ttype = {1; 2};           
cdir{2} = getProjection(tag, param, []);
param.tint = {tag.epoch.t{5}; tag.epoch.t{5}};     param.ttype = {1; 2};      
cdir{3} = getProjection(tag, param, cdir(2));


showProjection(tag, cdir{1}, param);
showProjection(tag, cdir{2}, param);
showProjection(tag, cdir{3}, param); 

plotEarlyLateCorr(tag, cdir)


anm = unique(tag.meta.animal);
figure; hold on;
for i= 1:numel(anm)
    plot(sum(tag.meta.animal(tag.gr(:,1))==anm(i)), sum(tag.meta.animal(tag.gr(:,3))==anm(i)), 'r.')
    plot(sum(tag.meta.animal(tag.gr(:,2))==anm(i)), sum(tag.meta.animal(tag.gr(:,4))==anm(i)), 'g.')
end
title('Correlation between tagged and untagged units');




function plotEarlyLateCorr(tag, cdir)
earlyVec = zeros(tag.N.cells, tag.N.gr);
lateVec = zeros(tag.N.cells, tag.N.gr);

for i = 1:tag.N.gr
    earlyVec(:,i) = cdir{1}{i}.vec;
    lateVec(:,i) = cdir{2}{i}.vec;
end

xl = [-0.05 0.065];
yl = [-0.08 0.08];

for i = 1:tag.N.gr
    figure; ax(i) = axes;
    hold on;
    x = earlyVec(tag.gr(:,i), i);
    y = lateVec(tag.gr(:,i), i);
    plot(x, y , '.');
    
    [r, pval] = corrcoef(x, y);
    p = polyfit(x,y,1);
    
    xline = linspace(xl(1), xl(2), 3);
    yline = polyval(p, xline);
    
    plot(xline, yline, 'k');
    title(['r = ' num2str(r(1,2)) ' (p = ' num2str(pval(2,1)) ')']);

    plot(xl, [0 0], 'k:');
    plot([0 0], yl, 'k:');
    xlim(xl);
    ylim(yl);
end





function showProjection(tag, cdir, p)
global tLine
Ngr = numel(p.gr);

f1 = figure; set(gcf, 'Units', 'Normalized', 'Position', [0.02 0.24 0.7 0.54]); 
yl = zeros(size(p.gr, 2), 2);

ax = zeros(Ngr, 1);
for i = 1:Ngr
    figure(f1);
    ax(i) = subplot(1,Ngr, i);
    plotProjection(tag, cdir{p.gr(i)}, p);

    yl(i, :) = ylim();
end
    
yl = [min(yl(:,1)), max(yl(:,2))];
yl(2) = yl(1) + 30;

figure(f1);
for i = 1:Ngr
    axes(ax(i));
    
    ylim(ax(i), yl);
    if i==1
        t = title('Medulla(L)-projecting');
    elseif i==2
        t = title('Thalamus-projecting');
    elseif  i==3
        t = title('Medulla(R)-projecting');
    end 
    set(t, 'Color', [i==1 0.7*(i==2) i==3]);
    
    for j = 1:numel(tLine)
        plot(tLine(j)+[0 0], yl, 'k-', 'Linewidth', 1);
    end

    
end
linkaxes(ax, 'xy');


figure;set(gcf, 'Units', 'Normalized', 'Position', [0.02 0.2 0.7 0.54]); 
subplot(1,2,1);  hold on;
for i = 1:Ngr
    plotProjectionSelectivity(tag, cdir{p.gr(i)}, p, getClr(i,0), [1 2]);
%     plotProjectionSelectivity(tag, cdir{i}, getClr(i,0)*0.75, [3 4]);

end
yl = ylim();
yl(2) = yl(1)+30;
ylim(yl);

for j = 1:numel(tLine)
    plot(tLine(j)+[0 0], yl, 'k-', 'Linewidth', 1);
end
plot([0.05 0.05], yl, 'k:', 'LineWidth', 1);
title('Selectivity, Go cue-aligned')

subplot(1,2,2);  hold on;
for i = 1:Ngr
    plotProjectionSelectivity(tag, cdir{p.gr(i)}, p, getClr(i,0), [5 6]);
end
yl = ylim();
yl(2) = yl(1)+30;
ylim(yl);

plot([0 0], yl, 'k-', 'Linewidth', 1);
plot([0.05 0.05], yl, 'k:', 'LineWidth', 1);
title('Selectivity, Last lick-aligned')








function plotProjection(tag, cdir, p)
global bootiter

hold on;
for i = 1:numel(p.ttplot)
    
    if bootiter>0
        mu = mean(cdir.bproj(:, p.ttplot(i), :), 3)-mean(mean(mean(cdir.bproj(tag.epoch.ix{1}, p.ttplot, :), 3), 2), 1);
        
        dat = squeeze(cdir.bproj(:, p.ttplot(i),:));
        base = squeeze(mean(mean(cdir.bproj(tag.epoch.ix{1}, p.ttplot, :), 2), 1));
        dat = dat - repmat(base', tag.N.pts, 1);
        
        if bootiter>100
            CI = prctile(dat, [5 95], 2);
            f = fill([tag.time fliplr(tag.time)], [CI(:,1); flipud(CI(:,2))], trialTypeClrs(p.ttplot(i)));
        else
            se = std(dat, [], 2);
            f = fill([tag.time fliplr(tag.time)], [mu+p.projZwid.*se; flipud(mu-p.projZwid.*se)], trialTypeClrs(p.ttplot(i)));
        end
        
        set(f, 'LineStyle', 'none', 'FaceAlpha', 0.25);
        
    else
        mu = cdir.proj(:, p.ttplot(i)) - mean(mean(cdir.proj(tag.epoch.ix{1}, p.ttplot), 2), 1);
    end
    
    plot(tag.time, mu, 'Color', 'k', 'LineWidth', 2);
end
plot([tag.time(1) tag.time(end)], [0 0], 'k--', 'Linewidth', 2);

axis tight;

xlabel('Time (sec)');
ylabel('Projection (A.U.)');





function plotProjectionSelectivity(tag, cdir, p, clr, ttypes)
global bootiter

if bootiter>0
    dat = squeeze(cdir.bproj(:,ttypes(2),:) - cdir.bproj(:,ttypes(1),:));
    if ttypes(1)<5
        dat = dat-repmat(mean(dat(p.baseix, :), 1), tag.N.pts, 1);
    end
    
    mu = mean(dat, 2);
    
    if bootiter>100
        CI = prctile(dat, 100.*[normcdf(-p.selZwid) normcdf(p.selZwid)], 2);
        f = fill([tag.time fliplr(tag.time)], [CI(:,1); flipud(CI(:,2))], clr);
    else
        se = std(dat, [], 2);
        f = fill([tag.time fliplr(tag.time)], [mu+p.selZwid.*se; flipud(mu-p.selZwid.*se)], clr);
    end
    
    set(f, 'LineStyle', 'none', 'FaceAlpha', 0.25);
else
    mu = cdir.proj(:, ttypes(2)) - cdir.proj(:, ttypes(1));
end

plot(tag.time, mu, 'Color', clr);

axis tight;
xlabel('Time (sec)');
ylabel('Projection Selectivity (A.U.)');
plot([tag.time(1) tag.time(end)], [0 0], 'k--', 'Linewidth', 1.5);







function cd = getProjection(tag, p, refdir)

cd = cell(tag.N.gr, 1);

for i = 1:tag.N.gr
    cd{i}.bvec = NaN.*zeros(tag.N.cells, tag.boot.iter);
    cd{i}.bproj = NaN.*zeros(tag.N.pts, tag.N.tt, tag.boot.iter);
    
    cd{i}.vec = DirectionVector(tag, p, i, 0);
    for j = 1:numel(refdir)
        cd{i}.vec= orthogonalizeDir(cd{i}.vec, refdir{j}{i}.vec);
    end
    cd{i}.proj = projectOntoVector(tag, cd{i}.vec);
    
    for k = 1:tag.boot.iter
        cd{i}.bvec(:, k) = DirectionVector(tag, p, i, k);
        for j = 1:numel(refdir)
            cd{i}.bvec(:, k) = orthogonalizeDir(cd{i}.bvec(:,k), refdir{j}{i}.bvec(:,k));
        end
        cd{i}.bproj(:,:, k) = projectOntoVector(tag, cd{i}.bvec(:, k));
%         cd{i}.sbproj(:,:,:,k) = projectSingleTrialsOntoVector(tag, cd{i}.bvec(:,k), 100);
    end

end





function cdir = orthogonalizeDir(cdir, refdir)
nanix = isnan(cdir);

cdir(isnan(cdir)) = 0;
refdir(isnan(refdir)) = 0;
cdir = cdir - (dot(cdir, refdir)./dot(refdir, refdir)).*refdir;
cdir(nanix) = NaN;
% cdir = cdir./sqrt(sum(cdir.^2));





function cv = DirectionVector(tag, p, grnum, bootrep)

ix1 = tag.time>=p.tint{1}(1) & tag.time<p.tint{1}(2);
ix2 = tag.time>=p.tint{2}(1) & tag.time<p.tint{2}(2);

mu = zeros(tag.N.cells, 2);
sd = zeros(tag.N.cells, 2);

pval = zeros(tag.N.cells, 1);

for j = 1:tag.N.cells
    
    ts1 = cell2mat(tag.psth{j}(p.ttype{1}));
    ts2 = cell2mat(tag.psth{j}(p.ttype{2}));
    
    if bootrep<1
        tr1 = 1:size(ts1, 2);
        tr2 = 1:size(ts2, 2);
    else
        tr1 = cell2mat(tag.boot.tr{j}(p.ttype{1}));
        tr2 = cell2mat(tag.boot.tr{j}(p.ttype{2}));
        
        tr1 = tr1(bootrep, :);
        tr2 = tr2(bootrep, :);
    end
    
    pval(j) = ranksum(nanmean(ts1(ix1, tr1), 1), nanmean(ts2(ix2, tr2), 1));

    mu(j, 1) = nanmean(nanmean(ts1(ix1, tr1), 1), 2);
    mu(j, 2) = nanmean(nanmean(ts2(ix2, tr2), 1), 2);
    
    sd(j, 1) = nanstd(nanmean(ts1(ix1, tr1), 1), [], 2);
    sd(j, 2) = nanstd(nanmean(ts2(ix2, tr2), 1), [], 2);
    
end

cv = (mu(:,2)-mu(:,1))./sqrt(sd(:,1).^2 + sd(:,2).^2);
cv(isnan(cv)) = 0;

if bootrep>0
    cv = cv.*histc(tag.boot.grix{grnum}(:,bootrep), 1:tag.N.cells);
else
    cv(~tag.gr(:, grnum))  = 0;
    cv(~p.filter) = 0;
    
end
cv = cv.*(pval<1);
% cv(~cix) = 0;

if p.pol==-1
    cv(cv>0) = 0;
elseif p.pol==1
    cv(cv<0) = 0;
end
% v = v./sqrt(nansum(v.^2));
cv = cv./sum(abs(cv));  %Note, if use euclidean norm, have to change the bootstrapping stuff.





function proj = projectOntoVector(tag, cdir)

a = tag.avg.ts;
a(isnan(a)) = 0;

for i = 1:tag.N.cells
    base = a(tag.epoch.ix{1}, i, [1 2]);
%     base = a(:, i, [1 2]);
    minval = min(min(a(:,i,1:2), [], 1), [], 3);
    maxval = max(max(a(:,i,1:2), [], 1), [], 3);
%     base = a(:, i, [1 2]);
    for j = 1:tag.N.tt
%         a(:, i, j) = a(:, i, j)./median(base(:));
%         a(:, i, j) = (a(:, i, j) - mean(base(:)))./std(base(:));
%         a(:, i, j) = (a(:, i, j)-minval)./(maxval-minval);
    end
end
a(isnan(a)) = 0;
a(isinf(a)) = 0;

proj = zeros(tag.N.pts, tag.N.tt);
for i = 1:tag.N.tt
    proj(:,i) = a(:, :, i)*cdir;
end





