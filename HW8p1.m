tic()
clc
close all
clear

%% preliminaries
colors
sigma = 10;
beta = 8/3;
rho = 28;
dt = 0.01;
Q = 1;
R = 1;
nsteps = 20000;
Traj = zeros(3,nsteps);
PF = zeros(3,nsteps);
Ne = 40;
w = zeros(1,Ne);
M1 = [0,0,0;-1,0,0;1,0,0];
M2 = [0,0,0;0,0,1;0,1,0];
M3 = [-sigma,sigma,0;rho,-1,0;0,0,-beta];
color1 = 11;
color2 = 9;
color3 = 22;
color4 = 8;
color5 = 9;
coords1 = [-10 60 -25 25 -30 30];
coords2 = [-25 25 -10 60];
name = 'SPF1';
ll = 25;
%%

%% true state

for ii=2:nsteps
    Traj(:,ii) = lorenz63s4(Traj(:,ii-1),dt,M1,M2,M3)+sqrt(dt).*randn(3,1);
end
%%

%% observations
H = [1,0,0;0,0,1];
Obs = H*Traj +R.*randn(2,nsteps);
%%

%% ensemble + simulation
Ens = randn(3,Ne);

for jj=2:nsteps
    Ens = lorenz63s4(Ens,dt,M1,M2,M3) + sqrt(dt).*randn(3,Ne);
    for kk=1:Ne
        w(kk) = 0.5.*(Obs(:,jj)-H*Ens(:,kk))'*(eye(2)./R)*(Obs(:,jj)-H*Ens(:,kk));
    end
    W = normalizeweights(w);
    Ens = resamplingmmo(W,Ens,Ne,3);
    PF(:,jj) = mean(Ens,2);
end
%%

%% Error and plot

Error = Traj - PF;
Error = sqrt(sum(Error.^2))./sqrt(3);
st = floor(0.25*nsteps);
average_RMSE = mean(Error(st:end))

lorenz63plots2(Traj,PF,color1,color2,color3,color4,color5,coords1,coords2,name,ll,nsteps)
%%

toc()