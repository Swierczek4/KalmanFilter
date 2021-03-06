tic()
clc
close all
clear

%% preliminaries
colors
dt = 0.01;
jump = 1;
R = 1;
spinsteps = 100000;
nsteps = 20000;
n = 40;
nobs = floor(n/2);
Traj = zeros(n,nsteps);
Ne = 20;
color1 = 11;
color2 = 9;
color3 = 22;
[M,N,H] = makeL96matrices(n);
F = 8;
alpha = 0.1;
r = 5;
L = localize2(n,r);
Rm = R*eye(nobs);
EnKFest = zeros(n,nsteps);
spreadv = zeros(1,nsteps);
%%

%% initial spin up
Wallaby = randn(n,1);

for ii=2:spinsteps
    Wallaby = lorenz96s4(Wallaby,dt,M,N,F);
end
%%

%% true state
Traj(:,1) = Wallaby;
for ii=2:nsteps
    Traj(:,ii) = lorenz96s4(Traj(:,ii-1),dt,M,N,F);
end
%%

%% observations
Obs = H*Traj +sqrt(R).*randn(nobs,nsteps);
%%

%% ensemble + simulation
Ens = ensemble_init(dt,Ne,M,N,F,Wallaby);
EnKFest(:,1) = mean(Ens,2);

for jj=2:nsteps
    [Ens,mu_a,spread] = ENKFSR(Ens,dt,jump,n,Ne,H,M,N,F,alpha,Obs(:,jj),L,Rm,nobs);
    EnKFest(:,jj) = mu_a;
    spreadv(jj) = spread;
end
%%

%% RMSE
Error = Traj - EnKFest;
Error = sqrt(sum(Error.^2))./sqrt(n);
st = floor(0.25*nsteps);
fprintf('RMSE %g\n',mean(Error(st:end)))
fprintf('Spread %g\n',mean(spreadv(st:end)))
%%

%% plots
sk = 20;
h1 = plot(sk:nsteps,spreadv(sk:end),'Color',Color(:,color1),'Linewidth',1.5);
hold on
h2 = plot(sk:nsteps,Error(sk:end),'Color',Color(:,color3),'Linewidth',1.5);
title('EnKF RMSE and spread')
xlabel('time steps')
ylabel('error')
legend([h1(1),h2(1)],'spread','RMSE')
print('EnKF RMSE','-djpeg')
hold off
%%

toc()