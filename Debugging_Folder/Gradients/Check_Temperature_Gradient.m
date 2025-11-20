function Check_Temperature_Gradient(x0, furnace_model, time_indices, plot_relative_errors, epsilon)
    %% Checks dT_dx accuracy: numerical vs. analytical

    tolerance = 1e-5; % Set your threshold for reporting discrepancies

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
    n_steps = length(time_indices);
    abs_errors = zeros(n_steps, 1);
    rel_errors = zeros(n_steps, 1);

    % Preallocate per-variable gradients
    dT_f_numeric = zeros(n_steps, 1);
    dT_f_analytic = zeros(n_steps, 1);
    dT_m_numeric = zeros(n_steps, 1);
    dT_m_analytic = zeros(n_steps, 1);
    dT_ms_numeric = zeros(n_steps, 1);
    dT_ms_analytic = zeros(n_steps, 1);
    dT_h_numeric = zeros(n_steps, 1);
    dT_h_analytic = zeros(n_steps, 1);

    for idx = 1:length(time_indices)
        k = time_indices(idx);

        % Extract full temperature vectors
        T_fwd = [result_forward.T_f_curve(k);
                 result_forward.T_m_curve(k);
                 result_forward.T_ms_curve(k);
                 result_forward.T_h_curve(k)];

        T_bwd = [result_backward.T_f_curve(k);
                 result_backward.T_m_curve(k);
                 result_backward.T_ms_curve(k);
                 result_backward.T_h_curve(k)];

        % Central difference numerical derivative
        dT_dx_numeric = (T_fwd - T_bwd) / (2 * epsilon);

        % Analytical derivative
        dT_dx_analytic = result_base.derivatives.dT_dx_series{k};

        % Store per-variable
        dT_f_numeric(idx) = dT_dx_numeric(1);
        dT_f_analytic(idx) = dT_dx_analytic(1);

        dT_m_numeric(idx) = dT_dx_numeric(2);
        dT_m_analytic(idx) = dT_dx_analytic(2);

        dT_ms_numeric(idx) = dT_dx_numeric(3);
        dT_ms_analytic(idx) = dT_dx_analytic(3);

        dT_h_numeric(idx) = dT_dx_numeric(4);
        dT_h_analytic(idx) = dT_dx_analytic(4);

        % Error metrics
        abs_diff = norm(dT_dx_analytic - dT_dx_numeric);
        rel_error = abs_diff / max(norm(dT_dx_numeric), 1e-8);

        rel_errors(idx) = rel_error;
        abs_errors(idx) = abs_diff;

        % Print only if error exceeds tolerance
        if ~plot_relative_errors && abs_diff > tolerance
            fprintf("\n====== Temperature Gradient Discrepancy at Time Index %d ======\n", k);
            fprintf("Numerical dT/dx:\n"); disp(dT_dx_numeric);
            fprintf("Analytical dT/dx:\n"); disp(dT_dx_analytic);
            fprintf("Absolute Difference: %.3e\n", abs_diff);
            fprintf("Relative Error:\n"); disp(rel_error);
            user_input = input('Continue comparing? Y/N [Y]: ', 's');
            if strcmpi(user_input, 'n')
                error('Comparison complete. Stopping simulation.');
            end
        end
    end

    % Plotting mode
    if plot_relative_errors
        % Relative error over time
        figure;
        plot(time_indices, rel_errors, '-o', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('Relative Error in dT/dx');
        title('Relative Error Between Analytical and Numerical dT/dx');
        grid on;

        % Plot dT_f/dx
        figure;
        plot(time_indices, dT_f_numeric, 'b-o', 'DisplayName', 'Numerical dT_f/dx', 'LineWidth', 1.5); hold on;
        plot(time_indices, dT_f_analytic, 'r--s', 'DisplayName', 'Analytical dT_f/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_f/dx');
        title('Furnace Temperature Gradient Comparison');
        legend('Location', 'best');
        grid on;

        % Plot dT_m/dx
        figure;
        plot(time_indices, dT_m_numeric, 'b-o', 'DisplayName', 'Numerical dT_m/dx', 'LineWidth', 1.5); hold on;
        plot(time_indices, dT_m_analytic, 'r--s', 'DisplayName', 'Analytical dT_m/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_m/dx');
        title('Alloy Temperature Gradient Comparison');
        legend('Location', 'best');
        grid on;

        % Plot dT_ms/dx
        figure;
        plot(time_indices, dT_ms_numeric, 'b-o', 'DisplayName', 'Numerical dT_{ms}/dx', 'LineWidth', 1.5); hold on;
        plot(time_indices, dT_ms_analytic, 'r--s', 'DisplayName', 'Analytical dT_{ms}/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_{ms}/dx');
        title('Metal Sheet Temperature Gradient Comparison');
        legend('Location', 'best');
        grid on;

        % Plot dT_h/dx
        figure;
        plot(time_indices, dT_h_numeric, 'b-o', 'DisplayName', 'Numerical dT_{h}/dx', 'LineWidth', 1.5); hold on;
        plot(time_indices, dT_h_analytic, 'r--s', 'DisplayName', 'Analytical dT_{h}/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_{h}/dx');
        title('Heater Temperature Gradient Comparison');
        legend('Location', 'best');
        grid on;
    end
end
