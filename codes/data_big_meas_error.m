data_big_inc=load("data/huge_dataset_vegetation_rep.mat");
data_big_inc=data_big_inc.data_big;

data_big_stat=load("data/huge_stationnary_dataset_vegetation_rep.mat");
data_big_stat=data_big_stat.data_big;

measurement_error=0.2;

data_big_measurement_error=data_big_inc+measurement_error*normrnd(0,1,size(data_big_inc));
data_big_measurement_error_stationary=data_big_stat+measurement_error*normrnd(0,1,size(data_big_stat));

save('data/huge_dataset_vegetation_measurement_error_rep.mat','data_big_measurement_error');
save('data/huge_dataset_vegetation_stationary_measurement_error_rep.mat','data_big_measurement_error_stationary');