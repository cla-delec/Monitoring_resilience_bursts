data_big=load("data/huge_dataset_vegetation_rep.mat");
data_big=data_big.data_big;
data_big=data_big(:,61);

length_tot=size(data_big,1);
length_bursts=500;
time=linspace(1,length_tot/3,length_tot);

%group 1: continous monitoring
cur_res=48;
%start=size(data_big,1)-length_bursts*cur_res;
%index_gp1=start:cur_res:size(data_big,1);
index_gp1=1:cur_res:size(data_big,1);
data_gp1=data_big(index_gp1);

ews=generic_ews(data_gp1,'indicators',{'AR'},'silent',true,'ebisuzaki',100);
indic=ews.indicators;
ar=indic(:,1);

subplot(2,2,1)
p=plot(time,data_big,'Color',[0.60, 0.60, 0.60, 1]);
hold on
plot(index_gp1/3,data_gp1,'Color',[0.074, 0.325, 0.866, 1])
ax = gca; 
ax.FontSize = 16; 
set(gca,'ytick',[])
set(gca,'YColor','k');
set(gca, 'box', 'off')
ylabel('Vegetation cover'); xlabel('Time (days)')
hold off

subplot(2,2,2)
plot(index_gp1/3,ar,'Color',[0.074, 0.325, 0.866, 1],'LineWidth',2);
%text(1000,0.05,{'True positive rate = 0.36','False positive rate = 0.9'});
ylim([-0.15, 0.1]); 
xlim([0, 8500]); 
ylabel('Autocorrelation'); xlabel('Time (days)')
ax = gca; 
ax.FontSize = 16; 
set(gca,'ytick',[])
set(gca,'YColor','k');
set(gca, 'box', 'off')



%group 2: 2 bursts of medium resolution
% cur_bursts=2;
% cur_res=3;
% l_bursts=length_bursts/cur_bursts; %length of one burst
% rem=length_tot-length_bursts*cur_res; %remaining amount of data points
% spacing=rem/(cur_bursts-1); %space between 2 bursts
% 
% indexes_gp2_1=round(linspace(1,l_bursts*cur_res,l_bursts));
% %indexes_gp2_2=indexes_gp2_1+floor(spacing+l_bursts);
% indexes_gp2_2=length_tot-indexes_gp2_1;
% data_gp2_1=data_big(indexes_gp2_1);
% data_gp2_2=data_big(indexes_gp2_2);
% 
% res1=generic_ews_fixed(data_gp2_1);
% val1=table2array(res1.CL(2,1));
% ci_low1=table2array(res1.CL(2,2));
% ci_high1=table2array(res1.CL(2,3));
% 
% res2=generic_ews_fixed(data_gp2_2);
% val2=table2array(res2.CL(2,1));
% ci_low2=table2array(res2.CL(2,2));
% ci_high2=table2array(res2.CL(2,3));
% 
% subplot(3,2,3)
% p=plot(time,data_big,'Color',[0.60, 0.60, 0.60, 1]);
% hold on
% plot(indexes_gp2_1/3,data_gp2_1,'Color',[0.043, 0.658, 0.047, 1])
% plot(indexes_gp2_2/3,data_gp2_2,'Color',[0.043, 0.658, 0.047, 1])
% ax = gca; 
% ax.FontSize = 16; 
% set(gca,'ytick',[])
% set(gca, 'box', 'off')
% ylabel('Vegetation cover'); xlabel('Time (days)')
% hold off
% 
% 
% 
% neg_dist_error1=val1-ci_low1;
% pos_dist_error1=ci_high1-val1;
% neg_dist_error2=val2-ci_low2;
% pos_dist_error2=ci_high2-val2;
% 
% subplot(3,2,4)
% scatter([mean(indexes_gp2_1)/3, mean(indexes_gp2_2)/3],[val1,val2],'marker','o','MarkerEdgeColor',[0.043, 0.658, 0.047]);
% hold on
% errorbar(mean(indexes_gp2_1/3),val1,neg_dist_error1,pos_dist_error1,'Color',[0.043, 0.658, 0.047],'LineWidth',2);
% errorbar(mean(indexes_gp2_2/3),val2,neg_dist_error2,pos_dist_error2,'Color',[0.043, 0.658, 0.047],'LineWidth',2);
% %text(1000,0.8,{'True positive rate = 1','False positive rate = 0.78'});
% ylabel('Autocorrelation'); xlabel('Time (days)')
% %ylim([0.25, 0.9]);  
% ax = gca; 
% ax.FontSize = 16; 
% set(gca,'ytick',[])
% set(gca, 'box', 'off')
% hold off

