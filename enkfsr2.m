function [ARMSE,aspread] = enkfsr2(dt,ensemble,M,N,H,t_final,R,Y,T,jump,W)
tic();

f = @(x)(M*x.*(N*x)+(8-x));
[n,ne]=size(ensemble);
numiter = ceil(t_final/dt);
[m,q]=size(T);
[m,a]=size(Y);
X = ensemble;
RMSE = [];
spread = [];
Rm = R*eye(m);
time = [1:1:a-1];
counter = 0;

for i=1:(q-1)
    k1=f(X);                                          % RK4
    k2=f(X+0.5*dt.*k1);
    k3=f(X+0.5*dt.*k2);
    k4=f(X+dt.*k3);
    X = X + (1/6)*dt.*(k1+2.*k2+2.*k3+k4);            % forecast ensemble
    
    if(mod(i,jump)==0)
        counter = counter + 1;
        mu_f = (1/ne).*transpose(sum(transpose(X)));      % forecast mean
        X_f = (X - mu_f).*(1/sqrt(ne-1));                 % forecast perturbations
        P_f = X_f*transpose(X_f);                         % forecast covariance
        K = P_f*(H')/(H*P_f*(H') + Rm);                   % Kalman Gain
        mu_a = mu_f + K*(Y(:,counter+1)-H*mu_f);          % analysis mean
        P_a = (eye(n)-K*H)*P_f;                           % analysis covariance
        V = (X_f')*(H');
        A = (V/Rm)*(V');
        A = 0.5.*(A+A');
        [U,lambda] = eig(A);
        Q = sqrt(eye(ne)+lambda);
        Z = U/Q;
        X_a = X_f*Z*W;                                    % analysis perturbations
        X = mu_a + sqrt(ne-1).*X_a;                       % analysis ensemble
        error = mu_a-T(:,jump*counter+1);
        RMSE = [RMSE,sqrt((1/n).*transpose(error)*error)];
        spread = [spread,sqrt(trace(P_a)/n)];
    end

end

[m,q] = size(RMSE);
z = floor(q/2);
ARMSE = (1/(q-1-z))*sum(transpose(RMSE(z:q-1)));
aspread = (1/(q-1-z))*sum(transpose(spread(z:q-1)));

figure
plot(time,RMSE,'*','MarkerSize',5,'Color','red')
hold on
plot(time,spread,'o','MarkerSize',5,'Color','blue')
title('EnKF Square Root Errors')
xlabel('time')
legend('root mean square error','spread')
print('ErrorsSR','-djpeg')

toc()
end

