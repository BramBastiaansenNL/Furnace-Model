function Display_Optimal_Results(fm, optimal_parameters, optimal_loss, ...
                                 p_guess, calibration_algorithm, param_subset)
%%  Display summary of optimization results

    fprintf('\n==================== Optimization Summary ====================\n');
    
    % Calibration algorithm
    if exist('calibration_algorithm', 'var') && ~isempty(calibration_algorithm)
        fprintf('Calibration Algorithm: %s\n', calibration_algorithm);
    end
    
    % Optimal loss
    if exist('optimal_loss', 'var')
        fprintf('Final Loss Value: %.6e\n', optimal_loss);
    end
    
    if ischar(param_subset) && strcmpi(param_subset, 'all')
        % Print all current parameters and their default values
        param_info = Get_Calibration_Parameter_Info();
        param_map  = containers.Map(param_info(:,1), param_info(:,2));
        fields = fieldnames(fm.default_values);
        fprintf('\nAll Calibratable Parameters (current fm values):\n');
        for i = 1:numel(fields)
            name = fields{i};

            % try to look up in fm via nested path
            if param_map.isKey(name)
                fpath = param_map(name);
                parts = split(fpath, '.');
                try
                    switch numel(parts)
                        case 2
                            val = fm.(parts{1}).(parts{2});
                        case 3
                            val = fm.(parts{1}).(parts{2}).(parts{3});
                        otherwise
                            warning('Unsupported path depth for "%s".', name);
                    end
                catch
                    warning('Could not read fm.%s; using default.', fpath);
                end
            else
                warning('No mapping found for parameter "%s"; using default.', name);
            end

            fprintf('  %s = %.6f\n', name, val);
        end

    else
        % Parameters
        fprintf('\nOptimal Parameters:\n');
        for i = 1:length(param_subset)
            fprintf('  %s = %.6f', param_subset{i}, optimal_parameters(i));
            if exist('p_guess', 'var') && length(p_guess) >= i
                fprintf('   (Initial: %.6f)', p_guess(i));
            end
            fprintf('\n');
        end
    end
    
    fprintf('==============================================================\n\n');
end
