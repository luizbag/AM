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

%% ================= Parte 1: Carregando a base de dados ====================
%  
fprintf('Carregamento dos dados iniciados...\n\n');

dadosOriginais = readtable('adult_data');
dadosOriginaisTeste = readtable('adult_test');

%% ================= Parte 2: Efetuando o Pr�-Processamento dos dados =======
% Para trabalhar com a base de dados dada, foi necess�rio realizar
% algumas adequa��es no modelo de dados, pois existiam inconsistencias
% tanto na sua formata��o quanto atributos faltantes
%
% Foi realizado 2 pr�-processamentos, um para os m�todos (Knn,Regress�o
% Logistica, Redes Neurais Artificiais, SVM) e outro para o NaiveBayes pela
% suas caracteristicas
fprintf('Pr�-processando iniciado...\n\n');

[dadosPreprocessados, rotulos, colunasAusentes, tamanhoCaracteristica, indiceNumericos] = preProcessar(dadosOriginais, dadosOriginaisTeste);

[dadosNaiveBayes] = preProcessarNaiveBayes(dadosPreprocessados, indiceNumericos);

%% ================= Parte 3: Normaliza��o dos dados ====================
fprintf('Normaliza��o por padroniza��o iniciada...\n\n');
[dadosNormalizados] = normalizarPadronizacao(dadosPreprocessados);

rotulosNormalizados = rotulos;

fprintf('Removendo dados ausentes...\n\n') %Remove p linhas

%Obtendo as amostras com todos os atributos preenchidos

linhasAusentes = any(dadosPreprocessados(:, colunasAusentes), 2);
dadosNormalizados(linhasAusentes, :) = [];
rotulosNormalizados(linhasAusentes, :) = [];

dadosNormalizados(:, colunasAusentes) = [];

plotar = input('Deseja visualizar o espalhamento dos dados (dimens�o reduzida)? (S/N)\n', 's');

%Efetua a visualiza��o dos dados utilizando o PCA em 3D
if strcmpi(plotar, 'S')
    Z = reduzir_atributos(dadosNormalizados, 3);

    pos = find(rotulosNormalizados == 1);
    neg = find(rotulosNormalizados == 0);
    figure; hold on;
    namostras = 5000;
    scatter3(Z(pos, 1), Z(pos, 2), Z(pos, 3), 'b+');
    scatter3(Z(neg, 1), Z(neg, 2), Z(neg, 3), 'ro');
    legend('>=50k','<50k');
    title('Plot 3D da base de dados');
    hold off;
    pause;
end
dadosNaiveBayes(linhasAusentes, :) = [];
dadosNaiveBayes(:, union(colunasAusentes, indiceNumericos)) = [];

%Verifica se deseja obter as curvas de aprendizado ou efetuar a valida��o
%Cruzada
op = input('Deseja fazer as curvas de aprendizado? (S/N)\n', 's');
if strcmpi(op, 'S')
    curva_aprendizado(dadosNormalizados, dadosNaiveBayes, rotulosNormalizados);
end
op = input('Deseja rodar a valida��o cruzada? (S/N)\n', 's');
if strcmpi(op, 'S')
    validacao_cruzada(dadosNormalizados, dadosNaiveBayes, rotulosNormalizados);
end
%% Finalizacao
%clear; %Descomentar na versao final
%close all;