%model harvesting2_noise_inc.ini
%This program measure the true positive rate depending on Delta_1 (interval
%between two bursts)and n (the number of bursts), when we assume that lambda 
%(the length of a burst) is fixed. It then creates a heatmap of true
%positive rate depending on Delta 1 and n (fig 7)
%We measure that for three values of lambda

%% LOAD THE DATA

data_big=load("data/huge_dataset_vegetation_measurement_error_rep.mat");
data_big=data_big.data_big_measurement_error;

%% SIMULATION PARAMETERS

length_tot=size(data_big,1);
n_rep=size(data_big,2); %number of repetitions

max_bursts=8;
bursts=2:max_bursts;
n_bursts=size(bursts,2);

lengths_bursts=[100, 200, 300]; %length of one burst, lambda values
%lengths_bursts=200;

%delta_1 values
resolutions=1:2:16;
n_res=length(resolutions);
resolution_days=round(resolutions/3,1); %convert delta_1 to days

%% RESULT VECTORS

res_ARs_linearreg=zeros(n_bursts,n_res,size(lengths_bursts,2));
res_vars_linearreg=zeros(n_bursts,n_res,size(lengths_bursts,2));

perf_ref_ar=zeros(3,1); perf_ref_var=zeros(3,1);

%% SIMULATION

for ind_cur_length_burst=1:size(lengths_bursts,2) %for each lambda value
    cur_length_burst=lengths_bursts(ind_cur_length_burst);
    
    for cur_bursts=bursts %for each number of bursts

        for ind_cur_res=1:n_res %for each resolution / delta_1
            perf_cur_var=0;
            perf_cur_ar=0;
            cur_res=resolutions(ind_cur_res);
            
            for rep=1:n_rep
                indexes_data=round(linspace(1,((cur_length_burst-1)*cur_res+1),cur_length_burst)); %index of the first burst
                
                length_one_burst_w_res=max(indexes_data);
                length_bursts_w_res=length_one_burst_w_res*cur_bursts;
                
                rem=length_tot-length_bursts_w_res; %remaining amount of data points not used in the subsamples
                spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts

                data_cur=[]; index=[];
                for i=1:cur_bursts
                    indexes_data_cur=indexes_data+(i-1)*(spacing+length_one_burst_w_res);
                    data_cur=cat(1,data_cur, data_big(indexes_data_cur,rep)); %subsample from the big dataset
                    index=[index, repelem(i,cur_length_burst)]; %create the indexes needed for generic_ews_fixed
                end

                
                
                %we consider the slope to be significantly different than 0 
                %if the lower bound of the confidence interval of the slope is higher than 0
                result=generic_ews_fixed(data_cur,'grouping',index','slopekind','ts');
                %cislope=result.CL;
                res_slope=result.CL.tsslope;
                perf_cur_ar=perf_cur_ar+(table2array(res_slope('slope_AR','p_value'))<0.05);
                perf_cur_var=perf_cur_var+(table2array(res_slope('slope_std','p_value'))<0.05);
                
            end
            
            %update the result vectors
            res_ARs_linearreg(cur_bursts,ind_cur_res,ind_cur_length_burst)=perf_cur_ar/n_rep;
            res_vars_linearreg(cur_bursts,ind_cur_res,ind_cur_length_burst)=perf_cur_var/n_rep;  
        end
    end
end

%% SAVE THE RESULT VECTORS

res_several_100_200_300.res_absolute_var=res_vars_linearreg;
res_several_100_200_300.res_absolute_ar=res_ARs_linearreg;
save('data/result_burst_resolution_samelengthburst100_200_300_pval_v5.mat','res_several_100_200_300');

%% LOAD THE RESULT VECTORS

res_several_100_200_300 = load('data/result_burst_resolution_samelengthburst100_200_300_pval_v5.mat');
res_several_100_200_300=res_several_100_200_300.res_several_100_200_300;
res_ARs_linearreg=res_several_100_200_300.res_absolute_ar;
res_vars_linearreg=res_several_100_200_300.res_absolute_var;

%% PLOT THE RESULTS

subplot(1,2,1)
h=heatmap(resolution_days,bursts,res_ARs_linearreg(2:end,:,1),'Colormap', parula(20),'CellLabelColor','none'); 
h.GridVisible = 'off';  h.ColorbarVisible = 'off';
ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation'})
ax = gca; 
ax.FontSize = 12; 

subplot(1,2,2)
h=heatmap(resolution_days,bursts,res_vars_linearreg(2:end,:,1),'Colormap', parula(20),'CellLabelColor','none'); 
h.GridVisible = 'off'; 
% annotation('textarrow',[0.99,0.99],[0.96,0.96],'string','Sensitivity', ...
%       'HeadStyle','none','LineStyle','none','HorizontalAlignment','center','FontSize',10);
ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance'})
ax = gca; 
ax.FontSize = 12; 

%% PLOT FULL FIGURE - SI

for i = 1:size(lengths_bursts,2)
    str_title="for \lambda = "+lengths_bursts(i);
    
    subplot(2,3,i)
    h=heatmap(resolution_days,bursts,res_ARs_linearreg(2:end,:,i),'Colormap', parula(20),'CellLabelColor','none'); 
    h.GridVisible = 'off';  
    ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation',str_title})
    ax = gca; 
    ax.FontSize = 12;
    
    subplot(2,3,i+3)
    h=heatmap(resolution_days,bursts,res_vars_linearreg(2:end,:,i),'Colormap', parula(20),'CellLabelColor','none'); 
    h.GridVisible = 'off'; 
    % annotation('textarrow',[0.96,0.96],[0.96,0.96],'string','TPR', ...
    %       'HeadStyle','none','LineStyle','none','HorizontalAlignment','center','FontSize',10);
    ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance',str_title})
    ax = gca; 
    ax.FontSize = 12;
end 


