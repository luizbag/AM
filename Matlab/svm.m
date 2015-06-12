function [ avaliacao, modeloSVM ] = svm( atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, numeroParticao, modeloCarregadoSVM )

%SVM Treinamento e Classifica��o do M�todo SVM
%  [ avaliacao, modeloSVM ] = svm( atributosTreinamento, rotulosTreinamento
%  , atributosTeste, rotulosTeste, numeroParticao, modeloCarregadoSVM )


       fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);
<<<<<<< HEAD
              
       %Verifica se j� foi calculado anteriormente o processo de
       %treinamento, caso contenha zero no modeloCarregado SVM, diz que n�o
       %foi previamente carregado, necessitando assim efetuar o treinamento
=======
       tic;
       
>>>>>>> 65a29ca169df03507d250d93a7dd84b2bd4c5299
       if (isnumeric(modeloCarregadoSVM))
            %Melhor linear -t 0 -c 0.01
            %Melhor radial -t 2 -c 0.01 -g 0.01
            modeloSVM =  svmtrain(rotulosTreinamento, atributosTreinamento, '-t 2 -c 1 -g 0.01 -q');
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
       
<<<<<<< HEAD
       %Efetua a Avalia��o do M�todo SVM
       [avaliacao] = avaliar(valorPrevistoTeste, rotulosTeste);
=======
       tempo = toc;
       
       fprintf('Tempo treinamento e valida��o: %d\n', tempo);
       
       [avaliacao] = avaliar(valorPrevistoTeste, rotulosTeste, tempo);
>>>>>>> 65a29ca169df03507d250d93a7dd84b2bd4c5299
       
       fprintf('\nFim Parti��o #%d\n', numeroParticao);
end

