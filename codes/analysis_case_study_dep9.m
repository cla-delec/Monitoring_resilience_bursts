%%% FIG WITH BURST VS MV SCA, SCB AND SCC FOR PCA OF NEG VARIABLES

data=readtable("case-study/data_depression/ESMdata.txt");
%data=load("ts_depression_withNaNs_thesh4hours.mat");
%data=data.new_data_thresh4;

%% FIND TIPPING POINT

date_initial=data.date(1);
date_change=date_initial+127; %date tipping point according to wichers et al. 2016
index_change=find(data.date==date_change, 1 );

index_all=[10:29, 39:46];
data_all=data(:,index_all);

date_end_baseline=date_initial+28;
index_end_baseline=find(data.date==date_end_baseline, 1 );

%% PCA of negative variables
index_data_neg=[2,3,5,6,8,10,11,13,14,15,18,19,22,23];
data_neg=data_all(:,index_data_neg);
data_neg_array= rmmissing(table2array(data_neg));

data_all_baseline=data_neg_array(1:index_end_baseline,:);
[coeff,score,latent] = pca(data_all_baseline);
projected_neg_data_pc=data_neg_array*coeff(:,1);

data_bftp=projected_neg_data_pc(1:index_change,:);
length_tot=size(data_bftp,1);

%% BURST ANALYSIS - SIMULATION PARAMETERS

cur_res=1;

max_bursts=4;
bursts=2:max_bursts; 
n_bursts=size(bursts,2);

length_bursts=100:20:500; %total length of data collected
n_lengths=size(length_bursts,2);

result_ar_bursts=zeros(n_bursts,n_lengths);
result_var_bursts=zeros(n_bursts,n_lengths);
result_scA=zeros(n_lengths,2);
result_scB=zeros(n_lengths,2);
res_scC=zeros(2,1);

%% BURST ANALYSIS - SIMULATION 


