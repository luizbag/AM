function [ dadosPreprocessados, rotulos, colunasAusentes, tamanhoCaracteristica ] = preProcessar(dadosOriginais, dadosOriginaisTeste)

%Concatena os dados da base original com a base de teste
dadosOriginaisAgrupados = vertcat(dadosOriginais, dadosOriginaisTeste);

% dadosOriginaisAgrupados.native_country = categorical(dadosOriginaisAgrupados.native_country);
% summary(dadosOriginaisAgrupados)

%age, workclass, fnlwgt, education, education-num, marital-status, occupation, 
%relationship, race, sex, capital-gain, capital-loss, hours-per-week, native-country, target

%Vetor para representar quantas colunas cada atributo original
%(caracter�stica) ocupara na matriz final
tamanhoCaracteristica = ones(size(dadosOriginaisAgrupados, 2) - 1, 1); % 15

%Indice para determinar qual atributo original (caracteristica) est� sendo
%processado agora
indiceAtributoAtual = 1;

%Vetor com os indices das colunas que representam a aus�ncia de informacao para
% um atributo original (caracterisitica)
colunasAusentes = [];

%Matriz final apos o pr�-processamento
dadosPreprocessados = [];

%% Age
[indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica] = ...
    agregarAtributoNumerico(indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.age);

%% Workclass
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.workclass);

%% Fnlwgt
[indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica] = ...
    agregarAtributoNumerico(indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.fnlwgt);

%% Education
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.education);

%% Education_num
[indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica] = ...
    agregarAtributoNumerico(indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.education_num);

%% Marital Status
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.marital_status);

%% Ocupation
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.occupation);

%% Relationship
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.relationship);

%% Race
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.race);

%% Sex
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.sex);

%% Capital_gain
[indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica] = ...
    agregarAtributoNumerico(indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.capital_gain);

%% Capital_loss
[indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica] = ...
    agregarAtributoNumerico(indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.capital_loss);

%% Native_country
[indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, ~] = ...
    agregarAtributosBinarios(indiceAtributoAtual, colunasAusentes, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.native_country);

%% Hours_per_week
[~, dadosPreprocessados, tamanhoCaracteristica] = ...
    agregarAtributoNumerico(indiceAtributoAtual, dadosPreprocessados, tamanhoCaracteristica, dadosOriginaisAgrupados.hours_per_week);

%% Rotulos
rotulos = zeros(size(dadosOriginaisAgrupados, 1), 1);

indices = cellfun(@(x) strcmpi(x, '>50k') | strcmpi(x, '>50k.'), dadosOriginaisAgrupados.target);

rotulos(indices) = 1;

end

