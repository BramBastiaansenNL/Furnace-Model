function [F, T_w_new, fm] = Residual_Wrapper(T, T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, Q_power, fm, k)
    %% Simplifies the call to fsolve for solving the residual system

    [F, T_w_new, fm] = Residual_System(T(1), T(2), T(3), T(4), ...
                                   T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                                   Q_power, fm, k);
end