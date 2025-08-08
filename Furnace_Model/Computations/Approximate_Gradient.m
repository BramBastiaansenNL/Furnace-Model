function g = Approximate_Gradient(f, x, h)
    % Approximates the gradient of f(x) using forward finite differences

    if nargin < 3
        h = 1e-4;
    end

    g = zeros(size(x));
    f0 = f(x);
    for i = 1:length(x)
        x1 = x;
        x1(i) = x1(i) + h;
        g(i) = (f(x1) - f0) / h;
    end
end
