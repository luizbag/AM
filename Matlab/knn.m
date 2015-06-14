function [ avaliacao, valorPrevisto ] = knn(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, k, numeroParticao)
    
    %% Efetua o calculo da distancia de todos os dados para todos os dados
    %
    %   [ avaliacao ] = knn(atributosTreinamento, rotulosTreinamento, 
    %   atributosTeste, rotulosTeste, k, numeroParticao)
    %   Obtem a avalia��o passando como parametro os atributos/Rotulos de
    %   Treinamento, e Atributos/Rotulos de Teste, alem da quantidade de
    %   visinhos que deseja calcular e qual parti��o esta dentro da
    %   valida��o cruzada

    fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);
    
    tic;
    
    %Realizando o calculo das distancias
    fprintf('Calculando distancias...\n');
    
    D = pdist2(atributosTreinamento, atributosTeste);
    
    fprintf('Distancias calculadas\n');
    
    m = size(atributosTeste, 1);
    
    fprintf('Ordenando matriz de distancias...\n');
    
    %Efetua a ordena��o da matriz de distancias calculadas
    [ ~, ind ] = sort(D, 2);
    
    fprintf('Matriz ordenada\n');
    
    fprintf('Encontrando vizinhos...\n');
    
    %Encontra o valor do k vizinhos e mostra o seu rotulo para cada amostra
    %da base de treinamento
    valorPrevisto = arrayfun(@(i) mode(rotulosTreinamento(ind(i, 1:k))), 1:m)';
    
    fprintf('Vizinhos encontrados\n');
    
    tempo = toc;
    
    fprintf('Tempo treinamento: %f\n', tempo);
    
    %Mostra a acuracia da base de teste
    fprintf('Acuracia na base de teste: %f\n', mean(double(valorPrevisto == rotulosTeste)) * 100);
    
    fprintf('Fim Parti��o #%d\n\n', numeroParticao);
    
    %Efetua a avalia��o
    avaliacao = avaliar(valorPrevisto, rotulosTeste, tempo);
end