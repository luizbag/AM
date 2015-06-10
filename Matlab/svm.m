function [ avaliacao, modeloSVM ] = svm( atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, numeroParticao, modeloCarregadoSVM )

%SVM Treinamento e Classifica��o do M�todo SVM
%  [ avaliacao, modeloSVM ] = svm( atributosTreinamento, rotulosTreinamento
%  , atributosTeste, rotulosTeste, numeroParticao, modeloCarregadoSVM )


       fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);
              
       %Verifica se j� foi calculado anteriormente o processo de
       %treinamento, caso contenha zero no modeloCarregado SVM, diz que n�o
       %foi previamente carregado, necessitando assim efetuar o treinamento
       if (isnumeric(modeloCarregadoSVM))
            tic;
            modeloSVM =  svmtrain(rotulosTreinamento, atributosTreinamento, '-c 1 -t 1 ');
            fprintf('Tempo treinamento: %d\n', toc);
       else
           modeloSVM = modeloCarregadoSVM;
       end
       
       
       %Efetuar a classifica��o da base de treinamento
       [valorPrevisto, ~, ~] = svmpredict(rotulosTreinamento, atributosTreinamento, modeloSVM);
       
       %Mostra a acuracia na base de treinamento
       fprintf('Acuracia na base de treinamento: %f\n', mean(double(valorPrevisto == rotulosTreinamento)) * 100);

       %Efetuar a classifica��o da base de teste
       [valorPrevistoTeste, ~, ~] = svmpredict(rotulosTeste, atributosTeste, modeloSVM);
       
       %Mostra a acuracia na base de teste
       fprintf('Acuracia na base de teste: %f\n', mean(double(valorPrevistoTeste == rotulosTeste)) * 100);
       
       %Efetua a Avalia��o do M�todo SVM
       [avaliacao] = avaliar(valorPrevistoTeste, rotulosTeste);
       
       fprintf('\Fim Parti��o #%d\n', numeroParticao);
end

