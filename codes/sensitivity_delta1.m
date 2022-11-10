%model harvesting2_noise_inc.ini

%%%%%%%%%%%%% LOAD THE DATA

data_big=load("data/huge_dataset_vegetation_measurement_error_rep.mat");
data_big=data_big.data_big_measurement_error;

%%%%%%%%%%%%% SIMULATION PARAMETERS

length_tot=size(data_big,1);
n_rep=size(data_big,2);

n_bursts=2;
length_bursts=1000; %total length of the data
l_bursts=floor(length_bursts/n_bursts); %length of one burst
res=3;

low_delta2=400;
high_delta2=1000;

n_delta1=20;
values_delta1=1:n_delta1;

%%%%%%%%%%%%% RESULT VECTORS

res_ARs_linearreg_delta1=zeros(n_delta1,2);
res_vars_linearreg_delta1=zeros(n_delta1,2);

%%%%%%%%%%%%% SIMULATION

for cur_delta1=1:n_delta1
    perf_cur_ar_delta1_low_delta2=0; perf_cur_ar_delta1_high_delta2=0;
    perf_cur_var_delta1_low_delta2=0; perf_cur_var_delta1_high_delta2=0;
    
    for rep=1:n_rep
            %%% for high delta 2
            indexes_data=round(linspace(length_tot-l_bursts*cur_delta1,length_tot,l_bursts)); %indexes data last burst 

            data_cur_high_delta2=[]; groups=[];
            for i=1:n_bursts
                indexes_data_cur=indexes_data-(i-1)*(high_delta2+l_bursts);
                data_cur_high_delta2=cat(1, data_big(indexes_data_cur,rep), data_cur_high_delta2);
                groups=[repelem((n_bursts-i+1),l_bursts), groups];
            end

            result_high_delta2=generic_ews_fixed(data_cur_high_delta2,'grouping',groups','slopekind','ts');
            cislope_high_delta2=table2array(result_high_delta2.CL);
            perf_cur_ar_delta1_high_delta2=perf_cur_ar_delta1_high_delta2+(cislope_high_delta2(1,2)>0);
            perf_cur_var_delta1_high_delta2=perf_cur_var_delta1_high_delta2+(cislope_high_delta2(2,2)>0);

            %%% for low delta 2
            indexes_data=round(linspace(length_tot-l_bursts*cur_delta1,length_tot,l_bursts)); %indexes data last burst 

            data_cur_low_delta2=[]; groups=[];
            for i=1:n_bursts
                indexes_data_cur=indexes_data-(i-1)*(low_delta2+l_bursts);
                data_cur_low_delta2=cat(1, data_big(indexes_data_cur,rep), data_cur_low_delta2);
                groups=[repelem((n_bursts-i+1),l_bursts), groups];
            end

            result_low_delta2=generic_ews_fixed(data_cur_low_delta2,'grouping',groups','slopekind','ts');
            cislope_low_delta2=table2array(result_low_delta2.CL);
            perf_cur_ar_delta1_low_delta2=perf_cur_ar_delta1_low_delta2+(cislope_low_delta2(1,2)>0);
            perf_cur_var_delta1_low_delta2=perf_cur_var_delta1_low_delta2+(cislope_low_delta2(2,2)>0);

    end  
        
    res_ARs_linearreg_delta1(cur_delta1,1)=perf_cur_ar_delta1_low_delta2/n_rep;
    res_ARs_linearreg_delta1(cur_delta1,2)=perf_cur_ar_delta1_high_delta2/n_rep;
    res_vars_linearreg_delta1(cur_delta1,1)=perf_cur_var_delta1_low_delta2/n_rep;  
    res_vars_linearreg_delta1(cur_delta1,2)=perf_cur_var_delta1_high_delta2/n_rep;  
end

result_final_delta1.res_vars_linearreg_delta1=res_vars_linearreg_delta1;
result_final_delta1.res_ARs_linearreg_delta1=res_ARs_linearreg_delta1;
save("data/sensitivity_delta1.mat","result_final_delta1");
