function Check_dT_w1_dx_proper(x0, furnace_model, time_indices, plot_relative_errors, epsilon, wall, node)
    %% Checks dTw1_dx

    tolerance = 1e-5; % Set threshold for reporting discrepancies

    % Forward and backward perturbations
    x_forward = x0;
    x_backward = x0;
    x_forward(1) = x0(1) + epsilon;
    x_backward(1) = x0(1) - epsilon;

    % Run simulations once
    furnace_model.settings.symbolic_differentiation = true;
    result_base = Get_Or_Run_Simulation(x0, furnace_model);
    furnace_model.settings.symbolic_differentiation = false;
    result_forward = Get_Or_Run_Simulation(x_forward, furnace_model);
    result_backward = Get_Or_Run_Simulation(x_backward, furnace_model);

    % Storage for errors
    n_timesteps = length(time_indices);
    dT_w1_dx_numeric_series = zeros(n_timesteps, 1);
    dT_w1_dx_analytic_series = zeros(n_timesteps, 1);
    rel_errors = zeros(n_timesteps, 1);
    abs_errors = zeros(n_timesteps, 1);

    for idx = 1:length(time_indices)
        k = idx;

        % Extract full temperature vectors
        T_w1_fwd = [result_forward.T_w_curve(:, node, k)];
        T_w1_bwd = [result_backward.T_w_curve(:, node, k)];
        dT_w1_dx_numeric = (T_w1_fwd - T_w1_bwd) / (2 * epsilon);

        % Analytical derivative
        if node == 1
            dT_w1_dx_analytic = result_base.derivatives.dT_w1_dx_series{k};
        else
            dT_w1_dx_analytic = result_base.derivatives.dT_w_dx_series{k, wall}(node);
        end

        % Store values (assuming scalar dT_h/dx)
        dT_w1_dx_numeric_series(idx) = dT_w1_dx_numeric(wall);
        dT_w1_dx_analytic_series(idx) = dT_w1_dx_analytic(wall, 1);

        % Error metrics
        abs_diff = norm(dT_w1_dx_analytic - dT_w1_dx_numeric);
        rel_error = abs_diff / max(norm(dT_w1_dx_numeric), 1e-8);

        rel_errors(idx) = rel_error;
        abs_errors(idx) = abs_diff;

        % Print only if error exceeds tolerance
        if ~plot_relative_errors && abs_diff > tolerance
            fprintf("\n====== Temperature Gradient Discrepancy at Time Index %d ======\n", k);
            fprintf("Numerical dT_w1/dx:\n"); disp(dT_w1_dx_numeric);
            fprintf("Analytical dT_w1/dx:\n"); disp(dT_w1_dx_analytic);
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
        ylabel('Relative Error in dT_w1/dx');
        title('Relative Error Between Analytical and Numerical dT_w1/dx');
        grid on;

        % Plotting the gradient
        figure;
        plot(time_indices, dT_w1_dx_numeric_series, 'b-o', 'DisplayName', 'Numerical dT_w1/dx', 'LineWidth', 1.5); hold on;
        plot(time_indices, dT_w1_dx_analytic_series, 'r--s', 'DisplayName', 'Analytical dT_w1/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_h/dx');
        title('Comparison of Analytical vs Numerical dT_w1/dx Over Time');
        legend('Location', 'best');
        grid on;
    end
end
