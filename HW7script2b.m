tic()

%% preliminaries
Ne = 100000;            % number of samples
W = zeros(Ne,1);        % initialize empty weight vector
pn = 2;                 % type of norm
funF = @(x)((norm(x-5,2)^4)/100 + 0.2*sin(5*norm(x,2)));                        % F(x)
funp = @(x,y)exp(-(((x-5).^2+(y-5).^2).^2)./100 + 0.2*sin(5*sqrt(x.^2+y.^2)));  % p(x)
funP = @(x)exp(-funF(x));                                                       % also p(x)    
%%

%% optimization
mu = lsqnonlin(funF,[5,5]);     % minimization
mu = mu'
phi = funF(mu);
H = 2*eye(2);                % guess for correlation matrix of multivariate t proposal
nu = 3;
%%

%% for histograms
colors                  % my own color palette for plotting
n = [50,50];            % number of bins
nbins = 300;            % vertical scale
lb = 0;                 % x axis lower bound
ub = 10;                % x axis upper bound
%%

%% for plotting p(x)
Z = linspace(lb,ub,200);
P = zeros(200,200);
for jj=1:200
    for kk=1:200
        P(jj,kk)=funp(Z(jj),Z(kk));         % plotting p(x) on a grid
    end
end
C = integral2(funp,-Inf,Inf,-Inf,Inf);      % scaling constant
Ps = P./C;
%%

%% calculating weights and effective sample size
X = mvtrnd(H,nu,Ne)' + mu;          % Ne draws from our proposal distribution
for ii=1:Ne
    W(ii) = funP(X(:,ii))/mvtpdf(X(:,ii),H,nu);         % calculate weights
end
rhonum = sum(W.^2)/Ne;              % numerator for rho calculation
rhoden = (sum(W)/Ne)^2;             % denominator for rho calculation
rho = rhonum/rhoden                 % rho
Neff = floor(Ne/rho)                % effective sample size
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
    x(:,jj) = X(:,kk);    
end
%%

%% plots
figure()
surf(Z,Z,Ps)
colormap autumn
axis([lb ub lb ub 0 0.06])
title('target distribution')
xlabel('x')
ylabel('y')
zlabel('p(x,y)')

figure()
hist3(X',n)
axis([lb ub lb ub 0 2*nbins])
title('proposal distribution')
xlabel('x')
ylabel('y')
zlabel('count')

figure()
hist3(x',n)
axis([lb ub lb ub 0 nbins])
title('resampled ensemble')
xlabel('x')
ylabel('y')
zlabel('count')

figure()
contourf(P,1)

figure()
TrianglePlot(X,1)

figure()
TrianglePlot(x,1)
%%

toc()

