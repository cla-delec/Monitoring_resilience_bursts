%This program is used to calculate the Delta_c values, used as x axis in
%fig 4A and fig4B
%it converts values of Delta_2 (interval between two bursts) into Delta_c
%(diff in resilience between two bursts

%%%%%%%%%%%%% LOAD TIME SERIES OF C OVER TIME

c_values=load("data/time_series_c.mat");
c_values=c_values.TS_c;

%%%%%%%%%%%%% SIMULATION PARAMETERS

length_tot=size(c_values,1);

n_bursts=2;
length_bursts=1000; %total length of the data
l_bursts=floor(length_bursts/n_bursts); %length of one burst

%These are the simulation parameters used to obtain the results stored in
%data/sensitivity_delta2.mat, using the algorithm
%codes/sensitivity_delta2.m

low_delta1=3; 
high_delta1=9;

n_delta2=20;
delta2_min=100; 
delta2_max=(round(length_tot-length_bursts*high_delta1)); %the maximum value of delta_2 given the other simulation parameters and total length of data available
deltas2=round(linspace(delta2_min,delta2_max,n_delta2));

% deltas2=[1000, 12000];
% n_delta2=2;

delta_c=zeros(n_delta2,1);

for ind_cur_delta2=1:n_delta2
    cur_delta2=deltas2(ind_cur_delta2);
    delta_c_cur=zeros(n_bursts,1); 
    
    %For each combination of values of Delta2 and Delta1, we calculate the
    %indexes of data.
    indexes_data=round(linspace(length_tot-l_bursts*low_delta1,length_tot,l_bursts)); %indexes data last burst 
    
    data_cur_low_delta1=[]; groups=[];
    for i=1:n_bursts
        indexes_data_cur=indexes_data-(i-1)*(cur_delta2+l_bursts);
        
        %we get the values of bifurcation parameter c for the corresponding
        %data points for that burst, and take the average value over the
        %burst
        delta_c_cur(i)=mean(c_values(indexes_data_cur)); 
        
    end 
    %calculate the delta c (between first and second burst)
    delta_c(ind_cur_delta2)=abs(delta_c_cur(1)-delta_c_cur(2));

end

save("data/delta_c_values.mat","delta_c");
