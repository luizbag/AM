function [mTheta1, mTheta2, avaliacao] = RNA_treinamento(aTreinamento,rTreinamento, aTeste,rTeste, numeroParticao,qtdNeuronio,epocas)

%RNA_treinamento Efetua o treinamento da RNA
%   [mTheta1, mTheta2, avaliacao] = RNA_treinamento(aTreinamento,rTreinamento, 
%   ...aTeste,rTeste, numeroParticao,qtdNeuronio,epocas)
%   Efetua o treinamento da rede neural passando como parametro a base de treinamento e seus rotulos
%   a base de Teste e seus Rotulos , qual parti��o esta sendo realizada o treinamento, a quantidade de neuronios, na camada intermediaria
%   e a quantidade de �pocas m�xima de treinamento

%Utilizamos somente uma camada intermedi�ria, pois foi comprovada pelo
%Pesquisador CYBENKO que o problema tem a caracteristica da Capacidade de
%aproxima��o universal, para mais detalhes segue link (Cap�tulo 2.4.6)
%ftp://ftp.dca.fee.unicamp.br/pub/docs/vonzuben/theses/lnunes_mest/cap2.pdf

   fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);

   %Inicializa algumas vari�veis �teis
   [m,n] = size(aTreinamento);
   
   %Inicicializando os Thetas com valores rand�micos                               
   mTheta1 = rand(qtdNeuronio,n + 1);       
   mTheta2 = rand(1,qtdNeuronio + 1);
   
   %Inicicializando a taxa de aprendizagem                             
   txAprendizagem = 0.06;
   
   %Inicicializando o erro auxilizar e a quantidade de �pocas j� realizadas
   erroAux = 10;
   epocasAux = 0;
       
   fprintf('Efetuando o treinamento da RNA...\n');
   tic;
   %Enquanto o erro form maior que 0.1 e a quantidade de �pocas n�o tenha
   %chego ao limite m�ximo ir� repetir o trexo de c�digo abaixo
   while( erroAux > 0.1 && epocasAux < epocas )
       erroAux = 0;
       
       %Para todas as amostras
       for i = 1:m
        
        %Ao chamar o RNA_forward, passando uma amostra e os tetas correntes
        %mostrar� qual foi o r�tulo realizado pela predi��o
        [~, a2, a3] =  RNA_forward(aTreinamento(i,:),mTheta1, mTheta2);
        a1 = [1 aTreinamento(i,:)];
               
        erro = (rTreinamento(i) - a3);
        sigL = a3 *(1 - a3) * erro ;
        
        sigH = (mTheta2' * sigL) .* (a2 .* (1 - a2));
        
        %Calcula o novo Theta basendo no Cap�tulo 4 (Redes Neurais
        %Artificiais) de Fernando C�sar C. de Castro e Maria Cristina F. de
        %Castro, disponibilizado pelo professor como material de leitura
        %adicional.
        
        %Camada de Saida
        mTheta2 = (mTheta2' + txAprendizagem * sigL * a2)';
        
        %Camada Intermedi�ria
        mTheta1 = bsxfun(@plus,mTheta1 , txAprendizagem * sigH(2:end) * a1);
        
        %Verificando o erro quadratico
        erroAux = erroAux + erro^2;
       end
       
       %Obtendo o erro quadratico m�dio
       erroAux = erroAux/m;
       
       epocasAux = epocasAux + 1;
       
   end
   
   fprintf('Finalizado o treinamento da RNA...\n');
   tempo = toc;
   fprintf('Tempo de Treinamento: %f\n', tempo);
    
    %Obtendo os r�tulos da base de treinamento para comparar com os r�tulos
    %reais
    %BASE 
    [mm,~] = size(aTreinamento);
    rotulosTreinamento = zeros(mm,1);
    
    for k = 1 : mm   
          rotulosTreinamento(k) =  RNA_forward(aTreinamento(k,:),mTheta1, mTheta2);
    end
      
    
    %Obtendo os r�tulos da base de teste para comparar com os r�tulos
    %reais
    %TESTE
    [mm,~] = size(aTeste);
    rotulosTeste = zeros(mm,1);
    
    for k = 1 : mm   
          rotulosTeste(k) =  RNA_forward(aTeste(k,:),mTheta1, mTheta2);
    end
    
    
    %Verificando a Acuracia da base de treinamento
    acuraciaTreinamento = mean(double(rotulosTreinamento == rTreinamento)) * 100;
    fprintf('Acuracia na base de treinamento: %f\n',acuraciaTreinamento );

    %Verificando a Acuracia da base de Teste
    acuraciaTeste = mean(double(rotulosTeste == rTeste)) * 100;
    fprintf('Acuracia na base de teste: %f\n', mean(double(rotulosTeste == rTeste)) * 100);

    %Obtendo as Avalia��es do m�todo
    [avaliacao] = avaliar(rotulosTeste, rTeste, tempo);
    
    %save (strcat(num2str(numeroParticao),'_.mat'), 'mTheta1', 'mTheta2', 'acuraciaTreinamento', 'acuraciaTeste')
    fprintf('Fim Parti��o #%d\n\n', numeroParticao);
end