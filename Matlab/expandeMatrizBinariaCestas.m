function [ matrizBinaria ] = expandeMatrizBinariaCestas( dados, numeroCestas)

    %% expandeMatrizBinariaCestas Divide um determinado crit�rio continuo em Cestas
    
    [~,~,cesta] = histcounts(dados,numeroCestas);
    
    numeroAmostras = size(dados, 1);
   
    matrizBinaria(numeroAmostras, numeroCestas) = 0;
    
    matrizBinaria(sub2ind(size(matrizBinaria), 1:numeroAmostras, cesta')) = 1;
end

