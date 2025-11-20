function Check_dT_h_dx_proper(x0, furnace_model, time_indices, plot_relative_errors, epsilon)
    %% Checks dT_dx

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

    % Storage for errors
    n_timesteps = length(time_indices);
    dT_dx_numeric_series = zeros(n_timesteps, 1);
    dT_dx_analytic_series = zeros(n_timesteps, 1);
    rel_errors = zeros(n_timesteps, 1);
    abs_errors = zeros(n_timesteps, 1);

    for idx = 1:length(time_indices)
        k = time_indices(idx);

        % Extract full temperature vectors
        T_fwd = [result_forward.T_h_curve(k)];
        T_bwd = [result_backward.T_h_curve(k)];
        dT_dx_numeric = (T_fwd - T_bwd) / (2 * epsilon);

        % Analytical derivative
        dT_dx_analytic = result_base.derivatives.dT_h_dx_series{k};

        % Store values (assuming scalar dT_h/dx)
        dT_dx_numeric_series(idx) = dT_dx_numeric;
        dT_dx_analytic_series(idx) = dT_dx_analytic;

        % Error metrics
        abs_diff = norm(dT_dx_analytic - dT_dx_numeric);
        rel_error = abs_diff / max(norm(dT_dx_numeric), 1e-8);

        rel_errors(idx) = rel_error;
        abs_errors(idx) = abs_diff;

        % Print only if error exceeds tolerance
        if ~plot_relative_errors && abs_diff > tolerance
            fprintf("\n====== Temperature Gradient Discrepancy at Time Index %d ======\n", k);
            fprintf("Numerical dT_h/dx:\n"); disp(dT_dx_numeric);
            fprintf("Analytical dT_h/dx:\n"); disp(dT_dx_analytic);
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
        % Plotting the relative errror
        figure;
        plot(time_indices, rel_errors, '-o', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('Relative Error in dT_h/dx');
        title('Relative Error Between Analytical and Numerical dT_h/dx');
        grid on;

        % Plotting the gradient
        figure;
        plot(time_indices, dT_dx_numeric_series, 'b-o', 'DisplayName', 'Numerical dT_h/dx', 'LineWidth', 1.5); hold on;
        plot(time_indices, dT_dx_analytic_series, 'r--s', 'DisplayName', 'Analytical dT_h/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_h/dx');
        title('Comparison of Analytical vs Numerical dT_h/dx Over Time');
        legend('Location', 'best');
        grid on;
    end
end
