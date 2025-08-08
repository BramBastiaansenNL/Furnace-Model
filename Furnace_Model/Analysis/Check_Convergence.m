function converged = Check_Convergence(residual_norm, dT_w, tol)
    % Checks if Newton Raphson has converged

    if residual_norm < tol && norm(dT_w(:)) < tol
        converged = true;
    else
        converged = false;
    end
end
