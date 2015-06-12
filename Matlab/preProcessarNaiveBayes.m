function [ dadosNaiveBayes ] = preProcessarNaiveBayes(dadosPreprocessados, indiceNumericos )

%% Pr�-Processamento do Naive Bayes
%  [ dadosNaiveBayes ] = preProcessarNaiveBayes(dadosPreprocessados, indiceNumericos )

    numeroCestas = 10;
    dadosNumericos = dadosPreprocessados(:, indiceNumericos);
    [dadosNumericos] = normalizarEscala(dadosNumericos);
    
    dadosNaoNumericos = dadosPreprocessados;
  
    dadosNaiveBayes = [];
    
    for i = 1:size(dadosNumericos, 2)
        dadosNaiveBayes = horzcat(dadosNaiveBayes, expandeMatrizBinariaCestas(dadosNumericos(:, i), numeroCestas));
    end

    dadosNaiveBayes = horzcat(dadosNaoNumericos, dadosNaiveBayes);   
end

