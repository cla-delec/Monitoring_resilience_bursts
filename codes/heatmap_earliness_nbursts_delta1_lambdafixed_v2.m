%model harvesting2_noise_inc.ini
%This program measure the true positive rate depending on Delta_1 (interval
%between two bursts)and n (the number of bursts), when we assume that N 
%(the total length of data) is fixed. It then creates a heatmap of true
%positive rate depending on Delta 1 and n (fig 6)
%We measure that for three values of N

%% LOAD THE DATA

data_big=load("data/huge_dataset_vegetation_measurement_error_rep.mat");
data_big=data_big.data_big_measurement_error;

%% SIMULATION PARAMETERS

length_tot=size(data_big,1);
n_rep=size(data_big,2); %number of repetitions
%n_rep=100;

max_bursts=8;
bursts=2:max_bursts;
n_bursts=size(bursts,2);
%bursts=2;

%lengths_bursts=[100, 200, 300];
length_bursts=200; 

%delta_1 values
resolutions=1:2:16;
n_res=length(resolutions);
resolutions_days=round(resolutions/3,1);
%n_res=1;

%% RESULT VECTORS

res_ARs_linearreg2=zeros(n_bursts,n_res,size(length_bursts,2));
res_vars_linearreg2=zeros(n_bursts,n_res,size(length_bursts,2));


%% SIMULATION

for ind_cur_length_bursts=1:size(length_bursts,2) %for each N value
    cur_length_bursts=length_bursts(ind_cur_length_bursts);
    
    for cur_bursts=bursts(2:end) %for each number of bursts

        for ind_cur_res=1:n_res %for each resolution / delta_1
            perf_cur_var=zeros(n_rep,1);
            perf_cur_ar=zeros(n_rep,1);
            cur_res=resolutions(ind_cur_res);

            for rep=1:n_rep

                indexes_data=round(linspace(1,((cur_length_bursts-1)*cur_res+1),cur_length_bursts)); %index of the first burst
                
                length_one_burst_w_res=max(indexes_data);
                length_bursts_w_res=length_one_burst_w_res*cur_bursts;
                
                rem=length_tot-length_bursts_w_res; %remaining amount of data points not used in the subsamples
                spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts

                data_cur=[]; index=[];
                for i=1:cur_bursts
                    indexes_data_cur=indexes_data+(i-1)*(spacing+length_one_burst_w_res);
                    data_cur=cat(1,data_cur, data_big(indexes_data_cur,rep)); %subsample from the big dataset
                    index=[index, repelem(i,cur_length_bursts)]; %create the indexes needed for generic_ews_fixed
                end
                
                for n_burst_early=cur_bursts:-1:2
                    index_max=find(index==n_burst_early,1,'last');
                    
                    result=generic_ews_fixed(data_cur(1:index_max),'grouping',index(1:index_max)','slopekind','ts', 'detrending', 'no');
                    res_slope=result.CL.tsslope;
                    
                    if table2array(res_slope('slope_AR','p_value'))<0.05
                        perf_cur_ar(rep)=(cur_bursts-n_burst_early)*(spacing+length_one_burst_w_res);
                    end
                    
                    if table2array(res_slope('slope_std','p_value'))<0.05
                        perf_cur_var(rep)=(cur_bursts-n_burst_early)*(spacing+length_one_burst_w_res);
                    end
                    
                end
            
            end
            
            %update the result vectors
            res_ARs_linearreg2(cur_bursts-1,ind_cur_res,ind_cur_length_bursts)=mean(perf_cur_ar);
            res_vars_linearreg2(cur_bursts-1,ind_cur_res,ind_cur_length_bursts)=mean(perf_cur_var);  
        end
    end
end

%% SAVE THE RESULT VECTORS

res_several_500_1000_1500.res_absolute_var=res_vars_linearreg2;
res_several_500_1000_1500.res_absolute_ar=res_ARs_linearreg2;
save('data/result_burst_resolution_500_lambdafixed_earliness.mat','res_several_500_1000_1500');

%% LOAD RESULTS

res_several_500_1000_1500 = load('data/result_burst_resolution_500_lambdafixed_earliness.mat');
res_several_500_1000_1500=res_several_500_1000_1500.res_several_500_1000_1500;
res_ARs_linearreg2=res_several_500_1000_1500.res_absolute_ar;
res_vars_linearreg2=res_several_500_1000_1500.res_absolute_var;
% 
%% PLOT THE RESULTS


subplot(1,2,1)
h=heatmap(resolutions_days,bursts,res_ARs_linearreg2(:,:,1)/3,'Colormap', parula(20),'CellLabelColor','none'); 
h.GridVisible = 'off';  h.ColorbarVisible = 'off';
ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation'})
ax = gca; 
ax.FontSize = 12; 

subplot(1,2,2)
h=heatmap(resolutions_days,bursts,res_vars_linearreg2(:,:,1)/3,'Colormap', parula(20),'CellLabelColor','none'); 
h.GridVisible = 'off'; 
% annotation('textarrow',[0.96,0.96],[0.96,0.96],'string','TPR', ...
%       'HeadStyle','none','LineStyle','none','HorizontalAlignment','center','FontSize',10);
ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance'})
ax = gca; 
ax.FontSize = 12; 

%% PLOT FULL FIGURE - SI
% 
% for i = 1:size(length_bursts,2)
%     str_title="for N = "+length_bursts(i);
%     
%     subplot(2,3,i)
%     h=heatmap(resolutions_days,bursts,res_ARs_linearreg2(:,:,i),'Colormap', parula(20),'CellLabelColor','none'); 
%     h.GridVisible = 'off';  
%     ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation',str_title})
%     ax = gca; 
%     ax.FontSize = 12;
%     
%     subplot(2,3,i+3)
%     h=heatmap(resolutions_days,bursts,res_vars_linearreg2(:,:,i),'Colormap', parula(20),'CellLabelColor','none'); 
%     h.GridVisible = 'off'; 
%     % annotation('textarrow',[0.96,0.96],[0.96,0.96],'string','TPR', ...
%     %       'HeadStyle','none','LineStyle','none','HorizontalAlignment','center','FontSize',10);
%     ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance',str_title})
%     ax = gca; 
%     ax.FontSize = 12;
% end 


