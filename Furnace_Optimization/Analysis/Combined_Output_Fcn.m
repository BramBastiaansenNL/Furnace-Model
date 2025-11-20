function stop = Combined_Output_Fcn(x, optimValues, state, userFcn)
    %% Nested function for combined behavior

    stop = false;
    % Call user’s output function (prints progress)
    if ~isempty(userFcn)
        stop_user = userFcn(x, optimValues, state);
        if stop_user
            stop = true;
        end
    end
    % Log elapsed time
    switch state
        case 'init'
            time_log = 0;
        case 'iter'
            time_log(end+1) = toc(start_time);
    end
end