function x = Thomas_Solver(a, b, c, d)
    %% Thomas Algorithm for Tridiagonal System
    
    N = length(d);
    
    % Forward elimination
    for i = 2:N
        factor = a(i-1) / b(i-1);
        b(i) = b(i) - factor * c(i-1);
        d(i) = d(i) - factor * d(i-1);
    end
    
    % Back-substitution
    x = zeros(N,1);
    x(N) = d(N) / b(N);
    for i = N-1:-1:1
        x(i) = (d(i) - c(i) * x(i+1)) / b(i);
    end
end