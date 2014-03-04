function [F] = getBaseFourier (m, n)
    %Fourier 2D vectorisée
    %Matrice motif qui se répète (dépend des lingnes m)
    i = [0:m-1];
    j = [0:n-1];
    ii = i'*i;
    jj = j'*j;
    Fm = exp(2*sqrt(-1)*pi*ii/m);
    Fn = exp(2*sqrt(-1)*pi*jj/n);
    %Remplissage de la matrice complète par concaténation des Fm modulées par
    %des facteurs suplémentaires (dépend des colonnes n) (produit de
    %kronecher)
    F = kron(Fn, Fm);
end