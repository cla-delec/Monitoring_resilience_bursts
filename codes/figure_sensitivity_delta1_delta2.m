%This program uses the results from sensitivity_delta1.m and
%sensitivity_delta2.m to create the four panels of fig4. It uses the deltac
%values calculated in calc_deltac.m as x axis values for the plots of sensitivity vs delta2

%%%%%%%%%%%%% LOAD THE RESULTS

result_final_delta1=load("data/sensitivity_delta1_pval_3.mat");
result_final_delta1=result_final_delta1.result_final_delta1;
res_vars_linearreg_delta1=result_final_delta1.res_vars_linearreg_delta1;
res_ARs_linearreg_delta1=result_final_delta1.res_ARs_linearreg_delta1;

result_final_delta2=load("data/sensitivity_delta2_pval_3.mat");
result_final_delta2=result_final_delta2.result_final_delta2;
res_vars_linearreg_delta2=result_final_delta2.res_vars_linearreg_delta2;
res_ARs_linearreg_delta2=result_final_delta2.res_ARs_linearreg_delta2;

delta_c_values=load("data/delta_c_values.mat");
delta_c_values=delta_c_values.delta_c;

%%%%%%%%%%%%% SIMULATION PARAMETERS
%used as values for the x axis
n_delta1=20;
values_delta1=1:n_delta1;

length_tot=size(delta_c_values,1);
high_delta1=9;
length_bursts=1000;
n_delta2=20;
delta2_min=100; 
delta2_max=(round(length_tot-length_bursts*high_delta1));
deltas2=round(linspace(delta2_min,delta2_max,n_delta2));

deltas2_days=round(deltas2/3); %convert the intervals in days
deltas1_days=values_delta1/3; %convert the intervals in days

%%%%%%%%%%%%% PLOT RESULTS

colors=[[0.2275,0.6902,1]; [1, 0.7098, 0.3843]; [0.9725, 0.4549, 0.4549]; [0.2431, 0.7804, 0.0431]];

subplot(2,2,3)
for i=1:2
   hold on
   plot(delta_c_values,res_ARs_linearreg_delta2(:,i),'Color',colors(i,:),'LineStyle','-','LineWidth',3)
end
xlabel('Difference in resilience between two bursts \Delta_c'); ylabel('True positive rate');
legend({'Low \Delta_1 (1 day)','High \Delta_1 (3 days)'}, 'Location','southeast');
title('Autocorrelation')
hold off

subplot(2,2,4)
for i=1:2
   hold on
   plot(delta_c_values,res_vars_linearreg_delta2(:,i),'Color',colors(i,:),'LineStyle','-','LineWidth',3)
end
xlabel('Difference in resilience between two bursts \Delta_c'); ylabel('True positive rate');
legend({'Low \Delta_1 (1 day)','High \Delta_1 (3 days)'}, 'Location','southeast');
title('Variance')
hold off

subplot(2,2,1)
for i=1:2
   hold on
   plot(deltas1_days,res_ARs_linearreg_delta1(:,i),'Color',colors(i,:),'LineStyle','-','LineWidth',3)
end
xlabel('Interval between two samples \Delta_1 (days)'); ylabel('True positive rate');
legend({'low \Delta_c  (0.1)','high \Delta_c (0.88)'}, 'Location','southeast');
title('Autocorrelation')
hold off

subplot(2,2,2)
for i=1:2
   hold on
   plot(deltas1_days,res_vars_linearreg_delta1(:,i),'Color',colors(i,:),'LineStyle','-','LineWidth',3)
end
xlabel('Interval between two samples \Delta_1 (days)'); ylabel('True positive rate');
legend({'low \Delta_c (0.1)','high \Delta_c (0.88)'}, 'Location','southeast');
title('Variance')
hold off