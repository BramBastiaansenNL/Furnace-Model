function Check_Power_Gradient(x0, furnace_model, time_indices, plot_relative_errors, epsilon)
    %% Checks dP/dx

    tolerance = 1e-5; % Set threshold for reporting discrepancies

    % Forward and backward perturbations
    x_forward = x0;
    x_backward = x0;
    x_forward(1) = x0(1) + epsilon;
    x_backward(1) = x0(1) - epsilon;

    % Run simulations once
    result_forward = Get_Or_Run_Simulation(x_forward, furnace_model);
    result_backward = Get_Or_Run_Simulation(x_backward, furnace_model);
    furnace_model.settings.symbolic_differentiation = true;
    result_base = Get_Or_Run_Simulation(x0, furnace_model);

    % Storage for errors and gradients
    n_timesteps = length(time_indices);
    dP_dx_numeric_series = zeros(n_timesteps, 1);
    dP_dx_analytic_series = zeros(n_timesteps, 1);
    rel_errors = zeros(n_timesteps, 1);
    abs_errors = zeros(n_timesteps, 1);

    for idx = 1:n_timesteps-1
        k = idx;

        % Numerical derivative (central difference)
        P_fwd = result_forward.Power_curve(k);
        P_bwd = result_backward.Power_curve(k);
        dP_dx_numeric = (P_fwd - P_bwd) / (2 * epsilon);

        % Analytical derivative
        dP_dx_analytic = result_base.derivatives.dP_dx_series{k};

        % Store
        dP_dx_numeric_series(idx) = dP_dx_numeric;
        dP_dx_analytic_series(idx) = dP_dx_analytic(1);

        % Error metrics
        abs_diff = norm(dP_dx_analytic - dP_dx_numeric);
        rel_error = abs_diff / max(norm(dP_dx_numeric), 1e-8);

        abs_errors(idx) = abs_diff;
        rel_errors(idx) = rel_error;

        % Print discrepancies
        if ~plot_relative_errors && abs_diff > tolerance
            fprintf("\n====== Power Gradient Discrepancy at Time Index %d ======\n", k);
            fprintf("Numerical dP/dx:\n"); disp(dP_dx_numeric);
            fprintf("Analytical dP/dx:\n"); disp(dP_dx_analytic);
            fprintf("Absolute Difference: %.3e\n", abs_diff);
            fprintf("Relative Error: %.3e\n", rel_error);
            user_input = input('Continue comparing? Y/N [Y]: ', 's');
            if strcmpi(user_input, 'n')
                error('Comparison complete. Stopping simulation.');
            end
        end
    end

    % Plotting mode
    if plot_relative_errors
        % Relative error plot
        figure;
        plot(time_indices, rel_errors, '-o', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('Relative Error in dP/dx');
        title('Relative Error Between Analytical and Numerical dP/dx');
        grid on;

        % Gradient comparison plot
        figure;
        plot(time_indices, dP_dx_numeric_series, 'b-o', 'DisplayName', 'Numerical dP/dx', 'LineWidth', 1.5); hold on;
        plot(time_indices, dP_dx_analytic_series, 'r--s', 'DisplayName', 'Analytical dP/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dP/dx');
        title('Comparison of Analytical vs Numerical dP/dx Over Time');
        legend('Location', 'best');
        grid on;
    end
end
