function [ Z, K ] = reduzir_atributos( X, K )
%Reduzir_Atributos Faz a redu��o de dimensionalidade de X, em K dimen��es
% respeitando 95% de vari�ncia

%Efetua o PCA obtendo os AutoVetores e AutoValores
[U, S] = pca(X);
tot = sum(sum(S));
cv = 1;
if K == -1
    K = size(S,1)+1;
    
    %Faz a itera��o enquanto o cv for maior q 0.95
    while cv >= 0.95
        K = K - 1;
        cv = sum(sum(S(1:K,1:K)))/tot;
    end
end

%projeta os dados em Z
Z = projetarDados(X, U, K);

end

