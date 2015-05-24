function [J, grad] = RNA_costFunction(theta, X, y, lambda)
    m = size(X, 1);
    J = 0;
    for i=1:m
        x = X(1,:);
        [saida, A1, A2, A3] = redeNeuralClassificar(x, theta);
        J = J + y(i)*log(saida) + (1-y(i))*log(1-saida);
        d4 = y-A3;
    end
    reg = lambda / (2 * m) * sum(theta(2:attSize).^2);
    J = (-1/m)*J + reg;
    grad = zeros(size(theta));
end