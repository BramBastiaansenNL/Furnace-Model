function dP_dx = Assemble_Derivatives(dP_dx, fm, N)
    %% Assembles local [1x1] derivatives into full [1x2N] vector
    
    % Sum all dP_dx_series{k} from the i-th simulation
    dP_dx(N) = dP_dx(N) + sum(cell2mat(fm.derivatives.dP_dx_series(2:end)));
end
