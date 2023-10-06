%% LOAD THE DATA

data=readtable("case-study/data_depression/ESMdata.txt");

%% KEEP UNIQUE DEPRESSION SCORE AND PLOT

% nan_dep=find(~isnan(data.dep));
% data_dep=unique(data(nan_dep, [1, 85]));
%plot(data_dep.date,data_dep.dep)

%data_dep=data(:, [1, 85]);
data_dep=data(:, [1, 72:84]);
data_dep.dep=mean(table2array(data_dep(:,2:end)),2);
data_dep=data_dep(:,[1,15]);

cur_dep=0;
for cur_i = 1:size(data_dep,1)
    if ~isnan(table2array(data_dep(cur_i,2)))
        cur_dep=table2array(data_dep(cur_i,2));
    else
        data_dep(cur_i,2)=num2cell(cur_dep);
    end
end


%% FIND TIPPING POINT

date_initial=data.date(1);
date_change=date_initial+127; %date tipping point according to wichers et al. 2016
index_change=find(data.date==date_change, 1 );
index_change_data_dep=find(data_dep.date>date_change, 1 );

index_all=[10:29, 39:46];
data_all=data(:,index_all);

date_end_baseline=date_initial+28;
index_end_baseline=find(data.date==date_end_baseline, 1 );

index_w_date=[1, 10:29, 39:46];
data_date=data(:,index_w_date);
%data_date= rmmissing(table2array(data_date));
data_date=data_date(:,1);

%% PCA of negative variables
index_data_neg=[2,3,5,6,8,10,11,13,14,15,18,19,22,23];
data_neg=data_all(:,index_data_neg);
%data_neg_array= rmmissing(table2array(data_neg));
data_neg_array= table2array(data_neg);

data_all_baseline=data_neg_array(1:index_end_baseline,:);
[coeff,score,latent] = pca(data_all_baseline);
projected_neg_data_pc=data_neg_array*coeff(:,1);

data_bftp=projected_neg_data_pc(1:index_change,:);
length_tot=size(data_bftp,1);

%% Plot depression score

plot(data_dep.date,data_dep.dep,'LineWidth',2)
hold on
x=[date_change max(data_dep.date) max(data_dep.date) date_change ]; y=[0.8 0.8 3 3];
fill(x,y,[0.886, 0.133, 0.254], 'EdgeColor','none')
alpha(0.3)
xlabel('Time')
ylabel('Depression score')
xlim([min(data_dep.date) max(data_dep.date)]); ylim([1 2.8]);
hold off
ax = gca; 
ax.FontSize = 16; 
set(gca, 'box', 'off')

%% Plot rw analysis

pval_scC=generic_ews(projected_neg_data_pc,'winsize',30,'indicators',{'std'},'silent',true,'nanflag','omitnan');

indicator=pval_scC.indicators;

subplot(5,1,1)
p=plot(data.date,projected_neg_data_pc,'Color',[0.074, 0.325, 0.866, 1]); %plot the whole dataset
hold on 
x=[date_change max(data_dep.date) max(data_dep.date) date_change ]; y=[max(projected_neg_data_pc)+5 max(projected_neg_data_pc)+5 -5 -5];
fill(x,y,[0.886, 0.133, 0.254], 'EdgeColor','none')
alpha(0.3)
xlim([min(data_dep.date) max(data_dep.date)]); ylim([min(projected_neg_data_pc)-0.1 max(projected_neg_data_pc)+0.1]);
ax = gca; 
ax.FontSize = 14; 
set(gca,'ytick',[])
set(gca,'xtick',[])
ylabel({'Data','resampled'})
set(gca,'YColor','k');
set(gca, 'box', 'off')
hold off

subplot(5,1,2:4)
plot(data.date,indicator,'LineWidth',2)
hold on
x=[date_change max(data_dep.date) max(data_dep.date) date_change ]; y=[0.8 0.8 3 3];
fill(x,y,[0.886, 0.133, 0.254], 'EdgeColor','none')
alpha(0.3)
xlabel('Time')
ylabel({'Variance calculated', 'with a rolling', 'window approach'})
xlim([min(data_dep.date) max(data_dep.date)]); ylim([min(indicator)-0.1 max(indicator)+0.1]);
hold off
ax = gca; 
ax.FontSize = 14; 
set(gca, 'box', 'off')

