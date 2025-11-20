function stop = Track_Best_Solution(x, optimValues, state)
    %% Custom OutputFcn for fmincon that tracks the best solution

    persistent best_x best_fval best_iter fval_history iter_history

    stop = false;

    switch state
        case 'init'
            % Initialize persistent variables
            best_x = x;
            best_fval = optimValues.fval;
            best_iter = optimValues.iteration;

            fval_history = optimValues.fval;
            iter_history = optimValues.iteration;

        case 'iter'
            % Track convergence history
            fval_history(end+1) = optimValues.fval;
            iter_history(end+1) = optimValues.iteration;

            % Update best values
            if optimValues.fval < best_fval
                percent_improvement = 100 * (best_fval - optimValues.fval) / abs(best_fval);
                best_x = x;
                best_fval = optimValues.fval;
                best_iter = optimValues.iteration;

                % Save to file
                timestamp = datetime('now');
                save('Current_Best_Solution.mat', 'best_x', 'best_fval', 'best_iter', 'timestamp');
                
                improvement_note = sprintf(' [Improved by %.2f%%]', percent_improvement);
            else
                improvement_note = '';
            end

            % Display progress
            fprintf('[Iteration %3d] fval: %.6f | Best: %.6f (iter %d)%s\n', ...
                optimValues.iteration, optimValues.fval, best_fval, best_iter, improvement_note);

        case 'done'
            % Final summary
            fprintf('\n========= Optimization Complete =========\n');
            fprintf('Best fval: %.6f found at iteration %d\n', best_fval, best_iter);

            % Try displaying labeled parameters
            try
                fm = evalin('base', 'fm');  % get fm from base workspace
                param_labels = fm.param_subset;

                fprintf('\nOptimal parameters:\n');
                for i = 1:length(param_labels)
                    fprintf('  %s = %.6f\n', param_labels{i}, best_x(i));
                end
            catch
                fprintf('\n[Warning] Could not access fm.param_subset — displaying raw values:\n');
                disp(best_x);
            end

            % Optional: plot convergence
            if exist('fval_history', 'var') && ~isempty(fval_history)
                figure;
                semilogy(iter_history, fval_history, '-o', 'LineWidth', 2);
                xlabel('Iteration');
                ylabel('Objective Function Value (log scale)');
                title('Convergence History');
                grid on;
            end
            
            fprintf('Saved best result to: Current_Best_Solution.mat\n');
            fprintf('=========================================\n');

            % Clear persistent data (optional if rerunning)
            clear best_x best_fval best_iter fval_history iter_history
    end
end
