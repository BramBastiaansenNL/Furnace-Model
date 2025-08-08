function [P_input, integral_error, prev_error, fm] = ...
    Compute_Power_Supply(T_f_desired, T_f, prev_integral_error, prev_error, dt, fm, k)
    %% Compute power supply using a PID controller

    % Controller Gains (we tune these values as needed)
    controller = fm.controller;
    Kp = controller.Kp;        % Proportional gain
    Ki = controller.Ki;          % Integral gain
    Kd = controller.Kd;          % Derivative gain
    n_heaters = controller.n_heaters;

    % Update errors
    error = T_f_desired - T_f;
    derivative_error = (error - prev_error) / dt;  % NEEDS CHANGING MAYBE!
        
    % Compute power input using PID
    P_unsaturated = Kp * error + Ki * prev_integral_error + Kd * derivative_error;
    
    % Ensure power input is non-negative and apply saturation limits
    if (P_unsaturated >= controller.P_max) || (P_unsaturated <= 0)
        fm.controller.power_saturated = true;
        integral_error = prev_integral_error;
    else
        fm.controller.power_saturated = false;
        integral_error = prev_integral_error + error * dt;
    end
    fm.controller.power_saturated_series{k} = double(fm.controller.power_saturated);
    P_input = min(max(0, P_unsaturated), controller.P_max); 

    % % Anti-windup: Only integrate if not saturated OR if error is driving P_input back into range
    % if (P_input > 0 && P_input < controller.P_max) || (P_input == 0 && error > 0) || (P_input == controller.P_max && error < 0)
    %     integral_error = prev_integral_error + error * dt;
    % else
    %     integral_error = prev_integral_error;
    % end

    % Store previous error for next iteration
    prev_error = error;

    % Divide the power evenly among the number of heating elements (20)
    P_input = P_input / n_heaters; 
end