%Model: harvesting2_noise_inc.ini
%load from Models/Overharvesting_model
%The model has been implemented with grind for matlab
%https://git.wageningenur.nl/sparcs/grind-for-matlab/-/tree/current-version

nrep=100; %number of repetitions
length=8000; %length of the tim series (days)
resolution=length*3; %how many data points per day
cs=0.5; %bifurcation parameter - start value
ce=2.2; %bifurcation parameter - end value
%to generate stationary time series: set ca to 0, and cs to the desired value of c

data_big=zeros(resolution,nrep);

%generate moving time series
for cur_rep=1:nrep
    ca=1; cs=0.5; ce=2.2;
    simtime 0 length resolution
    time -r -s
    TS_cur=outfun('N'); 
    data_big(:,cur_rep)=TS_cur(2:end);
end

save("data/huge_dataset_vegetation_rep_daily.mat",'data_big');

c_values=outfun('c'); %save c values over time
save("data/time_series_c.mat",'c_values');