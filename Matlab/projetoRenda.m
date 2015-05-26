%% Universidade Federal de Sao Carlos - UFSCar, Sorocaba
%
%  Disciplina: Aprendizado de Maquina
%  Grupo 1:
%
%  Integrantes :
%
%  Leandro Luciani Tavares
%  Luiz Benedito Aidar Gavioli
%  Victor Narcizo de Oliveira Neto
%
%  Projeto - Predicao de renda anual
%

%% Inicializacao
clear ; close all; format shortG; format loose; clc

%Numero de particoes;
numeroParticoes = 10;

%% Carregamento dos dados
fprintf('Carregamento dos dados iniciados...\n\n');
%load('projetoDados.mat');

dadosOriginais = readtable('adult_data');
dadosOriginaisTeste = readtable('adult_test');

%% Pr�-processamento
fprintf('Pr�-processando iniciado...\n\n');

[dadosPreprocessados, rotulos, colunasAusentes, tamanhoCaracteristica, indiceNumericos] = preProcessar(dadosOriginais, dadosOriginaisTeste);

[dadosNaiveBayes] = preProcessarNaiveBayes(dadosPreprocessados, colunasAusentes, tamanhoCaracteristica, indiceNumericos);

%% Normaliza��o
tipoNormalizacao = input('Deseja normalizar por Escala ou Padroniza��o? (E/P) \n', 's');

if(strcmpi(tipoNormalizacao, 'E'))
    fprintf('Normaliza��o por escala iniciada...\n\n');
    [dadosNormalizados] = normalizarEscala(dadosPreprocessados);
    %[rotulosNormalizados] = normalizarEscala(rotulos);
else
    fprintf('Normaliza��o por padroniza��o iniciada...\n\n');
    [dadosNormalizados] = normalizarPadronizacao(dadosPreprocessados);
    %[rotulosNormalizados] = normalizarPadronizacao(rotulos);
end

%TODO: melhorar isso
rotulosNormalizados = rotulos;

%% Tratamento dos ausentes
% manterAusentes = input('Deseja remover ou completar os dados ausentes? (R/C) \n', 's');
% 
% if (strcmpi(manterAusentes,'R'))
    fprintf('Removendo dados ausentes...\n\n') %Remove 3620 linhas
    linhasAusentes = any(dadosPreprocessados(:, colunasAusentes), 2);
    dadosNormalizados(linhasAusentes, :) = [];
    rotulosNormalizados(linhasAusentes, :) = [];
    
    dadosNormalizados(:, colunasAusentes) = [];
    

% else
%    fprintf('Completando dados ausentes... \n\n')
%    %TODO: Bag Usar os dados normalizados
% end

%% Correlacao linear
removerAtributos = input('Deseja remover atributos com alta correla��o linear? (S/N) \n', 's');
if(strcmpi(removerAtributos, 'S'))
    [r,p] = corrcoef(dadosNormalizados);
    [i, ~] = find(r>0.7 & r ~= 1);
    dadosNormalizados(:,i) = [];
end

%% Parti��o 
fprintf('Parti��o iniciada...\n\n');

dadosAparticionar = horzcat(dadosNormalizados, rotulosNormalizados);

[dadosParticionados] = particionar(dadosAparticionar, numeroParticoes);

%% Sele��o do m�todos

fprintf('0 - Todos\n')
fprintf('1 - KNN\n')
fprintf('2 - Regress�o log�stica\n')
fprintf('3 - Redes Neurais Artificiais\n')
fprintf('4 - SVM\n')
fprintf('5 - Naive Bayes\n')

metodoClassificacao = input('Selecione o m�todo que deseja executar\n');

hipotesesRegressao = cell(numeroParticoes);
avaliacoesRegressao = [];
hipoteseCarregada = [];

modelosSVM = cell(numeroParticoes);
avaliacoesSVM = [];

modelosNB = cell(numeroParticoes);
avaliacoesNaiveBayes = [];

if metodoClassificacao == 0 || metodoClassificacao == 1
    k = input('Qual o valor de K? (N�mero de vizinhos mais pr�ximos): \n');
end

