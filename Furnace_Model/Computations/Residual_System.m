function [F, T_w, fm] = Residual_System(T_f, T_a, T_ms, T_h, ...
                                    T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, Q_power, fm, k)
    %% Computes the residual system for Matlab's fsolve function solver
    
    % Variables and parameters
    dt = fm.model.dt;
    constants = fm.constants;
    
    % Wall update using the current guess
    if strcmpi(fm.discretization_method, 'FVM')
        [T_w, fm] = FVM_Wall_Solver(T_w_old, T_f, T_h, fm, k);
    elseif strcmpi(fm.discretization_method, 'FEM')
        [T_w, fm] = FEM_Wall_Solver(T_w_old, T_f, T_h, fm, k);
    else
        [T_w, fm] = Constant_Wall_Temperature(T_w_old, fm, k);
    end
    
    % Heat transfers
    [Q_f_w, Q_f_alloy, Q_h_ms, Q_ms_f, Q_h_f, Q_h_w] = ...
        Compute_Heat_Transfers(T_w(:,1), T_f, T_a, T_ms, T_h, fm, T_w_old(:,1));
    
    % Residuals
    F1 = T_f - T_f_old - dt/constants.m_fCp_f * (Q_h_f + 2 * Q_ms_f - Q_f_w - Q_f_alloy);
    F2 = T_a - T_a_old - dt/constants.m_aCp_a * (Q_f_alloy);
    F3 = T_ms - T_ms_old - dt/constants.m_msCp_ms * (Q_h_ms - 2 * Q_ms_f);
    F4 = T_h - T_h_old - dt/constants.m_hCp_h * (Q_power - Q_h_ms - Q_h_w - Q_h_f);
    F = [F1; F2; F3; F4];

    % If only one output is requested (as in fsolve), exit here
    if nargout == 1
        return;
    end
end
