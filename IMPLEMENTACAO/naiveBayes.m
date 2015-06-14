function [avaliacao, pMaior, pMenor, pAtrMaior, pAtrMenor] = naiveBayes(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, numeroParticao)

%% Efetua o calculo das probabilidades de todos os dados para todos os dados de treinamento
    %
    %   [avaliacao, modeloNB] = naiveBayes(atributosTreinamento, 
    %   rotulosTreinamento, atributosTeste, rotulosTeste, numeroParticao)
    
    %   Obtem a avalia��o passando como parametro os atributos/Rotulos de
    %   Treinamento, e Atributos/Rotulos de Teste e qual parti��o esta 
    %   dentro da valida��o cruzada

%Efetua o calculo das probabilidades do Naive Bayes
[pAtrMaior, pAtrMenor] = NB_calcularProbabilidades(atributosTreinamento, rotulosTreinamento);

fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);

tic;

pMaior = mean(rotulosTreinamento == 1);
pMenor = mean(rotulosTreinamento == 0);

%Efetua a classifica��o para cada atributo de treinamento
valorPrevisto = arrayfun(@(i) NB_classificacao(atributosTreinamento(i,:), pMaior, pMenor, pAtrMaior, pAtrMenor), 1:size(atributosTreinamento, 1))';

%Mostra a acuracia na base de treinamento
fprintf('Acuracia na base de treinamento: %f\n', mean(double(valorPrevisto == rotulosTreinamento)) * 100);

%Efetua a classifica��o para cada atributo de teste
valorPrevistoTeste = arrayfun(@(i) NB_classificacao(atributosTeste(i,:), pMaior, pMenor, pAtrMaior, pAtrMenor), 1:size(atributosTeste, 1))';

%Mostra a acuracia na base de Teste
fprintf('Acuracia na base de teste: %f\n', mean(double(valorPrevistoTeste == rotulosTeste)) * 100);
tempo = toc;
fprintf('Tempo processamento: %f\n', tempo);

fprintf('Fim Parti��o #%d\n\n', numeroParticao);

%Efetua a avalia��o
avaliacao = avaliar(valorPrevistoTeste, rotulosTeste, tempo);


end

