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
clear ; close all; format shortG; clc

%Numero de particoes;
numeroParticoes = 10;

%% Carregamento dos dados
fprintf('Carregamento dos dados iniciados...\n\n');
%load('projetoDados.mat');

dadosOriginais = readtable('adult_data');
dadosOriginaisTeste = readtable('adult_test');

%% Pr�-processamento
fprintf('Pr�-processando iniciado...\n\n');

[dadosPreprocessados, rotulos, colunasAusentes, tamanhoCaracteristica] = preProcessar(dadosOriginais, dadosOriginaisTeste);


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
manterAusentes = input('Deseja remover ou completar os dados ausentes? (R/C) \n', 's');

if (strcmpi(manterAusentes,'R'))
    fprintf('Removendo dados ausentes...\n\n') %Remove 3620 linhas
    linhasAusentes = any(dadosPreprocessados(:, colunasAusentes), 2);
    dadosNormalizados(linhasAusentes, :) = [];
    rotulosNormalizados(linhasAusentes, :) = [];
else
    fprintf('Completando dados ausentes... \n\n')
    %TODO: Bag Usar os dados normalizados
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

metodoClassificacao = input('Selecione o m�todo que deseja executar\n');

% acuraciaRegressao = zeros(numeroParticoes);
% fMedidaMediaRegressao = zeros(numeroParticoes);
% precisaoMediaRegressao = zeros(numeroParticoes);
% revocacaoMediaRegressao = zeros(numeroParticoes);
hipotesesRegressao = cell(numeroParticoes);
avaliacoesRegressao = [];

modelosSVM = cell(numeroParticoes);
avaliacoesSVM = [];

%% Selecoes de parametros adicionais para Regressao Logistica
if metodoClassificacao == 0 || metodoClassificacao == 2
    fprintf('1 - Hip�tese linear\n')
    fprintf('2 - Hip�tese quadr�tica\n')
    fprintf('3 - Hip�tese c�bica\n')
    hipoteseRegressao = input('Selecione a hip�tese desejada\n');
    
    utilizarRegularizacao = input('Utilizar regulariza��o? (S/N)\n', 's');
    
    if (strcmpi(utilizarRegularizacao,'S'))
        lambda = input('Qual o valor do par�metro de regulariza��o?\n');
    else
        lambda = 0;
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
            % TODO:BAG
            % KNN
            % [acuraciaKnn] = knn(dadosTreinamento, dadosTeste);
    end
    % Regress�o Log�stica
    if metodoClassificacao == 0 || metodoClassificacao == 2
       [ avaliacao, hipotesesRegressao{i}] = ...
           regressaoLogistica(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste,...
                              hipoteseRegressao, utilizarRegularizacao, lambda, i );     
                          
           avaliacoesRegressao = vertcat(avaliacoesRegressao, avaliacao);     
    end
    if metodoClassificacao == 0 || metodoClassificacao == 3
           %TODO Victor
            % Redes Neurais
    end
    if metodoClassificacao == 0 || metodoClassificacao == 4
        [avaliacao, modelosSVM{i}] = svm(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, i);
    end
   
end

if metodoClassificacao == 0 || metodoClassificacao == 2
    fprintf('Resultados regress�o log�stica\n');
    indiceMelhorHipotese = avaliarFinal(avaliacoesRegressao);
    
    exportarRegresao = input('Deseja exportar a melhor hipotese? (S/N)\n', 's');
    if (strcmpi(exportarRegresao,'S'))
        melhorHipoteseRegressao = hipotesesRegressao{indiceMelhorHipotese};
        save('HipoteseRegressao.mat', 'melhorHipoteseRegressao');
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