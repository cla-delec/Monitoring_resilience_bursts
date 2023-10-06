%% LOAD THE DATA

data_big=load("data/huge_dataset_vegetation_rep.mat");
data_big=data_big.data_big;

nrep=size(data_big,2);

%% FIND MEDIAN REPETITION

length_tot=size(data_big,1);
cur_bursts=6;
cur_res_s=[1 5 16]; 

length_bursts=200;

p_vals=zeros(nrep,3);

for ind_cur_res=1:3
    cur_res=cur_res_s(ind_cur_res);
        
    indexes_data=round(linspace(1,((length_bursts-1)*cur_res+1),length_bursts)); %index of the first burst
    
    length_one_burst_w_res=max(indexes_data);
    length_bursts_w_res=length_one_burst_w_res*cur_bursts;
    
    rem=length_tot-length_bursts_w_res; %remaining amount of data points
    spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts
    
    for cur_rep=1:nrep
        
        data_gp3=zeros(length_bursts,cur_bursts); indexes_gp3=zeros(length_bursts,cur_bursts);
        for i=1:cur_bursts
            indexes_data_cur=indexes_data+(i-1)*(spacing+length_one_burst_w_res);
            indexes_gp3(:,i)=indexes_data_cur;
            data_gp3(:,i)=data_big(indexes_data_cur); %subsample from big dataset
        end

        groups=cat(1,repelem(1,length_bursts)',repelem(2,length_bursts)',repelem(3,length_bursts)',repelem(4,length_bursts)',repelem(5,length_bursts)',repelem(6,length_bursts)');
        res_burst=generic_ews_fixed(data_gp3(:),'grouping',groups,'slopekind','ts'); %calculate indicators and slope
        res_burst=res_burst.CL.tsslope;

        slope_ar=table2array(res_burst('slope_AR','Estimated'));
        p_val_ar=table2array(res_burst('slope_AR','p_value'));

        p_vals(cur_rep,ind_cur_res)=p_val_ar;
    end
    
end

%cbind res with num rep: 1:100
res1=[(1:100).' p_vals(:,1)];
res1=sortrows(res1,2);
ind_res1=res1(51,1);

res2=[(1:100).' p_vals(:,2)];
res2=sortrows(res2,2);
ind_res2=res2(51,1);

res3=[(1:100).' p_vals(:,3)];
res3=sortrows(res3,2);
ind_res3=res3(50,1);

ind_res_all=[ind_res1 ind_res2 ind_res3];

%% PANELS D AND E - BURSTS APPROACH

length_tot=size(data_big,1);
cur_bursts=6;
cur_res_s=[1 5 16]; 

length_bursts=200;

time=linspace(1,length_tot/3,length_tot);

for ind_cur_res=1:3
    cur_res=cur_res_s(ind_cur_res);
    ind_rep=ind_res_all(ind_cur_res);
        
    indexes_data=round(linspace(1,((length_bursts-1)*cur_res+1),length_bursts)); %index of the first burst
    
    length_one_burst_w_res=max(indexes_data);
    length_bursts_w_res=length_one_burst_w_res*cur_bursts;
    
    rem=length_tot-length_bursts_w_res; %remaining amount of data points
    spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts
    
    data_gp3=zeros(length_bursts,cur_bursts); indexes_gp3=zeros(length_bursts,cur_bursts);
    for i=1:cur_bursts
        indexes_data_cur=indexes_data+(i-1)*(spacing+length_one_burst_w_res);
        indexes_gp3(:,i)=indexes_data_cur;
        data_gp3(:,i)=data_big(indexes_data_cur,ind_rep); %subsample from big dataset
    end

    groups=cat(1,repelem(1,length_bursts)',repelem(2,length_bursts)',repelem(3,length_bursts)',repelem(4,length_bursts)',repelem(5,length_bursts)',repelem(6,length_bursts)');
    res_burst=generic_ews_fixed(data_gp3(:),'grouping',groups,'slopekind','ts'); %calculate indicators and slope
    res_burst=res_burst.CL.tsslope;
    
    slope_ar=table2array(res_burst('slope_AR','Estimated'));
    p_val_ar=table2array(res_burst('slope_AR','p_value'));
    
    slope_std=table2array(res_burst('slope_std','Estimated'));
    p_val_std=table2array(res_burst('slope_std','p_value'));
    
    ar1=autocorr(data_gp3(:,1)); ar2=autocorr(data_gp3(:,2)); ar3=autocorr(data_gp3(:,3)); ar4=autocorr(data_gp3(:,4)); ar5=autocorr(data_gp3(:,5)); ar6=autocorr(data_gp3(:,6)); 
    ars=[ar1(2) ar2(2) ar3(2) ar4(2) ar5(2) ar6(2)];
    groups=[1 2 3 4 5 6];
    intercepts_ars=ars-slope_ar*groups; intercept_ar=mean(intercepts_ars);
    val_line_ar=slope_ar*groups+intercept_ar;

    std1=std(data_gp3(:,1)); std2=std(data_gp3(:,2)); std3=std(data_gp3(:,3)); std4=std(data_gp3(:,4)); std5=std(data_gp3(:,5)); std6=std(data_gp3(:,6)); 
    stds=[std1 std2 std3 std4 std5 std6];
    intercepts_stds=stds-slope_std*groups; intercept_std=mean(intercepts_stds);
    val_line_std=slope_std*groups+intercept_std;

    subplot(3,3,((ind_cur_res-1)*3+1))
    p=plot(time,data_big(:,ind_rep),'Color',[0.60, 0.60, 0.60, 1]); %plot whole dataset
    hold on
    for i=1:cur_bursts
        plot(indexes_gp3(:,i)/3,data_gp3(:,i),'Color',[0.886, 0.133, 0.254, 1]) %plot subsets of data
    end
    ax = gca; 
    ax.FontSize = 16; 
    ylabel('Vegetation cover'); xlabel('Time (days)')
    set(gca, 'box', 'off')


    subplot(3,3,((ind_cur_res-1)*3+2))
    box off
    plot(mean(indexes_gp3)/3,val_line_ar,'Color',[0.886, 0.133, 0.254],'LineWidth',2); %plot slope
    hold on
    scatter(mean(indexes_gp3)/3,ars,'marker','o','MarkerEdgeColor',[0.886, 0.133, 0.254]);
    ylim([min(ars)-0.1, max(ars)+0.1]);
    ylabel('Autocorrelation'); xlabel('Time (days)')
    set(gca, 'box', 'off')
    ax = gca; 
    ax.FontSize = 16; 
    text(1000,max(ars)+0.05,{['p-value = ' num2str(p_val_ar)]}, 'FontSize', 12);
    hold off
    
    
    subplot(3,3,((ind_cur_res-1)*3+3))
    box off
    plot(mean(indexes_gp3)/3,val_line_std,'Color',[0.886, 0.133, 0.254],'LineWidth',2); %plot slope
    hold on
    scatter(mean(indexes_gp3)/3,stds,'marker','o','MarkerEdgeColor',[0.886, 0.133, 0.254]);
    ylim([min(stds)-0.1, max(stds)+0.1]);
    ylabel('Variance'); xlabel('Time (days)')
    set(gca, 'box', 'off')
    ax = gca; 
    ax.FontSize = 16; 
    text(1000,max(stds),{['p-value = ' num2str(p_val_std)]}, 'FontSize', 12);
    hold off

end

 