function [a,A] = optimisation_cosamp(u,phi,psi,N,sp)
% NOTATIONS ADAPTEES DE L'ARTICLE "CoSaMP : Iterative signal recovery from incomplete and inaccurate samples"
% x has a sparse representation in some orthnormal basis psi
% x=psi*a
% a is s-sparse
% N number of samples of original signal
% u measurements
% y=phi*x
% x is the signal of interest, that is to say a here.
% A is the sampling matrix
% A=phi*psi
% e is the final residual error
% T is the support of the coefficients of interest
% v is the residual product of the algorithm

%% Algorithme d'optimisation
% Définition des constantes
s = floor(sp/100*N); % Nombre de coefficients parcimonieux ( <N/2)
e = 0.001; % Critère d'arret sur la variation de l'erreur
K = 30; % Nombre limite d'itérations

A = phi*psi; % Matrice d'échantillonnage

% Algorithme
a = 0; % Signal reconstruit initial
v = u; % Residu initial
T = []; % Support du signal initial
Nu = norm(u,2); % Norme de u (énergie des échantillons)
Nv(1) = norm(v,2)/Nu; % Norme de v initiale, par rapport aux échantillons
DNv = 2;

k = 1;
while k <= K && DNv > e
    k = k+1;
    y = A'*v; % On forme l'approximation énergétique du residu
    
    % Calcul du support des 2s plus grands coefficients de y et a
    [ys, iy] = sort(y, 'descend'); % ON FAIT UN ORDRE EN COMPLEXE, D'ABORD SUR ABS() PUIS ANGLE()
    O = iy((1:2*s)); % Support 2s plus grands coefs de y
    nza = nnz(a); % Nombre de non zero de a
    [as, ia] = sort(a, 'descend');
    T = ia([1:nza]); % Support de a
    T = union(O, T); % Union des deux supports
    
    % Moindre carré sur T
    AT = A(:,T); % Extraction des colonnes de A sur T
    piAT = pinv(AT); % Pseudoinverse de A
    Tc = setxor(T, (1:N)); % Complémentaire de T sur les échantillons
    b(T) = piAT*u; % Approximation moindres carrés
    b(Tc) = 0; % Signal parcimonieux nul sur Tc
    
    % Réduction à un signal de parcimonie s
    [bs, ib] = sort(b, 'descend');
    B = ib([1:s]); % Support des s plus grands coefficients de b
    a = zeros(N,1); % On efface les restes de la précédente itération
    a(B) = b(B); % On récupère bs dans l'ordre original des coefficients
    
    % Calcul du résidu
    v = u - A*a;
    
    % Norme de v
    Nv(k) = norm(v,2)/Nu;
    DNv = abs(Nv(k)-Nv(k-1));
    
    disp(['Iteration #',sprintf('%d', k-1)]);
end
plot((0:k-1),Nv);xlabel('Iteration');ylabel('Residual Error');
end