%% Selecoes de parametros adicionais para Regressao Logistica
if metodoClassificacao == 0 || metodoClassificacao == 2
    fprintf('1 - Hip�tese linear\n')
    fprintf('2 - Hip�tese quadr�tica\n')
    fprintf('3 - Hip�tese c�bica\n')
    hipoteseRegressao = input('Selecione a hip�tese desejada\n');
    
    carregarHipotese = input('Carregar hipotese previamente calculada? (S/N)\n', 's');
    
    lambda = 0;
    
    if strcmpi(carregarHipotese, 'S')
        load(strcat('HipoteseRegressao_',hipoteseRegressao,'.mat'));
    else
        utilizarRegularizacao = input('Utilizar regulariza��o? (S/N)\n', 's');

        if (strcmpi(utilizarRegularizacao,'S'))
            lambda = input('Qual o valor do par�metro de regulariza��o?\n');
        end
    end
    
   
end

%% Classifica��o
for i = 1:numeroParticoes
    indicesTreinamento = 1:numeroParticoes;
    indicesTreinamento = indicesTreinamento(indicesTreinamento~=i);
    
    dadosTreinamento = dadosParticionados(indicesTreinamento,:,:);
    dadosTreinamento = reshape(dadosTreinamento, size(dadosTreinamento, 1)*size(dadosTreinamento, 2), size(dadosTreinamento, 3));
    dadosTeste = dadosParticionados(i,:,:);
    dadosTeste = squeeze(dadosTeste);
    
    rotulosTreinamento = dadosTreinamento(:,end);
    atributosTreinamento = dadosTreinamento(:,1:end-1);

    rotulosTeste = dadosTeste(:, end);
    atributosTeste = dadosTeste(:, 1:end-1);

    if metodoClassificacao == 0 || metodoClassificacao == 1
        avaliacaoKnn = knn(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, k);
        avaliacoesKnn = vertcat(avaliacoesKnn, avaliacaoKnn);
    end
    % Regress�o Log�stica
    if metodoClassificacao == 0 || metodoClassificacao == 2
       [ avaliacao, hipotesesRegressao{i}] = ...
           regressaoLogistica(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste,...
                              hipoteseRegressao, utilizarRegularizacao, lambda, i, 0 );     
                          
           avaliacoesRegressao = vertcat(avaliacoesRegressao, avaliacao);
    end
    if metodoClassificacao == 0 || metodoClassificacao == 3
           %TODO Victor
            % Redes Neurais
    end
    if metodoClassificacao == 0 || metodoClassificacao == 4
        [avaliacao, modelosSVM{i}] = svm(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, i);
    end
    if metodoClassificacao == 0 || metodoClassificacao == 5
        [avaliacao, modelosNB{i}] = naiveBayes(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, i);
    end
   
end

if metodoClassificacao == 0 || metodoClassificacao == 1
    fprintf('Resultados KNN\n');
    avaliarFinal(avaliacoesKnn);
end

if metodoClassificacao == 0 || metodoClassificacao == 2
    fprintf('Resultados regress�o log�stica\n');
    indiceMelhorHipotese = avaliarFinal(avaliacoesRegressao);
    
    exportarRegresao = input('Deseja exportar a melhor hipotese? (S/N)\n', 's');
    if (strcmpi(exportarRegresao,'S'))
        melhorHipoteseRegressao = hipotesesRegressao{indiceMelhorHipotese};
        save(strcat('HipoteseRegressao_', hipoteseRegressao, ' .mat'), 'melhorHipoteseRegressao');
    end   
end

if metodoClassificacao == 0 || metodoClassificacao == 4
    fprintf('Resultados SVM \n');
    indiceMelhorModelo = avaliarFinal(avaliacoesSVM);
    
    exportarSVM = input('Deseja exportar o modelo do SVM? (S/N)\n', 's');
    
    if (strcmpi(exportarSVM,'S'))
        melhorModeloSVM = modelosSVM{indiceMelhorHipotese};
        save('ModeloSVM.mat', 'melhorModeloSVM');
    end   
end


%% Finalizacao
%clear; %Descomentar na versao final
%close all;