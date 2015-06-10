function [ avaliacao, modeloSVM ] = svm( atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, numeroParticao, modeloCarregadoSVM )
       fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);
              
       if (isnumeric(modeloCarregadoSVM))
            tic;
            modeloSVM =  svmtrain(rotulosTreinamento, atributosTreinamento, '-c 1 -t 1 ');
            fprintf('Tempo treinamento: %d\n', toc);
       else
           modeloSVM = modeloCarregadoSVM;
       end
       
       [valorPrevisto, ~, ~] = svmpredict(rotulosTreinamento, atributosTreinamento, modeloSVM);
       
       fprintf('Acuracia na base de treinamento: %f\n', mean(double(valorPrevisto == rotulosTreinamento)) * 100);

       [valorPrevistoTeste, ~, ~] = svmpredict(rotulosTeste, atributosTeste, modeloSVM);
       
       fprintf('Acuracia na base de teste: %f\n', mean(double(valorPrevistoTeste == rotulosTeste)) * 100);
       
       [avaliacao] = avaliar(valorPrevistoTeste, rotulosTeste);
       
       fprintf('\Fim Parti��o #%d\n', numeroParticao);
end

