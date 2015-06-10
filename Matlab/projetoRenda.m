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
% O programa solicita qual normaliza��o deseja efetuar, se por Escala ou
% Padroniza��o

tipoNormalizacao = input('Deseja normalizar por Escala ou Padroniza��o? (E/P) \n', 's');

if(strcmpi(tipoNormalizacao, 'E'))
    fprintf('Normaliza��o por escala iniciada...\n\n');
    [dadosNormalizados] = normalizarEscala(dadosPreprocessados);
else
    fprintf('Normaliza��o por padroniza��o iniciada...\n\n');
    [dadosNormalizados] = normalizarPadronizacao(dadosPreprocessados);
end

rotulosNormalizados = rotulos;

fprintf('Removendo dados ausentes...\n\n') %Remove p linhas

%Obtendo as amostras com todos os atributos preenchidos

linhasAusentes = any(dadosPreprocessados(:, colunasAusentes), 2);
dadosNormalizados(linhasAusentes, :) = [];
rotulosNormalizados(linhasAusentes, :) = [];

dadosNormalizados(:, colunasAusentes) = [];

Z = reduzir_atributos(dadosNormalizados, 3);

pos = find(rotulosNormalizados == 1);
neg = find(rotulosNormalizados == 0);
figure; hold on;

scatter3(Z(pos(1:10000), 1), Z(pos(1:10000), 2), Z(pos(1:10000), 3), 'b+');
scatter3(Z(neg(1:10000), 1), Z(neg(1:10000), 2), Z(neg(1:10000), 3), 'ro');

%plot(Z(neg(1:10000), 1), Z(neg(1:10000), 2), 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 7);
%plot(Z(pos(1:10000), 1), Z(pos(1:10000), 2), 'b+','LineWidth', 2, 'MarkerSize', 7);
title('Plot 3D da base de dados');
hold off;
dadosNaiveBayes(linhasAusentes, :) = [];
dadosNaiveBayes(:, union(colunasAusentes, indiceNumericos)) = [];

%% ================= Parte 4: Particionamento das Amostras ====================
% Foi realizado o particionamento das amostras utilizando o m�todo de
% Valida��o cruzada com 10 parti��es
fprintf('Parti��o iniciada...\n\n');
 
dadosAparticionar = horzcat(dadosNormalizados, rotulosNormalizados);

dadosAparticionarNaiveBayes =  horzcat(dadosNaiveBayes, rotulosNormalizados);

[dadosParticionados, dadosNaiveBayesParticionados] = particionar(dadosAparticionar, dadosNaiveBayes, numeroParticoes);

% size(dadosParticionados)
% size(dadosNaiveBayesParticionados)
metodoClassificacao = 0;


%% ================= Parte 5: Escolha do m�todo a ser aplicado ====================
% Foi criado um menu para a escolha do m�todo que ser� realizado o
% procedimento, 0 para executar todos os m�todos de uma unica vez.

