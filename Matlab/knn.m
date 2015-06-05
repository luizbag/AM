function [ avaliacao ] = knn(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, k, numeroParticao)
    
    fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);
    
    tic;
    
    fprintf('Calculando distancias...\n');
    
    D = pdist2(atributosTreinamento, atributosTeste);
    
    fprintf('Distancias calculadas\n');
    
    m = size(atributosTeste, 1);
    
    fprintf('Ordenando matriz de distancias...\n');
    
    [ ~, ind ] = sort(D, 2);
    
    fprintf('Matriz ordenada\n');
    
    fprintf('Encontrando vizinhos...\n');
    
    valorPrevisto = arrayfun(@(i) mode(rotulosTreinamento(ind(i, 1:k))), 1:m)';
    
    fprintf('Vizinhos encontrados\n');
    
    fprintf('Tempo treinamento: %f\n', toc);
    
    fprintf('Acuracia na base de teste: %f\n', mean(double(valorPrevisto == rotulosTeste)) * 100);
    
    fprintf('Fim Parti��o #%d\n\n', numeroParticao);
    
    avaliacao = avaliar(valorPrevisto, rotulosTeste);
end