%% Plot burst analysis

cur_bursts=4;
length_bursts=350;
l_bursts=floor(length_bursts/cur_bursts); %length of one burst
rem=length_tot-length_bursts; %remaining amount of data points
spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts
indexes_data=round(linspace(1,l_bursts,l_bursts));
data_gp3=zeros(l_bursts,cur_bursts); indexes_gp3=zeros(l_bursts,cur_bursts);
for i=1:cur_bursts
    indexes_data_cur=indexes_data+(i-1)*(spacing+l_bursts);
    indexes_gp3(:,i)=indexes_data_cur;
    data_gp3(:,i)=projected_neg_data_pc(indexes_data_cur); %subsample from big dataset
end

groups=cat(1,repelem(1,l_bursts)',repelem(2,l_bursts)',repelem(3,l_bursts)',repelem(4,l_bursts)');
res_burst=generic_ews_fixed(data_gp3(:),'grouping',groups,'slopekind','ts','nanflag','omitnan'); %calculate indicators and slope
res_burst=res_burst.CL.tsslope;
slope=table2array(res_burst('slope_std','Estimated'));
p_val=table2array(res_burst('slope_std','p_value'));
%slope_low=table2array(res_burst.CL.tsslope(1,2)); slope_high=table2array(res_burst.CL(1,3));

ar1=std(data_gp3(:,1)); ar2=std(data_gp3(:,2)); ar3=std(data_gp3(:,3)); ar4=std(data_gp3(:,4)); 
ars=[ar1 ar2 ar3 ar3];
groups=[1 2 3 4];
intercepts=ars-slope*groups; intercept=mean(intercepts);

val_line=slope*groups+intercept;
% val_line_low=slope_low*groups+intercept;
% val_line_high=slope_high*groups+intercept;

subplot(5,1,1)
p=plot(data.date,projected_neg_data_pc,'Color',[0.60, 0.60, 0.60, 1]); %plot whole dataset
hold on
for i=1:cur_bursts
    plot(data.date(indexes_gp3(:,i)),data_gp3(:,i),'Color',[0.886, 0.133, 0.254, 1]) %plot subsets of data
end
x=[date_change max(data_dep.date) max(data_dep.date) date_change ]; y=[max(projected_neg_data_pc)+5 max(projected_neg_data_pc)+5 -5 -5];
fill(x,y,[0.886, 0.133, 0.254], 'EdgeColor','none')
alpha(0.3)
xlim([min(data_dep.date) max(data_dep.date)]); ylim([min(projected_neg_data_pc)-0.1 max(projected_neg_data_pc)+0.1]);
ax = gca; 
ax.FontSize = 16; 
set(gca,'ytick',[])
set(gca,'xtick',[])
ylabel({'Data','resampled'})
set(gca,'YColor','k');
set(gca, 'box', 'off')
hold off

subplot(5,1,2:5)
plot(mean(data.date(indexes_gp3)),val_line,'Color',[0.886, 0.133, 0.254],'LineWidth',2); %plot slope
hold on
scatter(mean(data.date(indexes_gp3)),ars,'marker','o','MarkerEdgeColor',[0.886, 0.133, 0.254]);
ylabel({'Variance calculated with','a burst approach'}); xlabel('Time')
xlim([min(data_dep.date) max(data_dep.date)]); ylim([min(ars)-0.1 max(ars)+0.1]);
x=[date_change max(data_dep.date) max(data_dep.date) date_change ]; y=[max(projected_neg_data_pc)+5 max(projected_neg_data_pc)+5 -5 -5];
fill(x,y,[0.886, 0.133, 0.254], 'EdgeColor','none')
alpha(0.3)
%set(gca,'ytick',[])
set(gca, 'box', 'off')
ax = gca; 
ax.FontSize = 16; 
text(1000,0.08,{['p-value = ' num2str(p_val)]}, 'FontSize', 12);
hold off
