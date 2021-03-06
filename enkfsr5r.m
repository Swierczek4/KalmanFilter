function enkfsr5r(dt,ensemble,M,N,H,t_final,R,Y,jump,r,alpha,spy)
tic();

f = @(x)(M*x.*(N*x)+(8-x));
[n,ne]=size(ensemble);
[m,a]=size(Y);
X = ensemble;
RMSE = [];
spread = [];
Rm = R*eye(m);
time = [1:1:a];
counter = 0;
spyvec = zeros(1,a);
indices = [];
L = localize2(n,r);

for i=1:((t_final*jump-1)*jump)
    k1=f(X);                                          % RK4
    k2=f(X+0.5*dt.*k1);
    k3=f(X+0.5*dt.*k2);
    k4=f(X+dt.*k3);
    X = X + (1/6)*dt.*(k1+2.*k2+2.*k3+k4);            % forecast ensemble
    
    if(mod(i,jump)==0)
        counter = counter + 1;
        mu_f = (1/ne).*transpose(sum(transpose(X)));    % forecast mean
        x_f = mu_f + sqrt(1+alpha).*(X-mu_f);           % ensemble inflation
        X_f = (x_f - mu_f).*(1/sqrt(ne-1));             % forecast perturbations
        P_f = X_f*transpose(X_f);                       % forecast covariance
        P_f = L.*P_f;                                   % localization
        K = P_f*(H')/(H*P_f*(H') + Rm);                 % Kalman Gain
        mu_a = mu_f + K*(Y(:,counter+1)-H*mu_f);        % analysis mean
        P_a = (eye(n)-K*H)*P_f;                         % analysis covariance
        V = (X_f')*(H');
        A = (V/Rm)*(V');
        A = 0.5.*(A+A');
        [U,lambda] = eig(A);
        Q = sqrt(eye(ne)+lambda);
        Z = U/Q;
        X_a = X_f*Z;                                    % analysis perturbations
        X = mu_a + sqrt(ne-1).*X_a;                     % analysis ensemble
        spyvec(counter) = mu_a(spy);
        indices = [indices,i];
    end

end


figure
plot(time(625:end),spyvec(625:end),'LineWidth',4,'Color','red')
hold on
plot(time(625:end),Y(spy,625:end),'LineWidth',4,'Color','blue')
title(['Observed Data vs. SR Kalman Estimate in coordinate ', num2str(spy)])
xlabel('time')
legend('Kalman','Observed')
print(['KalmanvsObs_SR_r=',num2str(r),'_alpha=',num2str(alpha),'_Ne=',num2str(ne)],'-djpeg')

toc();

toc()
end

