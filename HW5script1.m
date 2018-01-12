tic()

format long g
Ne = 2000000:1:2000005;
n = 1000;
Nesz = size(Ne,2);

funp = @(x)(exp(-(x^2)/8)/sqrt(8*pi));
funf = @(x)(1*(x>=4));
funq = @(x)(exp(-(x^2)/2)/sqrt(2*pi));

% Efx = integral(funp,4,Inf);
Efx = 0.0227501319481792;
e = zeros(Nesz,1);
Output = [];

for ii=1:Nesz
    X = zeros(Ne(ii),1);
    evec = zeros(n,1);
    for jj=1:n
        x = normrnd(0,1,Ne(ii),1);
        for kk=1:Ne(ii)
            X(kk) = funf(x(kk))*funp(x(kk))/funq(x(kk));
        end
        Ehat = sum(X)/Ne(ii);
        evec(jj) = abs(Efx-Ehat)/abs(Efx);
    end
    e(ii) = sum(evec)/n;
    Output = [Output;Ne(ii),e(ii)*100];
    save Output
end

toc()


