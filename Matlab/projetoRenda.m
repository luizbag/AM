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
clear ; close all; clc

%% Carrega os dados
fprintf('Carregamento dos dados iniciados...\n\n');
%load('projetoDados.mat');

dadosOriginais = readtable('adult_data');
dadosOriginaisTeste = readtable('adult_test');

%% Pr�-processamento
fprintf('Pr�-processando iniciado...\n\n');

[atributos, rotulos, indicesAusentes] = preProcessar(dadosOriginais, dadosOriginaisTeste);

%% Normaliza��o
fprintf('Normaliza��o iniciada...\n\n');

[atributosNormalizados] = normalizar(atributos);

%% KNN


%% Finalizacao
%clear; %Descomentar na versao final
close all;