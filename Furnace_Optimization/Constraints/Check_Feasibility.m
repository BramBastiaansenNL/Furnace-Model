function is_feasible = Check_Feasibility(x, constraints, furnace_model)
    % Checks if the solution x = [T_f, t] satisfies all mechanical constraints
    
    % Determine dimension
    N = numel(x) / 2;

    % Get constraint violations
    [c, ~] = Get_Constraints(x, furnace_model, constraints, N);

    % Feasible if all inequality constraints are satisfied
    is_feasible = all(c <= 0);
end
