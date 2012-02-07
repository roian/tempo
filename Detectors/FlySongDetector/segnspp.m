function xempty = segnspp(d, ssf, cutoff_sd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Function runs sinesongfinder (multitaper spectral analysis) on recording
%%Finds putative noise by fitting a mixture model to the distribution of
%%power values (A) and taking the lowest mean (�var) as noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Test range of gmdistribution.fit parameters
AIC=zeros(1,6);
obj=cell(1,6);
for k=1:6
    obj{k}=gmdistribution.fit(ssf.summedPower',k);
    if obj{k}.Converged == 1%keep AIC only for those that converged
        AIC(k)=obj{k}.AIC;
    end
end
[~,numComponents]=min(AIC);%best fit model
noise_index = find(obj{numComponents}.mu == min(obj{numComponents}.mu));%find the dist in the mixture model with the lowest mean
presumptive_noise_mean = obj{numComponents}.mu(noise_index);
presumptive_noise_var = obj{numComponents}.Sigma(noise_index);
presumptive_noise_SD = sqrt(presumptive_noise_var);

%Collect samples of noise (all segments with A ? mean + SD * cutoff_sd) and
%concatenate
noise_cutoff = presumptive_noise_mean + (presumptive_noise_SD * cutoff_sd);


%get indices of ssf.A ? noise_cutoff
 
A_noise_indices = find(ssf.summedPower<noise_cutoff);
%skip segment 1 and last because range overlaps extremes of sample. Could add code to handle these times.
A_noise_indices = A_noise_indices(2:end-1);
%take only first 300 samples max for noise
if length(A_noise_indices) >300
    A_noise_indices = A_noise_indices(1:300);
end
noise =zeros(300*ssf.fs,1);
for i = 1:length(A_noise_indices)
    segment = A_noise_indices(i);
    start_sample=round((segment * ssf.dS - ssf.dS/2) * ssf.fs)+1;
    stop_sample=round((segment * ssf.dS + ssf.dS/2) * ssf.fs);
    sample_noise = d(start_sample:stop_sample);
    start_in_noise = (i-1) * length(sample_noise) + 1;
    stop_in_noise = i *length(sample_noise);
    noise(start_in_noise:stop_in_noise) = sample_noise;
end
noise_end = find(noise >0,1,'last');
noise = noise(1:noise_end);
 
xempty = noise;



