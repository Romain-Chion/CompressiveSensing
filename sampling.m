function [phi, y]=sampling(alpha,x,s)

% initialisation
[m,n] = size(x);
if s==1
    k=n*m;
    l=1;
elseif s==2
    k=n;
    l=m;
elseif s==3
    k=m;
    l=n;
end
   
N=floor(alpha*k);         % nombre d'échantillons
idx=datasample(eye(k),N,'Replace',false);
if s==3
    phi=kron(eye(l),idx);
else
    phi=kron(idx,eye(l));
end
y=phi*reshape(x,m*n,1);
end