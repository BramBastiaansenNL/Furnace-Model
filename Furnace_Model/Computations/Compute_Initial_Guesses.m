function [T_f, T_a, T_w, T_ms, T_h] = Compute_Initial_Guesses(T_f_old, T_a_old, T_w_old, T_ms_old, T_h_old, ...
                                                              T_f_older, T_a_older, T_w_older, T_ms_older, T_h_older)
    % Computes the initial guesses for Newton-Rephson by simple linear extrapolation of the previous temperatures

    if nargin < 6
        T_f = T_f_old;
        T_a = T_a_old;
        T_w = T_w_old;
        T_ms = T_ms_old;
        T_h = T_h_old;
    else
        % Linear extrapolation
        T_f = 2 * T_f_old - T_f_older;
        T_a = 2 * T_a_old - T_a_older;
        T_w = 2 * T_w_old - T_w_older;
        T_ms = 2 * T_ms_old - T_ms_older;
        T_h = 2 * T_h_old - T_h_older;
    end
end