%group 3: 3 bursts of high resolution
cur_bursts=4;
cur_res=3;
l_bursts=floor(length_bursts/cur_bursts); %length of one burst
rem=length_tot-length_bursts*cur_res; %remaining amount of data points
spacing=floor(rem/(cur_bursts-1)); %space between 2 bursts
indexes_data=round(linspace(1,l_bursts*cur_res,l_bursts));
data_gp3=zeros(l_bursts,cur_bursts); indexes_gp3=zeros(l_bursts,cur_bursts);
for i=1:cur_bursts
    indexes_data_cur=indexes_data+(i-1)*(spacing+l_bursts);
    indexes_gp3(:,i)=indexes_data_cur;
    data_gp3(:,i)=data_big(indexes_data_cur);
end

groups=cat(1,repelem(1,l_bursts)',repelem(2,l_bursts)',repelem(3,l_bursts)',repelem(4,l_bursts)');
res_burst=generic_ews_fixed(data_gp3(:),'grouping',groups,'slopekind','ts');
slope=table2array(res_burst.CL(1,1));
slope_low=table2array(res_burst.CL(1,2)); slope_high=table2array(res_burst.CL(1,3));

%ars=[0.58541,0.63029,0.83884];
%groups=[1 2 3];
ars=[0.42949,0.53268,0.59,0.7895];
groups=[1 2 3 4];
intercepts=ars-slope*groups; intercept=mean(intercepts);

val_line=slope*groups+intercept;
val_line_low=slope_low*groups+intercept;
val_line_high=slope_high*groups+intercept;

subplot(2,2,3)
p=plot(time,data_big,'Color',[0.60, 0.60, 0.60, 1]);
hold on
for i=1:cur_bursts
    plot(indexes_gp3(:,i)/3,data_gp3(:,i),'Color',[0.886, 0.133, 0.254, 1])
end
ax = gca; 
ax.FontSize = 16; 
ylabel('Vegetation cover'); xlabel('Time (days)')
set(gca,'ytick',[])
set(gca, 'box', 'off')


subplot(2,2,4)
box off
plot(mean(indexes_gp3)/3,val_line,'Color',[0.886, 0.133, 0.254],'LineWidth',2);
hold on
patch([mean(indexes_gp3)/3 fliplr(mean(indexes_gp3)/3)], [val_line fliplr(val_line)+val_line_high], [0.886, 0.133, 0.254], 'EdgeColor','none');
patch([mean(indexes_gp3)/3 fliplr(mean(indexes_gp3)/3)], [val_line fliplr(val_line)-val_line_low], [0.886, 0.133, 0.254], 'EdgeColor','none');
alpha(0.3)
scatter(mean(indexes_gp3)/3,ars,'marker','o','MarkerEdgeColor',[0.886, 0.133, 0.254]);
%text(1000,0.1,{'True positive rate = 0.96','False positive rate = 0.91'});
ylim([0, 1.7]); %ylim([0, 7]); 
ylabel('Autocorrelation'); xlabel('Time (days)')
set(gca,'ytick',[])
set(gca, 'box', 'off')
ax = gca; 
ax.FontSize = 16; 
hold off

% low_alpha=prctile(ews.ebitaus,5); high_alpha=prctile(ews.ebitaus,95);
% box off
% hist(ews.ebitaus); 
% % ylabel('Count'); xlabel('Kendall taus'); title({'Repartition of Kendall taus' ,'generated with the Ebisuzaki method'})
% h = findobj(gca,'Type','patch');
% h.FaceColor=[0.074, 0.325, 0.866];
% xline(low_alpha,'red','LineWidth',2); xline(high_alpha, 'red','LineWidth',2);
% set(gca,'ytick',[])
% set(gca,'xtick',[])
% set(gca, 'box', 'off')
% ax = gca; 
% ax.FontSize = 20; 
 