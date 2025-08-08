function dT_f_desired_dx = ...
    Compute_Linear_T_f_desired_Derivatives(temp_knots, time_knots, t_vec, alpha, t_total, N)
    %% Computes dT_f^desired(t)/dx where x = [T_f_desired, alpha, t_total] for linear interpolation

    dT_dT = zeros(length(t_vec), N);        % dT/dT_i
    dT_dalpha = zeros(length(t_vec), N);    % dT/dalpha_i
    dT_dt_total = zeros(length(t_vec), 1);  % dT/dt_total

    for k = 1:length(t_vec)
        t_now = t_vec(k);

        % Find active segment i
        i = find(time_knots <= t_now, 1, 'last');
        if t_now == time_knots(i) && i > 1
            i = i - 1;  % Use left-hand segment at breakpoint
        end
        if i >= length(temp_knots)
            i = length(temp_knots) - 1;
        end

        % Segment info
        tL = time_knots(i);
        tR = time_knots(i+1);
        TL = temp_knots(i);
        TR = temp_knots(i+1);
        dt_seg = tR - tL;

        % Interpolation weights
        if dt_seg == 0
            wL = 1;
            wR = 0;
            dT_dtL = 0;
            dT_dtR = 0;
        else
            wL = (tR - t_now) / dt_seg;
            wR = (t_now - tL) / dt_seg;
            dT_dtL = ((tR - t_now)*(TL - TR)) / dt_seg^2;
            dT_dtR = ((t_now - tL)*(TL - TR)) / dt_seg^2;
        end

        % === Derivative w.r.t. T_f_desired ===
        if i > 1
            dT_dT(k, i-1) = wL;  % T_i
        end
        if i <= N
            dT_dT(k, i) = wR;    % T_{i+1}
        end

        % === Derivative w.r.t. alpha ===
        for j = 1:N
            % ∂tL/∂alpha_j
            if j < i
                dtL_dalpha = t_total;
            else
                dtL_dalpha = 0;
            end

            % ∂tR/∂alpha_j
            if j <= i
                dtR_dalpha = t_total;
            else
                dtR_dalpha = 0;
            end

            dT_dalpha(k, j) = dT_dtL * dtL_dalpha + dT_dtR * dtR_dalpha;
        end

        % === Derivative w.r.t. t_total ===
        dtL_dt_total = sum(alpha(1:i-1));
        dtR_dt_total = sum(alpha(1:i));
        dT_dt_total(k) = dT_dtL * dtL_dt_total + dT_dtR * dtR_dt_total;
    end

    % Combine all gradients into single matrix
    dT_f_desired_dx = [dT_dT, dT_dalpha, dT_dt_total];
end
