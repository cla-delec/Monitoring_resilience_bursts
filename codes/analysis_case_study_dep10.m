%%%% pval with diff window size for mv analyses - multivariate indicators

data=readtable("case-study/data_depression/ESMdata.txt");
% data_detrended=load("data/data_case_study_dep_detrended_daily.mat");
% data_detrended=data_detrended.data_detrended;
% data_detrended=data_detrended(:,2:end);

%%%%%%%%%%%%% KEEP UNIQUE DEPRESSION SCORE AND PLOT

nan_dep=find(~isnan(data.dep));
data_dep=unique(data(nan_dep, [1, 85]));
%plot(data_dep.date,data_dep.dep)

%%%%%%%%%%%%% FIND TIPPING POINT

date_initial=data.date(1);
date_change=date_initial+127; %date tipping point according to wichers et al. 2016
index_change=find(data.date==date_change, 1 );
index_change_data_dep=find(data_dep.date==date_change, 1 );

%%%%%%%%%%%%% INDEX TIME SERIES 

index_all=[10:29, 39:46];
data_all=data(:,index_all);
index_data_neg=[2,3,5,6,8,10,11,13,14,15,18,19,22,23];
data_neg=data_all(:,index_data_neg);
names=data_neg.Properties.VariableNames;

data_neg_bftp=table2array(data_neg(1:index_change,:));
data_neg_bftp=rmmissing(data_neg_bftp);

%%%%%%%%%%%%% MV ANALYSIS - SIMULATION 

win_sizes=[25, 28, 30, 35, 40, 50];
n_win_sizes=size(win_sizes,2);
p_values=zeros(2,n_win_sizes);
for ind_win_size=1:n_win_sizes
    %data_cur=rmmissing(table2array(data_all_bftp(:,index)));
    %ews_cur=generic_ews(data_cur,'winsize',win_sizes(ind_win_size),'indicators',{'AR','std'},'ebisuzaki',100,'silent',true);
    ews=generic_ews(data_neg_bftp,'winsize',win_sizes(ind_win_size),'indicators',{'mean_ar','mean_var'},'datacolumn',[],'silent',true,'ebisuzaki',100);
    p_values(:,ind_win_size)=ews.pvalues;
end


plot(win_sizes,squeeze(p_values(1,:)),'LineWidth',5)
hold on
plot(win_sizes,squeeze(p_values(2,:)),'LineWidth',5)
hold off
xlabel('Window size')
ylabel('Pvalue')
yline(0.05,'r')
legend({'Mean AR','Mean var'})


