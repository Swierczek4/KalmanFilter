function [x_start,x_star,TimeSeries] = fdvar(x_0,dt,jump,L1,L2,H,bcov,bmean,y_t,n,R,F)
fun = @(x)argh(x,H,bcov,bmean,y_t,n,R,L1,L2,F,dt,jump);
% options = optimoptions(@lsqnonlin,'Display','iter-detailed',...
%     'SpecifyObjectiveGradient',true);
options = optimoptions(@lsqnonlin,...
    'SpecifyObjectiveGradient',true);
[x_star,~,~,~,~,~,J] = lsqnonlin(fun,x_0,[],[],options);
[x_start,TimeSeries] = MRK3(x_star,L1,L2,F,n,dt,jump);
end

