function stop = Save_Best_Particle(optimValues,state)
    %% OutputFcn for particleswarm to save best particle and print info
    %
    % Saves current best solution to file at each iteration.
    % Also prints current iteration, best f(x), and parameters.

    stop = false; % Do not stop optimization

    % Set file to save to:
    filename = 'Current_Best_Particle.mat';

    switch state
        case 'init'
            % Initialize (optional: clear file)
            if exist(filename, 'file')
                delete(filename);
            end

        case 'iter'
            % Save current best solution
            best_solution = optimValues.bestx;
            best_fval = optimValues.bestfval;
            iteration = optimValues.iteration;

            save(filename, 'best_solution', 'best_fval', 'iteration');

            % Print to console
            fprintf('SaveBestParticle: Iter %d, Best f(x) = %.6e\n', iteration, best_fval);
            fprintf('Best parameters:\n');
            disp(best_solution);

        case 'done'
            % Final save at end of optimization
            best_solution = optimValues.bestx;
            best_fval = optimValues.bestfval;
            iteration = optimValues.iteration;

            save(filename, 'best_solution', 'best_fval', 'iteration');

            fprintf('\nSaveBestParticle DONE: Iter %d, Best f(x) = %.6e\n', iteration, best_fval);
            fprintf('Final Best parameters:\n');
            disp(best_solution);

    end
end
