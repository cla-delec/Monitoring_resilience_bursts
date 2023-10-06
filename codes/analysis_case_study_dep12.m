%%% FIG TREND IN AR FOR DIFFERENT SCENARIOS

data=readtable("case-study/data_depression/ESMdata.txt");

%% FIND TIPPING POINT

date_initial=data.date(1);
date_change=date_initial+127; %date tipping point according to wichers et al. 2016
index_change=find(data.date==date_change, 1 );

index_all=[1, 7, 10:29, 39:46];
data_all=data(:,index_all);
data_all=rmmissing(data_all);
dates=data_all(:,1);
resp_time_dates=data_all(:,2);
data_all_array=table2array(data_all(:,3:end));

date_end_baseline=date_initial+28;
index_end_baseline=find(data.date==date_end_baseline, 1 );


%% PCA of negative variables

index_data_neg=[2,3,5,6,8,10,11,13,14,15,18,19,22,23];
data_neg=data_all_array(:,index_data_neg);
data_neg_array= rmmissing(data_neg);

data_all_baseline=data_neg_array(1:index_end_baseline,:);
[coeff,score,latent] = pca(data_all_baseline);
projected_neg_data_pc=data_neg_array*coeff(:,1);

data_bftp=projected_neg_data_pc(1:index_change,:);
length_tot=size(data_bftp,1);

%% MV analysis of pca data

ews_cur=generic_ews(data_bftp,'winsize',30,'indicators',{'AR'},'ebisuzaki',1000,'silent',true);
ar_pca_neg=ews_cur.indicators;

%% MV analysis scenario B - pca data

cur_length=300;
cur_res=round(length_tot/cur_length);
data_cur_scB=data_bftp(1:cur_res:end);
ews_cur_scB=generic_ews(data_cur_scB,'winsize',30,'indicators',{'AR'},'ebisuzaki',100,'silent',true);
ar_pca_neg_scB=ews_cur_scB.indicators;

%% MV analysis - aggregate per day

%calc days since start and then calculate avg group per day
date_init=table2array(dates(1,1));
day_since_start=table2array(dates)-date_init;
[hour_since_start, minute_since_start, second_since_start] = hms(day_since_start);

pca_mood_hour=[hour_since_start(1:index_change), projected_neg_data_pc(1:index_change)];
new_names=["hour", "pca_mood"];
pca_mood_hour=array2table(pca_mood_hour,'VariableNames',new_names);
avg_mood_hour = grpstats(pca_mood_hour,"hour");
avg_mood_day=avg_mood_hour.mean_pca_mood;
cur_res2=round(length_tot/length(avg_mood_day));

ews_cur_aggregate=generic_ews(avg_mood_day,'winsize',30,'indicators',{'AR'},'ebisuzaki',100,'silent',true);
ar_pca_neg_aggregate=ews_cur_aggregate.indicators;

%% Add NaNs 

date_all_precise=datetime(string(table2array(dates))+" "+string(table2array(resp_time_dates)));
date_initial_precise=date_all_precise(1);
distance_points=diff(date_all_precise);

data_all_precise_bftp=date_all_precise(1:index_change);
distance_points_bftp=diff(data_all_precise_bftp);
[hour, minute, second] = hms(distance_points_bftp);

threshold=4;
index_too_long=find(hour>threshold);
new_data_thresh4=data_bftp.';

for i=length(index_too_long):-1:1
    new_data_thresh4=[new_data_thresh4(1:index_too_long(i)) missing new_data_thresh4((index_too_long(i)+1):end)];
end

ews_cur_thresh4=generic_ews(new_data_thresh4,'winsize',30,'indicators',{'AR'},'silent',true,'ebisuzaki',100,'nanflag','omitnan');
ar_thresh4=ews_cur_thresh4.indicators;

threshold=6;
index_too_long=find(hour>threshold);
new_data_thresh6=data_bftp.';

for i=length(index_too_long):-1:1
    new_data_thresh6=[new_data_thresh6(1:index_too_long(i)) missing new_data_thresh6((index_too_long(i)+1):end)];
end

ews_cur_thresh6=generic_ews(new_data_thresh6,'winsize',30,'indicators',{'AR'},'silent',true,'ebisuzaki',100,'nanflag','omitnan');
ar_thresh6=ews_cur_thresh6.indicators;

%% daily detrending

data_detrended_daily=load("data/data_case_study_dep_detrended_daily.mat");
data_detrended_daily=data_detrended_daily.data_detrended;
data_detrended_daily=data_detrended_daily(:,(index_data_neg+1));

data_detrended_baseline=data_detrended_daily(1:index_end_baseline,2:end);
[coeff2,score,latent] = pca(data_detrended_baseline);
projected_detrended_data=data_detrended_daily(:,2:end)*coeff2(:,1);

projected_detrended_data_bftp=projected_detrended_data(1:index_change,:);

ews_cur_detrended_pca=generic_ews(rmmissing(projected_detrended_data_bftp),'winsize',30,'indicators',{'AR'},'silent',true,'ebisuzaki',100);
ar_detrended_pca=ews_cur_detrended_pca.indicators;

%% plots

plot(1:length_tot,ar_pca_neg,'LineWidth',2)
hold on
plot(1:cur_res:length_tot,ar_pca_neg_scB,'LineWidth',2)
plot(linspace(1,length_tot,length(avg_mood_day)),ar_pca_neg_aggregate,'LineWidth',2)
plot(linspace(1,length_tot,length(new_data_thresh4)),ar_thresh4,'LineWidth',2)
plot(linspace(1,length_tot,length(new_data_thresh6)),ar_thresh6,'LineWidth',2)
plot(linspace(1,length_tot,length(ar_detrended_pca)),ar_detrended_pca,'LineWidth',2)
hold off
xlabel('Time'); ylabel('Trend in autocorrelation');
h1=get(gca,'xlabel'); h2=get(gca,'ylabel');
set(h1, 'FontSize', 14); set(h2, 'FontSize', 14);
legend(["All data - p-val=0.056","Reduced resolution (scenario B) - p-val=0.05","Data aggregated per day - p-val=0.03","Not used when interval > 4 hours - p-val=0.06","Not used when interval > 6 hours - p-val=0.05","Detrended daily cycles - p-val=0.07"],'FontSize',14)