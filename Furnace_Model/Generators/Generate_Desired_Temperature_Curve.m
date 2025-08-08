function [T_f_generated, fm] = Generate_Desired_Temperature_Curve(T_f_desired, t, fm, alpha)
    %% Generates a fully custom desired temperature curve based on parameterization settings
    
    dt = fm.model.dt;
    N = fm.model.N;

    % Case 1: Constant target temperature
    if isscalar(T_f_desired)
        if isscalar(t)
            t_total = t;
        else
            t_total = sum(t);
        end
        n_steps = round(t_total / dt);
        t_vec = (0:(n_steps-1)) * dt;
        T_f_generated = repmat(T_f_desired, size(t_vec));
        cum_norm = [0, cumsum(alpha)];  % Should sum ~1
        time_knots = cum_norm * t_total;
        if fm.settings.store_derivatives
            fm.derivatives.dT_f_desired_dx = Compute_Constant_T_f_desired_Derivatives( ...
                time_knots, t_vec, N);
        end
        return;
    end

    % Case 2: Multi-segment
    if isscalar(t)
        % Case 2a: Multi-segment with scalar t (parameterized by alpha)
        if nargin < 4 || isempty(alpha)
            error('Alpha must be supplied when using scalar t (parameterized mode).');
        end
        t_total = t;
        n_steps = round(t_total / dt);
        t_vec = (0:(n_steps-1)) * dt;

        cum_norm = [0, cumsum(alpha)];  % Should sum ~1
        time_knots = cum_norm * t_total;
    else
        % Case 2b: Multi-segment with explicit segment times (alpha ignored)
        t_total = sum(t);
        n_steps = round(t_total / dt);
        t_vec = (0:(n_steps-1)) * dt;

        time_knots = [0, cumsum(t)];
        if numel(time_knots) ~= numel(T_f_desired) + 1
            error('Mismatch between T_f_desired length and segment times.');
        end
    end

    % Build temperatures at knots: prepend initial
    T0 = fm.furnace.T_initial;
    temp_knots = [T0, T_f_desired(:)'];  % length N+1

    switch lower(fm.settings.curve_parameterization)
        case 'constant'
            % Stepwise constant: find segment index
            time_knots_unique = unique(time_knots, 'stable');
            idx = arrayfun(@(u) find(time_knots_unique<=u,1,'last'), t_vec);
            T_f_generated = T_f_desired(idx);
            if fm.settings.store_derivatives
                fm.derivatives.dT_f_desired_dx = Compute_Constant_T_f_desired_Derivatives( ...
                   time_knots_unique, t_vec, N);
            end

        case 'linear'
            % Linear interpolation
            [time_knots_unique, ia] = unique(time_knots, 'stable');
            temp_knots_unique = temp_knots(ia);
            T_f_generated = interp1(time_knots_unique, temp_knots_unique, t_vec, 'linear', 'extrap');
            if fm.settings.store_derivatives
                fm.derivatives.dT_f_desired_dx = Compute_Linear_T_f_desired_Derivatives( ...
                    temp_knots_unique, time_knots_unique, t_vec, alpha, t_total, N);
            end

        case 'splines'
            % Cubic spline interpolation
            [time_knots_unique, ia] = unique(time_knots, 'stable');
            temp_knots_unique = temp_knots(ia);
            T_f_generated = interp1(time_knots_unique, temp_knots_unique, t_vec, 'pchip', 'extrap');
            if fm.settings.store_derivatives
                fm.derivatives.dT_f_desired_dx = Compute_Spline_T_f_desired_Derivatives(...
                    temp_knots_unique, time_knots_unique, t_vec, alpha, t_total, N);
            end
        otherwise
            error('Unknown curve_parameterization: %s', fm.settings.curve_parameterization);
    end
end