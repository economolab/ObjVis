function Projections()
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

end % Projections


function cv = DirectionVector(tag, p, grnum, bootrep)
% tag is data
% p is trial types : {1,2} or whatever
% don't need other inputs

ix1 = tag.time>=p.tint{1}(1) & tag.time<p.tint{1}(2);
ix2 = tag.time>=p.tint{2}(1) & tag.time<p.tint{2}(2);

mu = zeros(tag.N.cells, 2);
sd = zeros(tag.N.cells, 2);

pval = zeros(tag.N.cells, 1);

for j = 1:tag.N.cells
    
    ts1 = cell2mat(tag.psth{j}(p.ttype{1}));  % (time,trials)
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
    % ts1 = (ntime,trials)
    % nanmean(ts1(idx,:),1) = mean of each cell for each trial during epoch 
    pval(j) = ranksum(nanmean(ts1(ix1, tr1), 1), nanmean(ts2(ix2, tr2), 1));
    % mu(j,1) = mean for cell j across trials during epoch
    mu(j, 1) = nanmean(nanmean(ts1(ix1, tr1), 1), 2);
    mu(j, 2) = nanmean(nanmean(ts2(ix2, tr2), 1), 2);
    % sd(j,1) = std for cell j across trials during epoch
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

end % DirectionVector



