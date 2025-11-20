function J = Optimize_Time_Temperature_Wrapper(x, fm, constraints, N)
    %% Wrapper for the time-temperature optimization routine

    try
        [~, ~, J_hist, ~] = Optimize_Time_Temperature(fm, constraints, x, N);
        J = J_hist(end);
    catch
        J = 1e6; % Penalize failed runs
    end
end
