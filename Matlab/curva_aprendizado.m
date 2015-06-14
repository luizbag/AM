function [ ] = curva_aprendizado( dadosNormalizados, dadosNaiveBayes, rotulosNormalizados )
    %Numero de particoes;
    numeroParticoes = 10;
    %% ================= Parte 4: Particionamento das Amostras ====================
    % Foi realizado o particionamento das amostras utilizando o m�todo de
    % Valida��o cruzada com 10 parti��es
    fprintf('Curvas de aprendizado\n\n');
    fprintf('Parti��o iniciada...\n\n');

    dadosAparticionar = horzcat(dadosNormalizados, rotulosNormalizados);

    dadosAparticionarNaiveBayes =  horzcat(dadosNaiveBayes, rotulosNormalizados);

    [dadosParticionados, dadosNaiveBayesParticionados] = particionar(dadosAparticionar, dadosAparticionarNaiveBayes, numeroParticoes);

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

        avaliacoes = [];

        modelosSVM = cell(numeroParticoes);
        hipotesesRegressao = cell(numeroParticoes);
        hipoteseCarregada = [];
        curvaRNA = [];
        curvaKNN = [];
        curvaNaive = [];
        curvaRL = [];
        curvaSVM = [];

        modelosNB = cell(numeroParticoes);


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

            lambda = 0;

            utilizarRegularizacao = input('Utilizar regulariza��o? (S/N)\n', 's');

            if (strcmpi(utilizarRegularizacao,'S'))
                lambda = input('Qual o valor do par�metro de regulariza��o?\n');
            end
        end

        %Para RNA devemos escolher com quantos neuronios iremos treinar a rede
        if metodoClassificacao == 0 || metodoClassificacao == 3 

           qtdNeuronios = 50;

           alterarQtdNeuronios = input('Deseja alterar o valor padr�o de 50 neur�nios para treinamento? (S/N)\n', 's');

           if (strcmpi(alterarQtdNeuronios,'S'))
              qtdNeuronios = input('Quantos neur�nios deseja utilizar na RNA?\n');
           end
        end

        %% ================= Parte 6: Treinamento e Classifica��o ====================
        % Os metodos ser�o executados para cada parti��o das 10 previamente
        % separadas
        for i = 1:numeroParticoes-1
            %efetuando a separa��o dos dados/rotulos de treinamento e de
            %teste
            indicesTreinamento = 1:i;
            %indicesTreinamento = indicesTreinamento(indicesTreinamento~=i);

            dadosTreinamento = dadosParticionados(indicesTreinamento,:,:);
            dadosTreinamento = reshape(dadosTreinamento, size(dadosTreinamento, 1)*size(dadosTreinamento, 2), size(dadosTreinamento, 3));
            dadosTeste = dadosParticionados(numeroParticoes,:,:);
            dadosTeste = squeeze(dadosTeste);

            rotulosTreinamento = dadosTreinamento(:,end);
            atributosTreinamento = dadosTreinamento(:,1:end-1);

            rotulosTeste = dadosTeste(:, end);
            atributosTeste = dadosTeste(:, 1:end-1);

            fprintf('\nIn�cio Parti��o #%d - BaseTreinamento: #%d\n', i,size(dadosTreinamento,1));
            
            % KNN - Executar o m�todo de avalia��o
            if metodoClassificacao == 0 || metodoClassificacao == 1

                %Efetua a predi��o para os atributos de teste
                avaliacaoKnn = knn(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, k, i);
                %Faz a concatena��o das avalia��es de todas as parti��es
                avaliacoes = vertcat(avaliacoes, avaliacaoKnn);
            end


            % Regress�o Logistica - Executar a obten��o da Hipotese e a
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 2

                [ ~, hipotesesRegressao] = ...
                regressaoLogistica(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste,...
                hipoteseRegressao, utilizarRegularizacao, lambda, i, 0 );   

                switch hipoteseRegressao
                    case 1
                        atributosTesteExpandidos = atributosTeste;
                        atributosTreinamentoExpandidos = atributosTreinamento;
                    case 2
                        atributosTesteExpandidos = RL_expandeAtributosPolinomial(atributosTeste, 2);
                        atributosTreinamentoExpandidos =  RL_expandeAtributosPolinomial(atributosTreinamento, 2);
                    case 3
                        atributosTesteExpandidos = RL_expandeAtributosPolinomial(atributosTeste, 3);
                        atributosTreinamentoExpandidos =  RL_expandeAtributosPolinomial(atributosTreinamento, 3);
                end

                %Efetua a predi��o para os atributos de teste
                valorPrevistoTreinamento = RL_predicao(hipotesesRegressao, atributosTreinamento);
                
                %Efetua a predi��o para os atributos de teste
                valorPrevistoTeste = RL_predicao(hipotesesRegressao, atributosTesteExpandidos);
                
                erroTreinamentoRL= (sum(valorPrevistoTreinamento ~= rotulosTreinamento)/size(rotulosTreinamento,1))*100;
                erroTesteRL = (sum(valorPrevistoTeste ~= rotulosTeste)/size(rotulosTeste,1))*100;
                    
                 curvaRL = vertcat(curvaRL, [erroTreinamentoRL erroTesteRL]);
               
            end

            % RNA - Executar a obten��o dos Thetas e efetua a 
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 3

                 [mTheta1, mTheta2, avaliacao] = RNA_treinamento(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste,i,qtdNeuronios,100);
             
                  %Obtendo os r�tulos da base de treinamento para comparar com os r�tulos
                    %reais
         
                    for k = 1 : size(atributosTreinamento,1)
                          predicaoTreinamentoRNA(k) =  RNA_forward(atributosTreinamento(k,:),mTheta1, mTheta2);
                    end
                    
                    for k = 1 : size(atributosTeste,1)
                        predicaoTesteRNA(k) =  RNA_forward(atributosTeste(k,:),mTheta1, mTheta2);
                    end
                    
                    erroTreinamentoRNA = (sum(predicaoTreinamentoRNA' ~= rotulosTreinamento)/size(rotulosTreinamento,1))*100;
                    erroTesteRNA = (sum(predicaoTesteRNA' ~= rotulosTeste)/size(rotulosTeste,1))*100;
                    
                   curvaRNA = vertcat(curvaRNA, [erroTreinamentoRNA erroTesteRNA]);
                 
            end

            % SVM - Executar a obten��o do Modelo e efetuar a  
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 4
                 melhorModeloSVM = 0;
                [avaliacao, modeloSVM] = svm(atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, i,melhorModeloSVM);
                
                [valorPrevisto, ~, ~] = svmpredict(rotulosTreinamento, atributosTreinamento, modeloSVM);
                
                [valorPrevistoTeste, ~, ~] = svmpredict(rotulosTeste, atributosTeste, modeloSVM);
                
                 erroTreinamentoSVM = (sum(valorPrevisto ~= rotulosTreinamento)/size(rotulosTreinamento,1))*100;
                 erroTesteSVM = (sum(valorPrevistoTeste ~= rotulosTeste)/size(rotulosTeste,1))*100;
                    
                 curvaSVM = vertcat(curvaSVM, [erroTreinamentoSVM erroTesteSVM]);
                
            end


            % Naive Bayes - Executar a obten��o das probabilidades e efetuar 
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 5
                  dadosTreinamentoNB = dadosNaiveBayesParticionados(indicesTreinamento,:,:);
                  dadosTreinamentoNB = reshape(dadosTreinamentoNB, size(dadosTreinamentoNB, 1)*size(dadosTreinamentoNB, 2), size(dadosTreinamentoNB, 3));

                  dadosTesteNB = squeeze(dadosNaiveBayesParticionados(numeroParticoes,:,:));

                  rotulosTreinamentoNB = dadosTreinamentoNB(:,end);
                  atributosTreinamentoNB = dadosTreinamentoNB(:,1:end-1);

                  rotulosTesteNB = dadosTesteNB(:, end);
                  atributosTesteNB = dadosTesteNB(:, 1:end-1);

                 [avaliacao, pMaior, pMenor, pAtrMaior, pAtrMenor] = naiveBayes(atributosTreinamentoNB, rotulosTreinamentoNB, atributosTesteNB, rotulosTesteNB, i);
  
                 predicaoTreinamentoNaive = arrayfun(@(i) NB_classificacao(atributosTreinamentoNB(i,:), pMaior, pMenor, pAtrMaior, pAtrMenor), 1:size(atributosTreinamentoNB, 1))';
                 predicaoTesteNaive = arrayfun(@(i) NB_classificacao(atributosTesteNB(i,:), pMaior, pMenor, pAtrMaior, pAtrMenor), 1:size(atributosTesteNB, 1))';
                 
                 erroTreinamentoNaive = (sum(predicaoTreinamentoNaive ~= rotulosTreinamentoNB)/size(rotulosTreinamentoNB,1))*100;
                 erroTesteNaive = (sum(predicaoTesteNaive ~= rotulosTesteNB)/size(rotulosTesteNB,1))*100;
                    
                 curvaNaive = vertcat(curvaNaive, [erroTreinamentoNaive erroTesteNaive]);
        
            end

        end

     %% ================= Parte 7: Resultados ====================
        % Aqui mostrar� as curvas obtidas pelos m�todos selecioinados

        
         % KNN - Executar o m�todo de avalia��o
            if metodoClassificacao == 0 || metodoClassificacao == 1
                figure;
                 plot(curvaKNN);
                 axis([1, 9, 0, 30]);
                 
                 title('Cruva de Aprendizagem - KNN');
            end


            % Regress�o Logistica - Executar a obten��o da Hipotese e a
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 2
                figure;
                 plot(curvaRL);
                 axis([1, 9, 0, 30]);
          
                 title('Cruva de Aprendizagem - Regress�o Logistica');
            end

            % RNA - Executar a obten��o dos Thetas e efetua a 
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 3

                figure;
                 plot(curvaRNA);
                 axis([1, 9, 0, 30]);
                 
                 title('Cruva de Aprendizagem - RNA');
                
            end

            % SVM - Executar a obten��o do Modelo e efetuar a  
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 4
            
                 figure;
                 plot(curvaSVM);
                 axis([1, 9, 0, 30]);
                
                title('Cruva de Aprendizagem - SVM');
            end

            % Naive Bayes - Executar a obten��o das probabilidades e efetuar 
            % avalia��o dos dados de treinamento
            if metodoClassificacao == 0 || metodoClassificacao == 5
             
                 figure;
                 plot(curvaNaive);
                 axis([1, 9, 0, 30]);
                 title('Cruva de Aprendizagem - Naive');
            end
            
            
            legend('Base de Treinamento','Base de Teste');
            xlabel('Quantidade de parti��es utilizadas no treinamento');
            ylabel('Porcentagem de Erro na Predi��o');
       
    end
end