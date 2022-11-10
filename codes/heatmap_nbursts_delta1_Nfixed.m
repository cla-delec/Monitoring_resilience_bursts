%data_big=load("data/huge_dataset_vegetation_rep.mat");
%data_big=load("data/huge_dataset_ising.mat");
%data_big=data_big.data_big;

data_big=load("data/huge_dataset_vegetation_measurement_error_rep.mat");
data_big=data_big.data_big_measurement_error;

length_tot=size(data_big,1);
%n_rep=size(data_big,2);
%n_rep=10;

max_bursts=8;
bursts=2:max_bursts;
n_bursts=size(bursts,2);

length_bursts=1000; %[500 1000 1500]; %total length of data collected

n_res=8;

res_ARs_linearreg=zeros(n_bursts,n_res,size(length_bursts,2));
res_vars_linearreg=zeros(n_bursts,n_res,size(length_bursts,2));

perf_ref_var=zeros(3,1); perf_ref_ar=zeros(3,1); 

for ind_cur_length_bursts=1:size(length_bursts,2)
    
    cur_length_bursts=length_bursts(ind_cur_length_bursts);
    
    %measure performance for the reference/moving window
    res_ref=length_tot/cur_length_bursts;
    perf_ref_ar_cur=0; perf_ref_var_cur=0;

    data_moving_ref=data_big(1:res_ref:end,:);

    for cur_rep=1:n_rep
        ews=generic_ews(data_moving_ref(:,cur_rep),'indicators',{'AR','std'},'silent',true,'ebisuzaki',100);
        pval=ews.pvalues;

        perf_ref_ar_cur=perf_ref_ar_cur+(pval(1)<0.05);
        perf_ref_var_cur=perf_ref_var_cur+(pval(2)<0.05);
    end

    perf_ref_ar(ind_cur_length_bursts)=perf_ref_ar_cur/n_rep;
    perf_ref_var(ind_cur_length_bursts)=perf_ref_var_cur/n_rep;
end 

