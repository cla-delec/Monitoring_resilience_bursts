%model harvesting2_noise_inc.ini
%This program measure the true positive rate depending on Delta_2 (interval
%between two bursts). Delta_2 can also be expressed as a difference in
%resilience
%We measure that for two values of Delta_1 (interval between two samples)


%%%%%%%%%%%%% LOAD THE DATA

data_big=load("data/huge_dataset_vegetation_measurement_error_rep.mat");
data_big=data_big.data_big_measurement_error;

%%%%%%%%%%%%% SIMULATION PARAMETERS

length_tot=size(data_big,1);
n_rep=size(data_big,2);

n_bursts=2;
length_bursts=1000; %total length of the data
l_bursts=floor(length_bursts/n_bursts); %length of one burst

%values for delta1
low_delta1=3; 
high_delta1=15;

%Delta 2 values used for the calculations
n_delta2=20;
delta2_min=100; 
delta2_max=(round(length_tot-length_bursts*high_delta1));
deltas2=round(linspace(delta2_min,delta2_max,n_delta2));

%%%%%%%%%%%%% RESULT VECTORS

res_ARs_linearreg_delta2=zeros(n_delta2,2);
res_vars_linearreg_delta2=zeros(n_delta2,2);

%%%%%%%%%%%%% SIMULATION

    
for ind_cur_delta2=1:n_delta2
    perf_cur_ar_delta2_high_delta1=0; perf_cur_ar_delta2_low_delta1=0;
    perf_cur_var_delta2_high_delta1=0; perf_cur_var_delta2_low_delta1=0;
    cur_delta2=deltas2(ind_cur_delta2);
    
    for rep=1:n_rep
            %%% for low delta 1
            indexes_data=round(linspace(length_tot-l_bursts*low_delta1,length_tot,l_bursts)); %indexes data last burst 

            data_cur_low_delta1=[]; groups=[];
            for i=1:n_bursts
                indexes_data_cur=indexes_data-(i-1)*(cur_delta2+l_bursts); 
                data_cur_low_delta1=cat(1, data_big(indexes_data_cur,rep), data_cur_low_delta1); %subsample from the big dataset
                groups=[repelem((n_bursts-i+1),l_bursts), groups]; %create the indexes needed for generic_ews_fixed
            end

            result_low_delta1=generic_ews_fixed(data_cur_low_delta1,'grouping',groups','slopekind','ts');
%             cislope_low_delta1=table2array(result_low_delta1.CL);
%             
%             %we consider the slope to be significantly different than 0 
%             %if the lower bound of the confidence interval of the slope is higher than 0
%             perf_cur_ar_delta2_low_delta1=perf_cur_ar_delta2_low_delta1+(cislope_low_delta1(1,2)>0);
%             perf_cur_var_delta2_low_delta1=perf_cur_var_delta2_low_delta1+(cislope_low_delta1(2,2)>0);
            res_slope_low_delta1=result_low_delta1.CL.tsslope;
            perf_cur_ar_delta2_low_delta1=perf_cur_ar_delta2_low_delta1+(table2array(res_slope_low_delta1('slope_AR','p_value'))<0.05);
            perf_cur_var_delta2_low_delta1=perf_cur_var_delta2_low_delta1+(table2array(res_slope_low_delta1('slope_std','p_value'))<0.05);
            


            %%% for high delta 1
            indexes_data=round(linspace(length_tot-l_bursts*high_delta1,length_tot,l_bursts)); %indexes data last burst 

            data_cur_high_delta1=[]; groups=[];
            for i=1:n_bursts
                indexes_data_cur=indexes_data-(i-1)*(cur_delta2+l_bursts); 
                data_cur_high_delta1=cat(1, data_big(indexes_data_cur,rep), data_cur_high_delta1);  %subsample from the big dataset
                groups=[repelem((n_bursts-i+1),l_bursts), groups]; %create the indexes needed for generic_ews_fixed
            end

            result_high_delta1=generic_ews_fixed(data_cur_high_delta1,'grouping',groups','slopekind','ts');
%             cislope_high_delta1=table2array(result_high_delta1.CL);
%             
%             %we consider the slope to be significantly different than 0 
%             %if the lower bound of the confidence interval of the slope is higher than 0
%             perf_cur_ar_delta2_high_delta1=perf_cur_ar_delta2_high_delta1+(cislope_high_delta1(1,2)>0);
%             perf_cur_var_delta2_high_delta1=perf_cur_var_delta2_high_delta1+(cislope_high_delta1(2,2)>0);
            res_slope_high_delta1=result_high_delta1.CL.tsslope;
            perf_cur_ar_delta2_high_delta1=perf_cur_ar_delta2_high_delta1+(table2array(res_slope_high_delta1('slope_AR','p_value'))<0.05);
            perf_cur_var_delta2_high_delta1=perf_cur_var_delta2_high_delta1+(table2array(res_slope_high_delta1('slope_std','p_value'))<0.05);
  


    end  
        
    res_ARs_linearreg_delta2(ind_cur_delta2,1)=perf_cur_ar_delta2_low_delta1/n_rep;
    res_ARs_linearreg_delta2(ind_cur_delta2,2)=perf_cur_ar_delta2_high_delta1/n_rep;
    res_vars_linearreg_delta2(ind_cur_delta2,1)=perf_cur_var_delta2_low_delta1/n_rep;  
    res_vars_linearreg_delta2(ind_cur_delta2,2)=perf_cur_var_delta2_high_delta1/n_rep;  
end

%%%%%%%%%%%%% SAVE THE RESULT VECTORS

result_final_delta2.res_vars_linearreg_delta2=res_vars_linearreg_delta2;
result_final_delta2.res_ARs_linearreg_delta2=res_ARs_linearreg_delta2;
save("data/sensitivity_delta2_pval_3.mat","result_final_delta2");
