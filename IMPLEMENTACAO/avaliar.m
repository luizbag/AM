function [avaliacao] = avaliar(obtidos, esperados, tempo)

    %% avaliar Obtem a avalia��o de um m�todo atrav�s dos dados obtidos e
    %esperados
    %   [avaliacao] = avaliar(obtidos, esperados, tempo)
    %   Obtem a avalia�ao passando como parametro os dados obtidos, os
    %   esperados e o tempo gasto

    %% acuracia, fMedidaMedia, precisaoMedia, revocacaoMedia
    classePositiva = esperados == obtidos;
    verdadeirosPositivos = nnz(classePositiva);
    falsosPositivos = nnz(~classePositiva);
    
    classeNegativa = ~esperados(~obtidos);
    verdadeirosNegativos = nnz(classeNegativa);
    falsosNegativo = nnz(~classeNegativa);
   
    %% Acuracia
    acuracia = (verdadeirosPositivos + verdadeirosNegativos) / (verdadeirosPositivos + verdadeirosNegativos + falsosPositivos + falsosNegativo);
    
    %% Precis�o
    precisaoPositiva = verdadeirosPositivos / (verdadeirosPositivos + falsosPositivos);
    precisaoNegativa = verdadeirosNegativos / (verdadeirosNegativos + falsosNegativo);
    
    precisaoMedia = (precisaoPositiva + precisaoNegativa) / 2;
    
    %% Revoca��o
    revocacaoPositiva = verdadeirosPositivos / (verdadeirosPositivos + falsosNegativo);
    revocacaoNegativa = verdadeirosNegativos / (verdadeirosNegativos + falsosPositivos);
    
    revocacaoMedia = (revocacaoPositiva + revocacaoNegativa)/ 2;
    
    %% F-medida
    fMedidaPos = 2 * (precisaoPositiva * revocacaoPositiva) / (precisaoPositiva + revocacaoPositiva);
    fMedidaNeg = 2 * (precisaoNegativa * revocacaoNegativa) / (precisaoNegativa + revocacaoNegativa);
    
    fMedidaMedia = (fMedidaPos + fMedidaNeg) / 2;
    
    avaliacao = table(acuracia, fMedidaMedia, precisaoMedia, revocacaoMedia, tempo);
    %avaliacao = table(acuracia, fMedidaMedia, precisaoMedia, revocacaoMedia);
end

