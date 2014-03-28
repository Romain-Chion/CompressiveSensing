function [xv,sigma2v,wv,sigmax2v] = gibbs(n,m,y,A,xr,xi,sigma2,w,sigmax2,N_MC,burn_in)

N=n*m;
nbre_sv=N_MC-burn_in;
% preallocating for the sake of speed execution
xv=zeros(N,nbre_sv);
wv=zeros(nbre_sv,1);
xnew=zeros(N,1);
sigmax2v=zeros(nbre_sv,1);
sigma2v=zeros(nbre_sv,1);
%%
l2ti = zeros(N,1); %vecteur qui contient la norme 2 de la colonne i de A
for i=1:N
    l2ti(i) = norm(A(:,i),2)^2;
end     
x=xr+sqrt(-1)*xi;

for j=1:N_MC 
       %% sampling according to f(x|sigma2,omega,sigmax2,y)
       sumtixi = A*x;
       for i = 1:N % update the ith coordinate of the vector
                etai2 = 1./(1/sigmax2+l2ti(i)/sigma2);
                ei = y-(sumtixi-x(i)*A(:,i));
                nui = transpose(A(:,i))*conj(ei)*etai2/sigma2;
                witild = w*etai2/sigmax2*exp(abs(nui^2)/etai2);
                wi = witild/(witild+(1-w));
                a=rand(1,1);            
                if a > wi 
                    xnew(i)=0;
                else                    
                    xr=real(nui)+sqrt(etai2/2)*randn(1,1);
                    xi=imag(nui)+sqrt(etai2/2)*randn(1,1);
                    xnew(i)=xr+sqrt(-1)*xi;
                end                  
       end
       
       %% sampling according to f(sigma2|x,omega,sigmax2,y)
                loi_gamma=gamrnd(m,1/(norm(y-A*x,2)^2));
                sigma2new=1/loi_gamma;
    
       %% sampling according to f(omega|x,sigma2,sigmax2,y)                
                n1=nnz(x);% nombre de non zéros dans une matrice, cad la norme 0
                wnew=betarnd(n1+1,N-n1+1);
                
       %% sampling according to f(sigmax2|x,sigma2,omega,y)
                alpha0=1;
                alpha1=1;
                loi_gamma=gamrnd(n1+alpha0,1/(norm(x,2)^2+alpha1));
                sigmax2new=1/loi_gamma;
         
                % actualisation des paramètres
                x=xnew;
                w=wnew;
                sigmax2=sigmax2new;
                sigma2=sigma2new;
                     
                % stockage des paramètres
                if j>burn_in         
                    xv(:,j-burn_in)=xnew;% on rajoute une colonne plus loin correspondant à une réalisation pour tous les pixels, donc une ligne correspond à N_MC réalisations pour un pixel donné
                    wv(j-burn_in)=wnew;
                    sigmax2v(j-burn_in)=sigmax2new;
                    sigma2v(j-burn_in)=sigma2new;
                end
end