function [ atributosNormalizados ] = normalizarPadronizacao( atributos )

%% Normaliza��o por Padroniza��o 
%   [ atributosNormalizados ] = normalizarPadronizacao( atributos )

%Calcula a media
mu = mean(atributos);

%Calcula o desvio padrao
sigma = std(atributos);

%Calcula X_norm = (x_i - mu) (Numerador)
atributosNormalizados = bsxfun(@minus, atributos, mu);

%Calcula X_norm = X_norm / sigma (Denominador)
atributosNormalizados = bsxfun(@rdivide, atributosNormalizados, sigma);

end

