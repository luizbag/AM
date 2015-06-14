function [ avaliacao, modeloSVM ] = svm( atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, numeroParticao, modeloCarregadoSVM, kernel, custo, gama )

%SVM Treinamento e Classifica��o do M�todo SVM
%  [ avaliacao, modeloSVM ] = svm( atributosTreinamento, rotulosTreinamento
%  , atributosTeste, rotulosTeste, numeroParticao, modeloCarregadoSVM )


       fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);

              
       %Verifica se j� foi calculado anteriormente o processo de
       %treinamento, caso contenha zero no modeloCarregado SVM, diz que n�o
       %foi previamente carregado, necessitando assim efetuar o treinamento

       tic;
       parametros = '';
       
       if kernel == 0
           parametros = strcat({'-t '},num2str(kernel),{' -c '},num2str(custo),{' -q'});
       else
           parametros = strcat({'-t '},num2str(kernel),{' -c '},num2str(custo),{' -g '},num2str(gama),{' -q'});
       end
       

       if (isnumeric(modeloCarregadoSVM))
            %Melhor linear -t 0 -c 0.01
            %Melhor radial -t 2 -c 0.01 -g 0.01
            modeloSVM =  svmtrain(rotulosTreinamento, atributosTreinamento, parametros);
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
       tempo = toc;
       
       fprintf('Tempo treinamento e valida��o: %d\n', tempo);
       
       [avaliacao] = avaliar(valorPrevistoTeste, rotulosTeste, tempo);
       
       fprintf('\nFim Parti��o #%d\n', numeroParticao);
end

