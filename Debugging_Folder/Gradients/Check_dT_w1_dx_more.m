function Check_dT_w1_dx_more(x0, furnace_model, time_indices, plot_relative_errors, epsilon)
    %% Checks dTw1_dx

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
    dT_w1_dx_numeric_series = zeros(n_timesteps, 1);
    dT_w1_dx_analytic_series = zeros(n_timesteps, 1);
    rel_errors = zeros(n_timesteps, 1);
    abs_errors = zeros(n_timesteps, 1);
    gA_err_series = zeros(n_timesteps, 1);
    gB_err_series = zeros(n_timesteps, 1);
    gB1_err_series = zeros(n_timesteps, 1);
    gB2_err_series = zeros(n_timesteps, 1);
    gB3_err_series = zeros(n_timesteps, 1);
    gB4_err_series = zeros(n_timesteps, 1);
    full_grad_series = zeros(n_timesteps, 1);
    gA_series = zeros(n_timesteps, 1);
    gB_series = zeros(n_timesteps, 1);
    gB1_series = zeros(n_timesteps, 1);
    gB2_series = zeros(n_timesteps, 1);
    gB3_series = zeros(n_timesteps, 1);
    gB4_series = zeros(n_timesteps, 1);

    for idx = 1:length(time_indices)
        k = time_indices(idx);

        % Extract full temperature vectors
        T_w1_fwd = [result_forward.T_w_curve(:, 1, k)];
        T_w1_bwd = [result_backward.T_w_curve(:, 1, k)];
        dT_w1_dx_numeric = (T_w1_fwd - T_w1_bwd) / (2 * epsilon);

        % Analytical derivative
        dT_w1_dx_analytic = result_base.derivatives.dT_w1_dx_series{k};

        % Store values (assuming scalar dT_h/dx)
        dT_w1_dx_numeric_series(idx) = dT_w1_dx_numeric(1);
        dT_w1_dx_analytic_series(idx) = dT_w1_dx_analytic(1);

        % Error metrics
        abs_diff = norm(dT_w1_dx_analytic - dT_w1_dx_numeric);
        rel_error = abs_diff / max(norm(dT_w1_dx_numeric), 1e-8);

        rel_errors(idx) = rel_error;
        abs_errors(idx) = abs_diff;

        % Additional error metrics
        gA = result_base.derivatives.gA_series{k};
        gB = result_base.derivatives.gB_series{k};
        full_grad_series(idx) = gA(1) + gB(1);
        gB1 = result_base.derivatives.gB1_series{k};
        gB2 = result_base.derivatives.gB2_series{k};
        gB3 = result_base.derivatives.gB3_series{k};
        gB4 = result_base.derivatives.gB4_series{k};

        err_gA    = norm(gA(1) - dT_w1_dx_numeric) / norm(dT_w1_dx_numeric);
        err_gB    = norm(gB(1) - dT_w1_dx_numeric) / norm(dT_w1_dx_numeric);
        err_gB1    = norm(gB1(1) - dT_w1_dx_numeric) / norm(dT_w1_dx_numeric);
        err_gB2    = norm(gB2(1) - dT_w1_dx_numeric) / norm(dT_w1_dx_numeric);
        err_gB3    = norm(gB3(1) - dT_w1_dx_numeric) / norm(dT_w1_dx_numeric);
        err_gB4    = norm(gB4(1) - dT_w1_dx_numeric) / norm(dT_w1_dx_numeric);

        gA_err_series(idx) = err_gA;
        gB_err_series(idx) = err_gB;
        gB1_err_series(idx) = err_gB1;
        gB2_err_series(idx) = err_gB2;
        gB3_err_series(idx) = err_gB3;
        gB4_err_series(idx) = err_gB4;

        gA_series(idx) = gA(1);
        gB_series(idx) = gB(1);
        gB1_series(idx) = gB1(1);
        gB2_series(idx) = gB2(1);
        gB3_series(idx) = gB3(1);
        gB4_series(idx) = gB4(1);

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
        plot(time_indices, full_grad_series, 'DisplayName', 'Analytical dT_w1/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_w1/dx');
        title('Comparison of Analytical vs Numerical dT_w1/dx Over Time');
        legend('Location', 'best');
        grid on;

        % Plotting err_gA and err_gB
        figure;
        plot(time_indices, gA_err_series, 'b-o', 'DisplayName', 'gA error', 'LineWidth', 1.5); hold on;
        plot(time_indices, gB_err_series, 'r--s', 'DisplayName', 'gB error', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_w1/dx');
        title('gA and gB error');
        legend('Location', 'best');
        grid on;

        % Plotting further breakdown of err_gB
        figure;
        plot(time_indices, gB1_err_series, 'b-o', 'DisplayName', 'gB1 error', 'LineWidth', 1.5); hold on;
        plot(time_indices, gB2_err_series, 'DisplayName', 'gB2 error', 'LineWidth', 1.5);
        plot(time_indices, gB3_err_series, 'DisplayName', 'gB3 error', 'LineWidth', 1.5);
        plot(time_indices, gB4_err_series, 'DisplayName', 'gB4 error', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_w1/dx');
        title('gB error');
        legend('Location', 'best');
        grid on;

        % Plotting further breakdown of err_gB
        figure;
        plot(time_indices, gA_series, 'DisplayName', 'gA ', 'LineWidth', 1.5);hold on;
        plot(time_indices, gB_series, 'DisplayName', 'gB ', 'LineWidth', 1.5);
        plot(time_indices, gB1_series, 'b-o', 'DisplayName', 'gB1', 'LineWidth', 1.5);
        plot(time_indices, gB2_series, 'DisplayName', 'gB2 ', 'LineWidth', 1.5);
        plot(time_indices, gB3_series, 'DisplayName', 'gB3 ', 'LineWidth', 1.5);
        plot(time_indices, gB4_series, 'DisplayName', 'gB4 ', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_w1/dx');
        title('gB error');
        legend('Location', 'best');
        grid on;

        % Sanity Check
        figure;
        plot(time_indices, gB1_series, 'b-o', 'DisplayName', 'gB1 error', 'LineWidth', 1.5); hold on;
        plot(time_indices, dT_w1_dx_numeric_series - (gA_series + gB2_series + gB3_series + gB4_series), 'r--s', 'DisplayName', 'Missing error if gB1 excluded', 'LineWidth', 1.5);
        plot(time_indices, dT_w1_dx_numeric_series, 'DisplayName', 'Numerical dT_w1/dx', 'LineWidth', 1.5);
        xlabel('Time Step Index');
        ylabel('dT_w1/dx');
        title('Missing error if gB1 excluded');
        legend('Location', 'best');
        grid on;
    end
end
