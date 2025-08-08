function [fm, dP_dx] = Compute_dP_dx(fm, k, Kp, Kd, Ki, dt, n_heaters)
    %% Compute the derivative of power w.r.t. x, with saturation handling
    
    N = fm.model.N;
    
    % Check if power is saturated
    if fm.controller.power_saturated_series{k}
        dP_dx = zeros(1, 2*N+1);
        derror_dx = zeros(1, 2*N+1);
    else
        dT_f_desired_dx = fm.derivatives.dT_f_desired_dx(k, :);
        dT_f_dx = fm.derivatives.dT_dx_series{k}(1, :);
        derror_dx = dT_f_desired_dx - dT_f_dx;
        if k == 1
            dT_f_dx_prev = zeros(1, 2*N+1);
            dintegral_error_dx = zeros(1, 2*N+1);
        else
            dT_f_dx_prev = fm.derivatives.dT_dx_series{k-1}(1, :);
            dintegral_error_dx = sum(cell2mat(fm.derivatives.dintegral_error_dx(1:k-1, :)), 1);
        end
        dP_dx = 1/ n_heaters * (Kp * derror_dx + Ki * dt * dintegral_error_dx + ...
                Kd / dt * (derror_dx - (dT_f_desired_dx - dT_f_dx_prev)));
    end

    % Update and store
    fm.derivatives.dP_dx_series{k} = dP_dx;
    fm.derivatives.dintegral_error_dx{k} = derror_dx;
end