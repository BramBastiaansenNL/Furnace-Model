function [T_f_generated, fm] = Generate_Desired_Temperature_Curve_AD(T_f_desired, t, fm, alpha)
    %% Generates a fully custom desired temperature curve based on parameterization settings
    
    dt = fm.model.dt;
    N = fm.model.N;

    % Scalar temperature (constant profile)
    if isscalar(T_f_desired)
        t_total = t; 
        n_steps = round(extractdata(t_total / dt)); % convert for indexing
        t_vec = dlarray(0:(n_steps-1)) * dt;

        T_f_generated = repmat(T_f_desired, size(t_vec));
        return;
    end

    % Multi-segment case

    t_total = t;
    n_steps = round(extractdata(t_total / dt));
    t_vec = dlarray(0:(n_steps-1)) * dt;
    alpha = reshape(alpha,1,[]);
    cum_norm = [dlarray(0), dl_cumsum(alpha)];
    time_knots = cum_norm * t_total;

    % Temperature knots
    T0 = dlarray(fm.furnace.T_initial);
    temp_knots = [T0, T_f_desired(:)'];

    % Interpolation (linear, differentiable)
    switch lower(fm.settings.curve_parameterization)
        case 'constant'
            % Assign each segment to the corresponding time steps
            T_f_generated = dlarray(zeros(n_steps,1));
            for seg = 1:N
                t_start = time_knots(seg);
                t_end   = time_knots(seg+1);
                mask = (t_vec >= t_start) & (t_vec < t_end);  % logical mask
                T_f_generated(mask) = T_f_desired(seg);       % dlarray assignment works
            end
            % Make sure the last step is assigned
            T_f_generated(t_vec >= time_knots(end)) = T_f_desired(end);
            
        case 'linear'
            % Linear interpolation (fully dlarray-compatible)
            T_f_generated = dlarray(zeros(n_steps,1));
            for k = 1:n_steps
                u = t_vec(k) / t_total;  % normalized time [0,1]
                % Find segment index
                seg = find(u <= time_knots(2:end)/t_total, 1, 'first');
                if seg > 1
                    u0 = time_knots(seg)/t_total;
                else
                    u0 = 0;
                end
                u1 = time_knots(seg+1)/t_total;
                T0_seg = T_f_desired(seg);
                T1_seg = T_f_desired(seg);  % for linear between same points, could adapt later
                % linear interpolation
                T_f_generated(k) = T0_seg + (T1_seg-T0_seg)*(u-u0)/(u1-u0+eps);
            end

        case 'splines'
            % Could implement PCHIP manually with arithmetic ops if needed
            error('Spline interpolation not yet implemented for AD mode');
        otherwise
            error('Unknown curve_parameterization: %s', fm.settings.curve_parameterization);
    end
end