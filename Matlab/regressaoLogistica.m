function [ avaliacao,  theta ] = ...
    regressaoLogistica( atributosTreinamento, rotulosTreinamento, atributosTeste, rotulosTeste, ...
                        hipoteseRegressao, utilizarRegularizacao, lambda, numeroParticao, melhorHipoteseRegressao ) 

fprintf('\nIn�cio Parti��o #%d\n', numeroParticao);

switch hipoteseRegressao
    case 1
        atributosExpandidos = atributosTreinamento;
        atributosTesteExpandidos = atributosTeste;
    case 2
        atributosExpandidos = RL_expandeAtributosPolinomial(atributosTreinamento, 2);
        atributosTesteExpandidos = RL_expandeAtributosPolinomial(atributosTeste, 2);
    case 3
        atributosExpandidos = RL_expandeAtributosPolinomial(atributosTreinamento, 3);
        atributosTesteExpandidos = RL_expandeAtributosPolinomial(atributosTeste, 3);
end

thetaInicial = zeros(size(atributosExpandidos, 2), 1);

% Configura op��es
opcoes = optimset('GradObj', 'on', 'MaxIter', 400, 'Display', 'off');

fprintf('Minimizando fun��o de custo...\n');

tic;
% Otimiza o gradiente
[theta, J, exit_flag] = ...
	fminunc(@(t)(RL_funcaoCustoReg(t, atributosExpandidos, rotulosTreinamento, lambda, utilizarRegularizacao)), thetaInicial, opcoes);
tempo = toc;
fprintf('Tempo minimiza��o: %f\n', tempo);

fprintf('Custo m�nimo encontrado: %f\n', J);

valorPrevisto = RL_predicao(theta, atributosExpandidos);

fprintf('Acuracia na base de treinamento: %f\n', mean(double(valorPrevisto == rotulosTreinamento)) * 100);

valorPrevistoTeste = RL_predicao(theta, atributosTesteExpandidos);

fprintf('Acuracia na base de teste: %f\n', mean(double(valorPrevistoTeste == rotulosTeste)) * 100);

[avaliacao] = avaliar(valorPrevistoTeste, rotulosTeste, tempo);

fprintf('Fim Parti��o #%d\n\n', numeroParticao);

end

