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

[dadosNaiveBayes] = preProcessarNaiveBayes(dadosPreprocessados, indiceNumericos);

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

rotulosNormalizados = rotulos;

fprintf('Removendo dados ausentes...\n\n') %Remove p linhas
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

%% Parti��o 
fprintf('Parti��o iniciada...\n\n');

dadosAparticionar = horzcat(dadosNormalizados, rotulosNormalizados);

dadosAparticionarNaiveBayes =  horzcat(dadosNaiveBayes, rotulosNormalizados);

[dadosParticionados, dadosNaiveBayesParticionados] = particionar(dadosAparticionar, dadosNaiveBayes, numeroParticoes);

% size(dadosParticionados)
% size(dadosNaiveBayesParticionados)
metodoClassificacao = 0;
%% Sele��o do m�todos
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

    %Redes Neurais
    if metodoClassificacao == 0 || metodoClassificacao == 3
        carregarThetas = input('Carregar os Thetas previamente calculados? (S/N)\n', 's');

        if (strcmpi(carregarThetas,'S'))
                load('thetasRedesNeurais.mat');
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
            avaliacaoKnn = knn(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, k, i);
            avaliacoesKnn = vertcat(avaliacoesKnn, avaliacaoKnn);
        end
        % Regress�o Log�stica
        if metodoClassificacao == 0 || metodoClassificacao == 2

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

                    valorPrevistoTeste = RL_predicao(melhorHipoteseRegressao, atributosTesteExpandidos);
                    avaliacao = avaliar(valorPrevistoTeste,valorPrevistoTeste);
             end

               avaliacoesRegressao = vertcat(avaliacoesRegressao, avaliacao);
        end
        if metodoClassificacao == 0 || metodoClassificacao == 3

             if (strcmpi(carregarThetas,'N'))
               [mTheta1, mTheta2, avaliacao] = RNA_treinamento(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste,i,200,100);
             else
                 rTesteItem = zeros(size(atributosTeste,1),1);
                  for item = 1:size(atributosTeste,1)
                      rTesteItem(item) =  RNA_forward(atributosTeste(item,:),mTheta1, mTheta2);
                  end

                    acuraciaTeste = mean(double(rotulosTeste == rTesteItem)) * 100;
                    fprintf('Acuracia na base de teste: %f na parti��o %d\n', acuraciaTeste, i);
                    avaliacao = avaliar(rTesteItem,rotulosTeste);
             end

             avaliacoesRNA = vertcat(avaliacoesRNA, avaliacao);
        end
        if metodoClassificacao == 0 || metodoClassificacao == 4
            [avaliacao, modelosSVM{i}] = svm(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, i);
        end
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