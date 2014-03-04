function [v,A]=optimisation_cvx(y,phi,psi,N,lambda)
% NOTATIONS DE L'ARTICLE "Compressive sensing in medical ultrasoud"
% x has a sparse representation in some orthnormal basis psi
% x=psi*v 
% v is s-sparse
% N number of samples of original signal
% y measurements
% y=phi*x
% x is the signal of interest, that is to say v here.
 
%% Problème d'optimisation
% cas sans bruit
A = phi*psi;
% lambda=0.5;

delete 'log.txt';
diary 'log.txt';
% package cvx
cvx_begin
    variable v(N) complex
    minimize( (1-lambda)*norm( A*v - y , 2) + lambda*norm( v , 1 ) )
cvx_end
diary off

file = fopen('log.txt');
str = textscan(file, '%s', 'Delimiter','|','HeaderLines',13);
k=0
while str2num(str{1}{9*k+1})==k
    Nv(k+1)=str2num(str{1}{9*k+6})
    k=k+1
end
fclose(file);
subplot('Position',[0.505 0.505 0.485 0.44]);
semilogy((0:k-1),Nv);title('Residual Error');
end