for index_cur_length=1:n_lengths

    cur_length_bursts=length_bursts(index_cur_length);

    data_cur_scA=data_bftp((end-cur_length_bursts):end);
    ews_cur=generic_ews(data_cur_scA,'winsize',30,'indicators',{'AR','std'},'ebisuzaki',100,'silent',true,'nanflag','omitnan');
    result_scA(index_cur_length,1)=ews_cur.pvalues(1);
    result_scA(index_cur_length,2)=ews_cur.pvalues(2);

    cur_res_scB=round(length_tot/cur_length_bursts);
    data_cur_scB=data_bftp(1:cur_res_scB:end);
    ews_cur=generic_ews(data_cur_scB,'winsize',30,'indicators',{'AR','std'},'ebisuzaki',100,'silent',true,'nanflag','omitnan');
    result_scB(index_cur_length,1)=ews_cur.pvalues(1);
    result_scB(index_cur_length,2)=ews_cur.pvalues(2);

    for index_cur_burst=1:n_bursts

        cur_bursts=bursts(index_cur_burst);

        %indexes of the data
        l_bursts=floor(cur_length_bursts/cur_bursts); %length of one burst
        rem=length_tot-cur_length_bursts*cur_res; %remaining amount of data points (not subsampled)
        spacing=floor(rem/(cur_bursts-1)); %Delta2, interval between 2 bursts

        indexes_data=round(linspace(1,l_bursts*cur_res,l_bursts)); %indexes of the first burst

        %subsample data
        data_cur=[]; index=[];
        for i=1:cur_bursts
            indexes_data_cur=indexes_data+(i-1)*(spacing+l_bursts);
            data_cur=cat(1,data_cur, data_bftp(indexes_data_cur));
            index=[index, repelem(i,l_bursts)];
        end

        cur_result=generic_ews_fixed(data_cur,'grouping',index','slopekind','ts','nanflag','omitnan');
        cislope=cur_result.CL.tsslope;

        %result_ar(index_cur_burst,index_cur_length)=table2array(cislope('slope_AR','p_value'));
        result_var_bursts(index_cur_burst,index_cur_length)=table2array(cislope('slope_std','p_value'));
        result_ar_bursts(index_cur_burst,index_cur_length)=table2array(cislope('slope_AR','p_value'));

    end
end
pval_scC=generic_ews(data_bftp,'winsize',30,'indicators',{'AR','std'},'ebisuzaki',1000,'silent',true,'nanflag','omitnan');
res_scC(1)=pval_scC.pvalues(1);
res_scC(2)=pval_scC.pvalues(2);

%save('data/results_case_study_depression_non_processed_pvals.mat','result_var_bursts');

%% process result


result_var=[result_scA(:,2) result_scB(:,2) result_var_bursts.'];
result_var(result_var>0.1)=3; result_var(result_var<0.05)=1; result_var(result_var>0.05&result_var<0.1)=2; 
x=NaN(length(length_bursts),1);
new_result=[result_var(:,1) x result_var(:,2) x result_var(:,3) x result_var(:,4) x result_var(:,5)];

%save('data/results_case_study_depression_processed_pvals.mat','new_result');

yvals={'Scenario I', 'Scenario II','2 bursts', '3 bursts','4 bursts'};
h=heatmap(length_bursts,yvals,result_var.','Colormap', parula(3),'CellLabelColor','none','MissingDataColor','1.00,1.00,1.00');
xlabel('Total number of data points (N)');
h.GridVisible = 'off'; 
h.ColorbarVisible = 'off';
ax = gca; 
ax.FontSize = 12; 

exportgraphics(h,'fig4d.pdf','BackgroundColor','none','ContentType','vector')

%% Plot

subplot(1,2,1)
plot(length_bursts,result_var_bursts(1,:),'LineWidth',2)
hold on
plot(length_bursts,result_var_bursts(2,:),'LineWidth',2)
plot(length_bursts,result_var_bursts(3,:),'LineWidth',2)
plot(length_bursts,result_scA(:,2),'LineWidth',2)
plot(length_bursts,result_scB(:,2),'LineWidth',2)
yline(0.05,'red','LineWidth',2)
yline(res_scC(2),'magenta','Perf scenario C','LineWidth',2)
hold off
xlabel('Total amount of data points'); ylabel('p-value');
legend({'2 bursts','3 bursts','4 bursts','MV - sc A', 'MV - sc B'})
title('Result of mv vs burst for PCA of neg moods, std')

subplot(1,2,2)
plot(length_bursts,result_ar_bursts(1,:),'LineWidth',2)
hold on
plot(length_bursts,result_ar_bursts(2,:),'LineWidth',2)
plot(length_bursts,result_ar_bursts(3,:),'LineWidth',2)
plot(length_bursts,result_scA(:,1),'LineWidth',2)
plot(length_bursts,result_scB(:,1),'LineWidth',2)
yline(0.05,'red','LineWidth',2)
scC=yline(res_scC(1),'magenta','Perf scenario C','LineWidth',2);
hold off
xlabel('Total amount of data points'); ylabel('p-value');
legend({'2 bursts','3 bursts','4 bursts','MV - sc A', 'MV - sc B'})
title('Result of mv vs burst for PCA of neg moods, AR')


%% plot 2

p1=plot(length_bursts,result_var_bursts(1,:),'LineWidth',2);
hold on
p2=plot(length_bursts,result_var_bursts(2,:),'LineWidth',2);
p3=plot(length_bursts,result_var_bursts(3,:),'LineWidth',2);
p4=plot(length_bursts,result_scA(:,2),'LineWidth',2);
p5=plot(length_bursts,result_scB(:,2),'LineWidth',2);
p6=yline(res_scC(2),'magenta','LineWidth',2);
xlim([200, 500]);
x=[200 200 600 600]; y=[0 0.05 0.05 0];
patch(x,y,[0.886, 0.133, 0.254], 'EdgeColor','none')
alpha(0.3)
hold off
ax = gca; 
ax.FontSize = 16; 
set(gca, 'box', 'off')
xlabel('Total amount of data points'); ylabel('p-value');
leg1=legend([p1, p2, p3],{'2 bursts','3 bursts','4 bursts'},'Location','NorthEast');set(leg1,'FontSize',14);
ah1=axes('position',get(gca,'position'),'visible','off');
leg2=legend(ah1,[p4 p5,p6],{'Scenario A', 'Scenario B', 'Scenario C'},'Location','NorthWest');set(leg2,'FontSize',14);
leg2.Title.String='Moving window approach';
leg1.Title.String='Burst approach';