function stop = Print_Optimization_Steps(x, optimValues, state)
    %% OutputFcn for fmincon that prints T_f and t values in a table each iteration

    persistent J_hist best_x best_fval best_iter best_constrviolation

    stop = false;  % never stop optimization from here
    feasibility_tol = 1e-6;  % Acceptable tolerance for constraints

    switch state
        case 'init'
            J_hist = [];
            best_x = x;
            best_fval = optimValues.fval;
            best_iter = optimValues.iteration;
            best_constrviolation = optimValues.constrviolation;

        case 'iter'
            n = floor(numel(x)/2);
            T_f = x(1:n);
            t = x(n+1:end);
            total_time = sum(t);

            tf_str = sprintf('%.1f°C ', T_f);
            t_str  = sprintf('%.1fs ', t);

            fprintf('T_f: [%s] | t: [%s] | sum(t): %.2fs\n', ...
                tf_str, t_str, total_time);

            %% Update history
            J_hist(end+1) = optimValues.fval;

            %% Check for feasible improvement
            is_feasible = optimValues.constrviolation <= feasibility_tol;
            best_is_feasible = best_constrviolation <= feasibility_tol;

            if is_feasible
                if (~best_is_feasible) || (optimValues.fval < best_fval)
                    percent_improvement = 100 * (best_fval - optimValues.fval) / abs(best_fval + eps);
                    best_x = x;
                    best_fval = optimValues.fval;
                    best_iter = optimValues.iteration;
                    best_constrviolation = optimValues.constrviolation;

                    timestamp = datetime('now');
                    save('Current_Optimization_Solution.mat', 'best_x', 'best_fval', 'best_iter', 'timestamp');

                    fprintf('[Iteration %3d] fval: %.6f | Feasible solution saved! (%.2f%% improvement)\n\n', ...
                        optimValues.iteration, optimValues.fval, percent_improvement);
                else
                    fprintf('[Iteration %3d] fval: %.6f | Feasible, but not better.\n\n', ...
                        optimValues.iteration, optimValues.fval);
                end
            else
                fprintf('[Iteration %3d] fval: %.6f | Infeasible (constraint violation = %.2e)\n\n', ...
                    optimValues.iteration, optimValues.fval, optimValues.constrviolation);
            end
            
        case 'done'
            assignin('base', 'J_hist_fmincon', J_hist);  % Export to base workspace
            % Clear persistent variables
            clear J_hist best_x best_fval best_iter best_constrviolation
    end
end