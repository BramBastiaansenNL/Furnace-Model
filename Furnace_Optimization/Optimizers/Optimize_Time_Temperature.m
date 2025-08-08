function [T_f_opt, t_opt, J_opt, results] = ...
    Optimize_Time_Temperature(furnace_model, constraints, initial_guess, N)
    % Function that determines the optimization solver
    
    % Update with the correct number of temperature nodes
    furnace_model.model.N = N;

    if strcmpi(furnace_model.settings.optimizer, 'projected gradient descent')
        [T_f_opt, t_opt, J_opt, results] = PGD_Optimizer(furnace_model, constraints, initial_guess, N);

    elseif strcmpi(furnace_model.settings.optimizer, 'fmincon')
        [T_f_opt, t_opt, J_opt, results] = fmincon_Optimizer(furnace_model, constraints, initial_guess, N);

    elseif strcmpi(furnace_model.settings.optimizer, 'comparison')
        Compare_Optimizers(furnace_model, constraints, initial_guess, N);

    else
        error('Invalid method. Use "fmincon", "projected gradient descent" or "comparison".');
    end
end