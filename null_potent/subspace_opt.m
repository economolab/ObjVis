function subspace_opt(~, ~, fig)

% get guidata
h = guidata(fig);

% reformat obj
h.nullData = reformatObj(h);

% preprocess reformatted data
h.nullData = preprocess_null_potent(h.nullData);

% import manopt
run('null_potent/manopt/importmanopt'); % I turned off 'save path' question in importmanopt.m

%% Optimization 1, Orth Subspace, 2afc context
d_Move = 4;
d_Prep = 4;

data = h.nullData;
alpha = 0; % regularization hyperparam (+ve->discourage sparity, -ve->encourage sparsity)
[Q, ~, info, options] = orthogonal_subspaces(data.cov{2},d_Move, ...
                                             data.cov{1},d_Prep,alpha);
P1 = [eye(d_Move); zeros(d_Prep,d_Move)];
P2 = [zeros(d_Move, d_Prep); eye(d_Prep)];
dmax = max(d_Move,d_Prep);

% variance explained
var_explained(Q,P1,P2,data.cov{2},data.cov{1},d_Move,d_Prep,dmax);

%% projections for each condition in each subspace dimension

% get null and potent dimensions per context
Q_potent = Q*P1;
Q_null = Q*P2;

% project psths onto null/potent dimensions
right_potent = (data.psth{1}*Q_potent);
left_potent = (data.psth{2}*Q_potent);
right_null = (data.psth{1}*Q_null);
left_null = (data.psth{2}*Q_null);

% plot projections (2afc)
% move subspace
x_lim = [min(data.time),data.time(end)];
y_lim = [-1,1];
plot_projections(data.time,left_potent,right_potent,x_lim,y_lim,d_Move,'Move')

% prep subspace
x_lim = [min(data.time),data.time(end)];
y_lim = [-1,1];
plot_projections(data.time,left_null,right_null,x_lim,y_lim,d_Prep,'Prep')

%% state space trajectories

moveonset = round(length(data.time) / 2);

figure()
plot3(right_potent(:,1),right_potent(:,2),right_null(:,1),'b');
hold on
plot3(right_potent(moveonset,1),right_potent(moveonset,2),right_null(moveonset,1),'y.','MarkerSize',50);
plot3(right_potent(1,1),right_potent(1,2),right_null(1,1),'b.','MarkerSize',50);
plot3(left_potent(:,1),left_potent(:,2),left_null(:,1),'r');
plot3(left_potent(moveonset,1),left_potent(moveonset,2),left_null(moveonset,1),'g.','MarkerSize',50);
plot3(left_potent(1,1),left_potent(1,2),left_null(1,1),'r.','MarkerSize',50);
grid on
xlabel('Move Dim 1')
ylabel('Move Dim 2')
zlabel('Prep Dim 1')

% save guidata
guidata(fig, h);

end % subspace_opt

%% Helper Functions

function my_animate(gcf,fig_pth,whos_data)
    axis tight
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);
    set(gca,'zticklabel',[]);
    az = 0;
    el = 90;
    view([az,el]);
    degStep = 1;
    detlaT = 0.1;
    fCount = 71;
    f = getframe(gcf);
    [im,map] = rgb2ind(f.cdata,256,'nodither');
    im(1,1,1,fCount) = 0;
    k = 1;
    % spin 45°
    for i = 0:-degStep:-45
      az = i;
      view([az,el]);
      f = getframe(gcf);
      im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
      k = k + 1;
    end
    % tilt down
    for i = 90:-degStep:15
      el = i;
      view([az,el]);
      f = getframe(gcf);
      im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
      k = k + 1;
    end
    % spin left
    for i = az:-degStep:-90
      az = i;
      view([az,el]);
      f = getframe(gcf);
      im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
      k = k + 1;
    end
    % spin right
    for i = az:degStep:0
      az = i;
      view([az,el]);
      f = getframe(gcf);
      im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
      k = k + 1;
    end
    % tilt up to original
    for i = el:degStep:90
      el = i;
      view([az,el]);
      f = getframe(gcf);
      im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
      k = k + 1;
    end
    fig_name = fullfile(fig_pth,whos_data,'state_space.gif');
    imwrite(im,map,fig_name,'DelayTime',detlaT,'LoopCount',inf)
end % my_animate

function var_explained(Q,P1,P2,C1,C2,d1,d2,dmax)
    eigvals1 = eigs(C1, dmax, 'la'); 
    eigvals2 = eigs(C2, dmax, 'la');
    Move_on_Move = var_proj(Q*P1,C1,sum(eigvals1(1:d1))); % var explained of Move in Orth-Move subsapce
    Prep_on_Move = var_proj(Q*P1,C2,sum(eigvals2(1:d1))); % var explained of Prep in Orth-Move subsapce
    Prep_on_Prep = var_proj(Q*P2,C2,sum(eigvals2(1:d2)));
    Move_on_Prep = var_proj(Q*P2,C1,sum(eigvals1(1:d2)));

    figure();
    bar([Prep_on_Prep, Prep_on_Move,0,0,Move_on_Move, Move_on_Prep]);
    grid on;
    ax = gca();
    ax.XTickLabel = {'Prep in Null','Prep in Potent','','','Move in Potent','Move in Null'};
    a = get(gca,'XTickLabel'); set(gca,'XTickLabel',a,'fontsize',18)
    xtickangle(45)
    xlabel('Subspace projections');
    ylabel('Fraction of variance captured');
    title('Variance captured for orthogonal subspace');
end % var_explained

function plot_projections(time,left,right,x_lim,y_lim,d,title_str)
    figure
    for i = 1:d
        subplot(d,1,i)
        plot(time,left(:,i),'r','LineWidth',2)
        hold on
        plot(time,right(:,i),'b','LineWidth',2); xlim(x_lim); ylim(y_lim);
        set(gca,'yticklabel',[]);
        if i~=d; set(gca,'xticklabel',[]); 
        else; set(gca,'fontsize',18); xlabel('time relative to go cue'); end
        hold off
        sgtitle(title_str)
    end
end