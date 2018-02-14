tic()

%% preliminaries
Ne = 100000;            % number of samples
y = 2.5;                % observation from actual people
W = zeros(Ne,1);        % initialize empty weight vector
funF = @(x)(0.5*((x-1)^2 + ((y-x^3)/0.1)^2));           % F(x)
funp = @(x)exp(-0.5.*((x-1).^2 + ((y-x.^3)./0.1).^2));  % p(x)
nu = 1:99;              % degrees of freedom for t distribution
nexp = size(nu,2);
rhoTemp = zeros(nexp,1);
%%

%% optimization
mu = fminsearch(funF,1.3);         % minimization
dx = 0.001;                        % evaluate Hessian using finite difference grid
sigsq = (funF(mu-3*dx)/90-3*funF(mu-2*dx)/20+1.5*funF(mu-dx)-49*funF(mu)/18 ...
    +1.5*funF(mu+dx)-3*funF(mu+2*dx)/20+funF(mu+3*dx)/90)/(dx^2);
stdv = sqrt(1/sigsq);
%%

%% for histograms
colors                  % my own color palette for plotting
n = 80;                 % number of bins
nbins = ceil(Ne/20);    % vertical scale
lb = 1.2;               % x axis lower bound
ub = 1.5;               % x axis upper bound
%%

%% for plotting p(x)
Z = unifrnd(lb,ub,Ne,1);         % uniform random variables for plotting target p(x)
Z = sort(Z);
P = funp(Z);
C = quadgk(funp,-Inf,Inf);       % scaling constant
P = P./C;
%%

%% calculating weights and effective sample size
for ll=1:nexp
    X = stdv.*trnd(nu(ll),Ne,1) + mu;   % Ne draws from our proposal distribution
    
    W = funp(X)./tpdf(X,nu(ll));        % weights
    
    rhonum = sum(W.^2)/Ne;              % numerator for rho calculation
    rhoden = (sum(W)/Ne)^2;             % denominator for rho calculation
    rhoTemp(ll) = rhonum/rhoden
end

rho = mean(rhoTemp);                
Neff = floor(Ne/rhoTemp(nexp))          % effective sample size
%%

%% resampling
x = X;                              % little x will be resampled ensemble
What = W./(sum(W));                 % W hat are the self normalized weights
Whatsum = zeros(Ne,1);                  

for ii=1:Ne
    Whatsum(ii) = sum(What(1:ii));  % Whatsum is a cumulative sum of W hat
end

U = unifrnd(0,1,Ne,1);
U = sort(U);

for jj=1:Ne                         % performs resampling algorithm
    kk=find(Whatsum>=U(jj),1);           
    x(jj) = X(kk);    
end
%%

%% plots
figure()
plot(Z,P,'Color',Color(:,19),'Linewidth',2)
axis([lb ub 0 25])
title('target distribution')
xlabel('x')
ylabel('p(x)')

figure()
hist(X,n)
h = findobj(gca,'Type','patch');
h.FaceColor = Color(:,7);
axis([lb ub 0 nbins])
title('proposal distribution')
xlabel('x')
ylabel('count')

figure()
hist(x,n)
h = findobj(gca,'Type','patch');
h.FaceColor = Color(:,9);
axis([lb ub 0 nbins])
title('resampled ensemble')
xlabel('x')
ylabel('count')
%%

toc()