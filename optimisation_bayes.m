function x_map=optimisation_bayes(y,phi,psi,m,n)

N=m*n;
% PRIORS
% loi de Laplace normalisée
ur = rand(N,1)-0.5; % pour une loi symétrique
ui = rand(N,1)-0.5; % pour une loi symétrique
x1_r= -2 * sign(ur).* log(1- 2* abs(ur));
x1_i= -2 * sign(ui).* log(1- 2* abs(ui));
sigma2_1=rand(1,1); 
w_1=rand(1,1);
alpha0=1;
alpha1=1;
loi_gamma=gamrnd(alpha0,1/alpha1);
sigmax2_1=1/loi_gamma;

N_MC=1000;
burn_in=200;
% échantillonnage de Gibbs 
[x,sigma2,w,sigmax2]=gibbs(m,n,y,phi*psi,x1_r,x1_i,sigma2_1,w_1,sigmax2_1,N_MC,burn_in);

% Maximum a posteriori de x
x_map=zeros(N,1);
for i=1:N
    x_map(i)=max(x(i,:));
end

if (1) %enable/disable histogram figure
    scrsz=get(0,'ScreenSize');
    figure('Name','Bayesian Histogram','NumberTitle','off',...
              'MenuBar','none','Resize','off',...
              'Position',[(scrsz(3)-800)/2 (scrsz(4)-600)/2 800 600]);
    subplot('Position',[0.15 0.05 0.7 0.40]);
    x_map_vs=[real(x_map) imag(x_map)];
    hist3(x_map_vs,[50 50])
    title('x MAP')
    subplot('Position',[0.15 0.55 0.7 0.40]);
    x_prior=[x1_r x1_i];
    hist3(x_prior,[50 50])
    title('x a priori')
end
