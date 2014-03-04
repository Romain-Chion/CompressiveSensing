function [F] = getBaseFourier (m, n)
    %Fourier 2D vectoris�e
    %Matrice motif qui se r�p�te (d�pend des lingnes m)
    i = [0:m-1];
    j = [0:n-1];
    ii = i'*i;
    jj = j'*j;
    Fm = exp(2*sqrt(-1)*pi*ii/m);
    Fn = exp(2*sqrt(-1)*pi*jj/n);
    %Remplissage de la matrice compl�te par concat�nation des Fm modul�es par
    %des facteurs supl�mentaires (d�pend des colonnes n) (produit de
    %kronecher)
    F = kron(Fn, Fm);
end