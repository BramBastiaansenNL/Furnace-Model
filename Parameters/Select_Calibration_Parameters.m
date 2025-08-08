function subset_to_optimize = Select_Calibration_Parameters(parameter_list)
    %% Opens a selection dialog for choosing parameters to calibrate.
    % Returns a cell array of selected parameter names.
    % If the user cancels, returns default subset.
    
    % Default selection list
    default_selection = {
        'h_f_al'
        'h_ms_f'
        'h_f_w'
        'h_h_f'
        'h_out'
        'epsilon_ms'
        'epsilon_w'
    };
    
    % Map defaults to indices in param_list
    [~, default_idx] = ismember(default_selection, parameter_list);
    default_idx = default_idx(default_idx > 0);  % Filter out missing

    [selected_idx, ok] = listdlg( ...
        'PromptString', 'Select parameters to calibrate:', ...
        'SelectionMode', 'multiple', ...
        'ListString', parameter_list, ...
        'InitialValue', default_idx);

    if ok
        subset_to_optimize = parameter_list(selected_idx);
    else
        fprintf('No selection made. Using default parameters.\n');
        subset_to_optimize = default_selection;
    end
end
