%model harvesting2_noise_inc.ini
nrep=100;
length=8000;
resolution=length;
dist_min=0.5;
dist_max=2.2;

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
