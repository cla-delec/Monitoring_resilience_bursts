%%%%%%%%%%%%% LOAD THE DATA

%stationary data to calculate true positive rate
data_stationary=load('data/huge_dataset_vegetation_stationary_measurement_error_rep.mat');
data_stationary=data_stationary.data_big_measurement_error_stationary;

%data with increasing c (bifurcation parameter) to calculate true negative
%rate
data_moving=load('data/huge_dataset_vegetation_measurement_error_rep.mat');
data_moving=data_moving.data_big_measurement_error;

%%%%%%%%%%%%% SIMULATION PARAMETERS
length_tot=size(data_moving,1);
n_rep=size(data_moving,2); %number of repetitions
cur_res=3; %daily resolution

max_bursts=8;
bursts=1:max_bursts; 
n_bursts=size(bursts,2);

length_bursts=1000; %total length of data collected

%%%%%%%%%%%%% RESULT VECTORS
sensitivity_ARs_linearreg=zeros(n_bursts,1);
sensitivity_vars_linearreg=zeros(n_bursts,1);
specificity_ARs_linearreg=zeros(n_bursts,1);
specificity_vars_linearreg=zeros(n_bursts,1);

%%%%%%%%%%%%% SIMULATION
for cur_bursts=bursts

    sens_cur_var=0; sens_cur_var_sc2=0; sens_cur_var_sc3=0;
    sens_cur_ar=0; sens_cur_ar_sc2=0; sens_cur_ar_sc3=0;
    spec_cur_var=0; spec_cur_var_sc2=0; spec_cur_var_sc3=0;
    spec_cur_ar=0; spec_cur_ar_sc2=0; spec_cur_ar_sc3=0;

    for rep=1:n_rep

        if cur_bursts==1 %Rolling window approach
            
            %%% SCENARIO A Same resolution and number of data points, but
            %%% different gradient
            
            %measure of the true positive rate
            data_moving_cur_sc1=data_moving((length_tot-cur_res*length_bursts):cur_res:length_tot,rep); %subsample from big time series
            ews=generic_ews(data_moving_cur_sc1,'indicators',{'AR','std'},'silent',true,'ebisuzaki',100); %calculate the ebi p_val
            pval=ews.pvalues;

            sens_cur_ar=sens_cur_ar+(pval(1)<=0.1);
            sens_cur_var=sens_cur_var+(pval(2)<=0.1);
            
            %measure of the true negative rate
            data_stationary_cur_sc1=data_stationary((length_tot-cur_res*length_bursts):cur_res:length_tot,rep); %subsample from big time series
            ews=generic_ews(data_stationary_cur_sc1,'indicators',{'AR','std'},'silent',true,'ebisuzaki',100);
            pval=ews.pvalues;

            spec_cur_ar=spec_cur_ar+(pval(1)>0.1);
            spec_cur_var=spec_cur_var+(pval(2)>0.1);
            
            %%% SCENARIO B Different resolution but same gradient of c
            %%% (from beginning to end)
            
            %measure of the sensitivity
            res_sc2=length_tot/length_bursts; %calculate the resolution to keep same n of data points and same gradient
            data_moving_cur_sc2=data_moving(1:res_sc2:length_tot,rep);%subsample from big time series
            ews=generic_ews(data_moving_cur_sc2,'indicators',{'AR','std'},'silent',true,'ebisuzaki',100);
            pval=ews.pvalues;

            sens_cur_ar_sc2=sens_cur_ar_sc2+(pval(1)<=0.1);
            sens_cur_var_sc2=sens_cur_var_sc2+(pval(2)<=0.1);
            
            %measure of the specificity
            data_stationary_cur_sc2=data_stationary(1:res_sc2:length_tot,rep); %subsample from big time series
            ews=generic_ews(data_stationary_cur_sc2,'indicators',{'AR','std'},'silent',true,'ebisuzaki',100);
            pval=ews.pvalues;

            spec_cur_ar_sc2=spec_cur_ar_sc2+(pval(1)>0.1);
            spec_cur_var_sc2=spec_cur_var_sc2+(pval(2)>0.1);
            
            %%% SCENARIO C Same resolution and gradient, thus more data
            %%% points
            
            %measure of the sensitivity
            data_moving_cur_sc3=data_moving(1:cur_res:length_tot,rep); %subsample from big dataset, from beginning to end with current resolution
            ews=generic_ews(data_moving_cur_sc3,'indicators',{'AR','std'},'silent',true,'ebisuzaki',100);
            pval=ews.pvalues;

            sens_cur_ar_sc3=sens_cur_ar_sc3+(pval(1)<=0.1);
            sens_cur_var_sc3=sens_cur_var_sc3+(pval(2)<=0.1);
            
            %measure of the specificity
            data_stationary_cur_sc3=data_stationary(1:cur_res:length_tot,rep); %subsample from big dataset, from beginning to end with current resolution
            ews=generic_ews(data_stationary_cur_sc3,'indicators',{'AR','std'},'silent',true,'ebisuzaki',100);
            pval=ews.pvalues;

            spec_cur_ar_sc3=spec_cur_ar_sc3+(pval(1)>0.1);
            spec_cur_var_sc3=spec_cur_var_sc3+(pval(2)>0.1);
                   
        elseif cur_bursts>=2 %burst approach
            
            %indexes of the data
            l_bursts=floor(length_bursts/cur_bursts); %length of one burst
            rem=length_tot-length_bursts*cur_res; %remaining amount of data points (not subsampled)
            spacing=floor(rem/(cur_bursts-1)); %Delta2, interval between 2 bursts

            indexes_data=round(linspace(1,l_bursts*cur_res,l_bursts)); %indexes of the first burst
            
            %subsample data
            data_cur_moving=[]; data_cur_stat=[]; index=[];
            for i=1:cur_bursts
                indexes_data_cur=indexes_data+(i-1)*(spacing+l_bursts);
                data_cur_moving=cat(1,data_cur_moving, data_moving(indexes_data_cur,rep));
                data_cur_stat=cat(1,data_cur_stat, data_stationary(indexes_data_cur,rep));
                index=[index, repelem(i,l_bursts)];
            end

            %result for sensitivity
            result_moving=generic_ews_fixed(data_cur_moving,'grouping',index','slopekind','ts');
            cislope_moving=table2array(result_moving.CL);
            sens_cur_ar=sens_cur_ar+(cislope_moving(1,2)>0);
            sens_cur_var=sens_cur_var+(cislope_moving(2,2)>0);
            
            %result for specificity
            result_stat=generic_ews_fixed(data_cur_stat,'grouping',index','slopekind','ts');
            cislope_stat=table2array(result_stat.CL);
            
            if cislope_stat(1,2)<=0 && cislope_stat(1,3)>=0
                spec_cur_ar=spec_cur_ar+1;
            end 
            
            if cislope_stat(2,2)<=0 && cislope_stat(2,3)>=0
                spec_cur_var=spec_cur_var+1; 
            end 
        end  
    end
    
    %update global perf
    if cur_bursts==1
        sensitivity_ARs_linearreg(1)=sens_cur_ar/n_rep;
        sensitivity_vars_linearreg(1)=sens_cur_var/n_rep;  
        specificity_ARs_linearreg(1)=spec_cur_ar/n_rep;  
        specificity_vars_linearreg(1)=spec_cur_var/n_rep;  
        
        sensitivity_ARs_linearreg(2)=sens_cur_ar_sc2/n_rep;
        sensitivity_vars_linearreg(2)=sens_cur_var_sc2/n_rep;  
        specificity_ARs_linearreg(2)=spec_cur_ar_sc2/n_rep;  
        specificity_vars_linearreg(2)=spec_cur_var_sc2/n_rep; 
        
        sensitivity_ARs_linearreg(3)=sens_cur_ar_sc3/n_rep;
        sensitivity_vars_linearreg(3)=sens_cur_var_sc3/n_rep;  
        specificity_ARs_linearreg(3)=spec_cur_ar_sc3/n_rep;  
        specificity_vars_linearreg(3)=spec_cur_var_sc3/n_rep; 
    else
        sensitivity_ARs_linearreg(cur_bursts+2)=sens_cur_ar/n_rep;
        sensitivity_vars_linearreg(cur_bursts+2)=sens_cur_var/n_rep;  
        specificity_ARs_linearreg(cur_bursts+2)=spec_cur_ar/n_rep;  
        specificity_vars_linearreg(cur_bursts+2)=spec_cur_var/n_rep;  
    end
end


% %%%%%%%%%%%%% LOAD RESULTS 
% result_final=load("data/sensitivity_specificity_bursts3.mat");
% result_final=result_final.result_final;
% sensitivity_ARs_linearreg=result_final.sensitivity_ar;
% sensitivity_vars_linearreg=result_final.sensitivity_var;
% specificity_ARs_linearreg=result_final.specificity_ar;
% specificity_vars_linearreg=result_final.specificity_var;

%%%%%%%%%%%%% PLOT RESULTS 

res_sens=cat(2,sensitivity_ARs_linearreg,sensitivity_vars_linearreg);
res_spec=cat(2,specificity_ARs_linearreg,specificity_vars_linearreg);

%%% add 0 value to make space between RW and bursts
res_sens=cat(1,res_sens(1:3,:),[0,0],res_sens(4:end,:));
res_spec=cat(1,res_spec(1:3,:),[0,0],res_spec(4:end,:));

subplot(5,1,[1:2])
b=bar(res_sens);
b(1).FaceColor=[0.2275,0.6902,1];
b(2).FaceColor=[1, 0.7098, 0.3843];
xticklabels({'A','B','C','','2','3','4','5','6','7','8'})
xlabel('Number of bursts')
ylabel('True positive rate')
ax = gca; 
ax.FontSize = 16; 

subplot(5,1,3)
b=bar(zeros(3,2));
b(1).FaceColor=[0.2275,0.6902,1];
b(2).FaceColor=[1, 0.7098, 0.3843];
set(gca, 'box', 'off')
set(gca,'ytick',[])
set(gca,'xtick',[])
set(gca,'Visible','off')
legend('Autocorrelation','Variance','Location','south')
ax = gca; 
ax.FontSize = 12; 

subplot(5,1,[4:5])
b=bar(res_spec);
b(1).FaceColor=[0.2275,0.6902,1];
b(2).FaceColor=[1, 0.7098, 0.3843];
xticklabels({'A','B','C','','2','3','4','5','6','7','8'})
xlabel('Number of bursts')
ylabel('True negative rate')
ax = gca; 
ax.FontSize = 16; 

%%%%%%%%%%%%% SAVE RESULTS 
% 
% result_final.sensitivity_ar=sensitivity_ARs_linearreg;
% result_final.sensitivity_var=sensitivity_vars_linearreg;
% result_final.specificity_ar=specificity_ARs_linearreg;
% result_final.specificity_var=specificity_vars_linearreg;
% save("data/sensitivity_specificity_bursts3.mat","result_final");