function results_summary = Benchmark_Optimizers(furnace_model, constraints, N, n_runs)
    % Benchmark PGD and fmincon optimizers over multiple runs
    %
    % Returns a struct with aggregated results for each optimizer.

    rng(42); % for reproducibility

    optimizers = {'PGD', 'FMINCON'};
    results_summary = struct();

    for opt_id = 1:length(optimizers)
        optimizer_name = optimizers{opt_id};
        fprintf('\n=== Running %s Benchmark (%d runs) ===\n', optimizer_name, n_runs);

        % Preallocate arrays
        final_costs = zeros(n_runs, 1);
        runtimes = zeros(n_runs, 1);
        all_J_hist = cell(n_runs, 1);
        all_time_log = cell(n_runs, 1);

        for i = 1:n_runs
            % Generate random initial guess (or use a baseline)
            T_init = furnace_model.settings.T_min + ...
                     rand(1, N) .* (furnace_model.settings.T_max - furnace_model.settings.T_min);
            t_init = furnace_model.settings.t_min + ...
                     rand * (furnace_model.settings.t_max - furnace_model.settings.t_min);
            initial_guess = [T_init, t_init];

            % Call optimizer
            if strcmpi(optimizer_name, 'PGD')
                [~, ~, J_hist, ~, time_log] = PGD_Optimizer(furnace_model, constraints, initial_guess, N);
            else
                [~, ~, J_hist, ~, time_log] = fmincon_Optimizer(furnace_model, constraints, initial_guess, N);
            end

            % Record
            final_costs(i) = J_hist(end);
            runtimes(i) = time_log(end);
            all_J_hist{i} = J_hist;
            all_time_log{i} = time_log;

            fprintf('Run %2d | Final Cost: %.4f | Runtime: %.2fs\n', i, J_hist(end), time_log(end));
        end

        % Store summary
        results_summary.(optimizer_name).final_costs = final_costs;
        results_summary.(optimizer_name).runtimes = runtimes;
        results_summary.(optimizer_name).all_J_hist = all_J_hist;
        results_summary.(optimizer_name).all_time_log = all_time_log;
    end
end