while metodoClassificacao ~= 6
    fprintf('0 - Todos\n')
    fprintf('1 - KNN\n')
    fprintf('2 - Regress�o log�stica\n')
    fprintf('3 - Redes Neurais Artificiais\n')
    fprintf('4 - SVM\n')
    fprintf('5 - Naive Bayes\n')
    fprintf('6 - Sair\n')

    metodoClassificacao = input('Selecione o m�todo que deseja executar\n');
    if metodoClassificacao == 6
        break
    end

    hipotesesRegressao = cell(numeroParticoes);
    avaliacoesRegressao = [];
    avaliacoesRNA = [];
    hipoteseCarregada = [];

    modelosSVM = cell(numeroParticoes);
    avaliacoesSVM = [];

    avaliacoesKnn = [];

    modelosNB = cell(numeroParticoes);
    avaliacoesNaiveBayes = [];

    %Cada m�todo tem sua particularidade na escolha de parametros
    
    %Para o Knn devemos escolher quantos visinhos ser�o avaliados pelo
    %m�todo
    if metodoClassificacao == 0 || metodoClassificacao == 1
        k = input('Qual o valor de K? (N�mero de vizinhos mais pr�ximos): \n');
    end

    %Para a Regress�o Logistica devemos escolher qual o tipo da Hip�tese
    %que dever� ser aplicado e se desejar� efetuar o procedimento com
    %Regulariza��o
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

    %Para RNA devemos escolher com quantos neuronios iremos treinar a rede
    if metodoClassificacao == 0 || metodoClassificacao == 3
        carregarThetas = input('Carregar os Thetas previamente calculados? (S/N)\n', 's');

        qtdNeuronios = 50;
        
        if (strcmpi(carregarThetas,'S'))
                load('thetasRedesNeurais.mat');
        else
          
           alterarQtdNeuronios = input('Deseja alterar o valor padr�o de 50 neur�nios para treinamento? (S/N)\n', 's');

           if (strcmpi(alterarQtdNeuronios,'S'))
              qtdNeuronios = input('Quantos neur�nios deseja utilizar na RNA?\n');
           end
        end
        
    end

    %% ================= Parte 6: Treinamento e Classifica��o ====================
    % Os metodos ser�o executados para cada parti��o das 10 previamente
    % separadas
    for i = 1:numeroParticoes
        
        %efetuando a separa��o dos dados/rotulos de treinamento e de
        %teste
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

        % KNN - Executar o m�todo de avalia��o
        if metodoClassificacao == 0 || metodoClassificacao == 1
            
            %Efetua a predi��o para os atributos de teste
            avaliacaoKnn = knn(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, k, i);
            %Faz a concatena��o das avalia��es de todas as parti��es
            avaliacoesKnn = vertcat(avaliacoesKnn, avaliacaoKnn);
        end
       
        
        % Regress�o Logistica - Executar a obten��o da Hipotese e a
        % avalia��o dos dados de treinamento
        if metodoClassificacao == 0 || metodoClassificacao == 2

             %Verifica se deseja carregar a hipotese previamente calculada
             if (strcmpi(carregarHipotese,'N'))
                        [ avaliacao, hipotesesRegressao{i}] = ...
                        regressaoLogistica(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste,...
                        hipoteseRegressao, utilizarRegularizacao, lambda, i, 0 );   
             else
                 switch hipoteseRegressao
                        case 1
                            atributosTesteExpandidos = atributosTeste;
                        case 2
                            atributosTesteExpandidos = RL_expandeAtributosPolinomial(atributosTeste, 2);
                        case 3
                            atributosTesteExpandidos = RL_expandeAtributosPolinomial(atributosTeste, 3);
                 end

                    %Efetua a predi��o para os atributos de teste
                    valorPrevistoTeste = RL_predicao(melhorHipoteseRegressao, atributosTesteExpandidos);
                    
                    %Chama o m�todo Avaliar que faz todo o processo de
                    %gera��o de indices para avalia��o do m�todo
                    avaliacao = avaliar(valorPrevistoTeste,valorPrevistoTeste);
             end

               %Faz a concatena��o das avalia��es de todas as parti��es
               avaliacoesRegressao = vertcat(avaliacoesRegressao, avaliacao);
        end
        
        % RNA - Executar a obten��o dos Thetas e efetua a 
        % avalia��o dos dados de treinamento
        if metodoClassificacao == 0 || metodoClassificacao == 3

            %Verifica se deseja obter os Thetas previamente calculados
             if (strcmpi(carregarThetas,'N'))
               %Efetua o Treinamento da RNA
               [mTheta1, mTheta2, avaliacao] = RNA_treinamento(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste,i,qtdNeuronios,100);
             else
                 rTesteItem = zeros(size(atributosTeste,1),1);
                 
                  %Para cada amostra de teste � obtido a sua predi��o
                  for item = 1:size(atributosTeste,1)
                      rTesteItem(item) =  RNA_forward(atributosTeste(item,:),mTheta1, mTheta2);
                  end

                    %Chama o m�todo Avaliar que faz todo o processo de
                    %gera��o de indices para avalia��o do m�todo
                    avaliacao = avaliar(rTesteItem,rotulosTeste);
             end
             %Faz a concatena��o das avalia��es de todas as parti��es
             avaliacoesRNA = vertcat(avaliacoesRNA, avaliacao);
        end
        
        % SVM - Executar a obten��o do Modelo e efetuar a  
        % avalia��o dos dados de treinamento
        if metodoClassificacao == 0 || metodoClassificacao == 4
            [avaliacao, modelosSVM{i}] = svm(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, i);
        end
                
        
        % Naive Bayes - Executar a obten��o das probabilidades e efetuar 
        % avalia��o dos dados de treinamento
        if metodoClassificacao == 0 || metodoClassificacao == 5
              dadosTreinamentoNB = dadosNaiveBayesParticionados(indicesTreinamento,:,:);
              dadosTreinamentoNB = reshape(dadosTreinamentoNB, size(dadosTreinamentoNB, 1)*size(dadosTreinamentoNB, 2), size(dadosTreinamentoNB, 3));

              dadosTesteNB = squeeze(dadosNaiveBayesParticionados(i,:,:));

              rotulosTreinamentoNB = dadosTreinamentoNB(:,end);
              atributosTreinamentoNB = dadosTreinamentoNB(:,1:end-1);

              rotulosTesteNB = dadosTesteNB(:, end);
              atributosTesteNB = dadosTesteNB(:, 1:end-1);

            [avaliacao, modelosNB{i}] = naiveBayes(atributosTreinamentoNB, rotulosTreinamento, atributosTesteNB, rotulosTeste, i);
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
            save(strcat('HipoteseRegressao_', num2str(hipoteseRegressao), ' .mat'), 'melhorHipoteseRegressao','hipoteseRegressao');
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
end

%% Finalizacao
%clear; %Descomentar na versao final
%close all;