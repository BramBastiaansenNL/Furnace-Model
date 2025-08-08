function [T_f, T_a, T_ms, T_h] = Damped_Update(T_f_prev, T_a_prev, T_ms_prev, T_h_prev, ...
                                          F, dT, fm, ...
                                          T_w, T_f_old, T_a_old, T_ms_old, T_h_old, ...
                                          dt, m_fCp_f, m_aCp_a, m_msCp_ms, m_hCp_h, Q_power)
    % Performs damped Newton-raphson update on temperatures

    reduction_factor = 0.5;
    min_alpha = 1e-4;
    alpha = 1;
    
    while true
        T_f_temp = T_f_prev + alpha * dT(1);
        T_a_temp = T_a_prev + alpha * dT(2);
        T_ms_temp = T_ms_prev + alpha * dT(3);
        T_h_temp = T_h_prev + alpha * dT(4);

        % Compute new heat transfers
        [Q_f_w_temp, Q_f_alloy_temp, Q_h_ms_temp, Q_ms_f_temp, Q_h_f_temp, Q_h_w_temp] = ...
            Compute_Heat_Transfers(T_w, T_f_temp, T_a_temp, T_ms_temp, T_h_temp, fm);

        % New residuals
        F1_temp = T_f_temp - T_f_old - dt/m_fCp_f * (Q_h_f_temp + 2*Q_ms_f_temp - Q_f_w_temp - Q_f_alloy_temp);
        F2_temp = T_a_temp - T_a_old - dt/m_aCp_a * (Q_f_alloy_temp);
        F3_temp = T_ms_temp - T_ms_old - dt/m_msCp_ms * (Q_h_ms_temp - Q_ms_f_temp);
        F4_temp = T_h_temp - T_h_old - dt/m_hCp_h * (Q_power - Q_h_f_temp - Q_h_ms_temp - Q_h_w_temp);
        F_temp = [-F1_temp; -F2_temp; -F3_temp; -F4_temp];
        new_residual = norm(F_temp);
        old_residual = (1 - 1e-4 * alpha) * norm(F);

        % Check if new residual norm is smaller (sufficient decrease)
        if new_residual < old_residual
            % Accept step
            T_f = T_f_temp;
            T_a = T_a_temp;
            T_ms = T_ms_temp;
            T_h = T_h_temp;
            break;
        else
            alpha = alpha * reduction_factor;
            if alpha < min_alpha
                % warning('Alpha too small, accepting step anyway');
                T_f = T_f_temp;
                T_a = T_a_temp;
                T_ms = T_ms_temp;
                T_h = T_h_temp;
                break;
            end
        end
    end
end
