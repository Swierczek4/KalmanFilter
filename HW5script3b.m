
colors
eps = 0.1;
Ne = 100000;
nexp = 100;
n = 1000:-10:10;
sz = size(n,2);
sigsq = 1+eps;
sig = sqrt(sigsq);
rho = zeros(sz,1);
rhoTemp = zeros(nexp,1);
output = zeros(sz,2);
count = 0;

for ii=1:sz   
    tic()
    for jj=1:nexp
        x = normrnd(0,sig,Ne,n(ii));
        W = zeros(Ne,1);
        Wsq = zeros(Ne,1);
        for kk=1:Ne
            W(kk) = divgauss(0,1,0,sigsq,x(kk));
            Wsq(kk) = W(kk)^2;
        end
        X = sum(Wsq)/Ne;
        Y = (sum(W)/Ne)^2;
        rhoTemp(jj) = X/Y;
    end
    rho(ii) = mean(rhoTemp);
    output(ii,:) = [n(ii),rho(ii)];
    count = count + 1
    toc()
end

plot(n,rho,'Color',Color(:,19),'Linewidth',2)
title('n vs. rho')
xlabel('n')
ylabel('rho')
print('n_vs_rho','-djpeg')

save output