%process data: measure AR and var for all
for ind_cur_length_bursts=1:size(length_bursts,2)
    cur_length_bursts=length_bursts(ind_cur_length_bursts);
    
    for cur_bursts=bursts

        for cur_res=1:n_res
            perf_cur_var=0;
            perf_cur_ar=0;

            for rep=1:n_rep

                if cur_bursts==2
                     l_bursts=floor(cur_length_bursts/cur_bursts); %length of one burst
                    rem=length_tot-cur_length_bursts*cur_res; %remaining amount of data points
                    spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts

                    indexes_data=round(linspace(1,l_bursts*cur_res,l_bursts));
                    indexes_data2=indexes_data+spacing+l_bursts;
                    data1=data_big(indexes_data,rep);
                    data2=data_big(indexes_data2,rep);
                    res1=generic_ews_fixed(data1);
                    res2=generic_ews_fixed(data2);

                    ci1=table2array(res1.CL);
                    ci2=table2array(res2.CL);

                    if ci2(1,1)>ci1(1,3) | ci2(1,1)<ci1(1,2)
                         perf_cur_ar=perf_cur_ar+1;
                    end


                    if ci2(2,1)>ci1(2,3) | ci2(2,1)<ci1(2,2)
                        perf_cur_var=perf_cur_var+1;
                    end

                elseif cur_bursts>2
                    l_bursts=floor(cur_length_bursts/cur_bursts); %length of one burst
                    rem=length_tot-cur_length_bursts*cur_res; %remaining amount of data points
                    spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts

                    indexes_data=round(linspace(1,l_bursts*cur_res,l_bursts));

                    data_cur=[]; index=[];
                    for i=1:cur_bursts
                        indexes_data_cur=indexes_data+(i-1)*(spacing+l_bursts);
                        data_cur=cat(1,data_cur, data_big(indexes_data_cur,rep));
                        index=[index, repelem(i,l_bursts)];
                    end

                    result=generic_ews_fixed(data_cur,'grouping',index','slopekind','ts');
                    cislope=table2array(result.CL);
                    perf_cur_ar=perf_cur_ar+(cislope(1,2)>0);
                    perf_cur_var=perf_cur_var+(cislope(2,2)>0);
                end  
            end
            %UPDATE GLOBAL PERF
            res_ARs_linearreg(cur_bursts-1,cur_res,ind_cur_length_bursts)=perf_cur_ar/n_rep;
            res_vars_linearreg(cur_bursts-1,cur_res,ind_cur_length_bursts)=perf_cur_var/n_rep;  
        end
    end
end

% res_relative_ARs_linearreg=zeros(n_bursts,n_res,size(length_bursts,2));
% res_relative_vars_linearreg=zeros(n_bursts,n_res,size(length_bursts,2));
% for ind_cur_length_bursts=1:size(length_bursts,2)
%     res_relative_ARs_linearreg(:,:,ind_cur_length_bursts)=res_ARs_linearreg(:,:,ind_cur_length_bursts)/perf_ref_ar(ind_cur_length_bursts);
%     res_relative_vars_linearreg(:,:,ind_cur_length_bursts)=res_vars_linearreg(:,:,ind_cur_length_bursts)/perf_ref_var(ind_cur_length_bursts);
% end 
% 
% res_several_500_1000_1500.res_relative_ar=res_relative_ARs_linearreg;
% res_several_500_1000_1500.res_relative_var=res_relative_vars_linearreg;
% res_several_500_1000_1500.res_absolute_var=res_vars_linearreg;
% res_several_500_1000_1500.res_absolute_ar=res_ARs_linearreg;
% save('data/result_burst_resolution_burst500_1000_1500.mat','res_several_500_1000_1500');
% 
% 
% %resolutions=[0.3 0.6 1 2 3 4 5 6];
% resolutions=round((1:n_res)/3,1);
% 
% subplot(2,3,1)
% h=heatmap(resolutions,bursts,res_ARs_linearreg(:,:,1),'Colormap', parula(20)); 
% ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation - 500 data points'})
% 
% subplot(2,3,2)
% h=heatmap(resolutions,bursts,res_ARs_linearreg(:,:,2),'Colormap', parula(20)); 
% ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation - 1000 data points'})
% 
% subplot(2,3,3)
% h=heatmap(resolutions,bursts,res_ARs_linearreg(:,:,3),'Colormap', parula(20)); 
% ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation - 1500 data points'})
% 
% subplot(2,3,4)
% h=heatmap(resolutions,bursts,res_vars_linearreg(:,:,1),'Colormap', parula(20)); 
% ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance - 500 data points'})
% 
% subplot(2,3,5)
% h=heatmap(resolutions,bursts,res_vars_linearreg(:,:,2),'Colormap', parula(20)); 
% ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance - 1000 data points'})
% 
% subplot(2,3,6)
% h=heatmap(resolutions,bursts,res_vars_linearreg(:,:,3),'Colormap', parula(20)); 
% ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance - 1500 data points'})

resolutions=round((1:n_res)/3,1);
subplot(1,2,1)
h=heatmap(resolutions,bursts,res_ARs_linearreg(:,:,1),'Colormap', parula(20),'CellLabelColor','none'); 
h.GridVisible = 'off';  h.ColorbarVisible = 'off';
ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of autocorrelation'})
ax = gca; 
ax.FontSize = 12; 
subplot(1,2,2)
h=heatmap(resolutions,bursts,res_vars_linearreg(:,:,1),'Colormap', parula(20),'CellLabelColor','none'); 
h.GridVisible = 'off'; 
annotation('textarrow',[0.99,0.99],[0.96,0.96],'string','Sensitivity', ...
      'HeadStyle','none','LineStyle','none','HorizontalAlignment','center','FontSize',10);
ylabel('Number of bursts'); xlabel('Sampling interval (days)'); title({'Performance of variance'})
ax = gca; 
ax.FontSize = 12; 