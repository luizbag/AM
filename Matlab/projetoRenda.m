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

fprintf('Pr�-processando iniciado...\n\n');

dados = preProcessar(dadosOriginais, dadosOriginaisTeste);


% indices = find(cellfun(@(x) strcmpi(x,'>50k'), table2cell(Y)));
% 
% T = zeros(size(Y,1),1);
% T(indices) = 1;
% Y = T;

%TODO (victor): Feito at� aqui


%% Finalizacao
%clear; %Descomentar na versao final
close all;