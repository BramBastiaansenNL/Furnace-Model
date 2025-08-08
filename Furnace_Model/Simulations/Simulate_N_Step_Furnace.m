function [T_w_curve, T_f_curve, T_a_curve, T_ms_curve, Power_curve, T_h_curve, fm] = ...
    Simulate_N_Step_Furnace(T_f_desired, t, fm)
    %% Simulates the furnace for an N-step process with stepwise temperature changes
    
    % Total number of time steps
    dt = fm.model.dt;
    Nt = round(t / dt);
    Nt_total = sum(Nt);
    N = length(T_f_desired); % Total number of temperature profile 'steps'
    fm.model.N = N;

    % Initialize storage
    T_w_curve = zeros(6, fm.walls.Nx, Nt_total);
    T_f_curve = zeros(1, Nt_total);
    T_a_curve = zeros(1, Nt_total);
    T_ms_curve = zeros(1, Nt_total);
    Power_curve = zeros(1, Nt_total);
    T_h_curve = zeros(1, Nt_total);

    % Running index for filling
    idx = 1;

    % Determine whether the alloy is present in the furnace
    if ~isfield(fm.settings, 'alloy_present') || ~fm.settings.alloy_present
        fm = Remove_Alloy(fm);
    end
    
    if fm.settings.store_derivatives
        dP_dx = zeros(1, 2 * N);
    end 

    %% Loop through each step
    for i = 1:N
        
        % Simulate furnace behavior for this step
        [T_w_step, T_f_step, T_a_step, T_ms_step, Power_step, T_h_step, fm] = ...
            Simulate_Furnace(T_f_desired(i), t(i), fm, i);
        
        % Update furnace temperature after this step
        fm = Update_Temperature(fm, T_f_step(end), T_w_step(:,:, end), T_a_step(end), T_ms_step(end), T_h_step(end));

        % Fill in results
        T_w_curve(:, :, idx : idx+Nt(i)-1) = T_w_step(:, :, :);
        T_f_curve(idx : idx+Nt(i)-1) = T_f_step;
        T_a_curve(idx : idx+Nt(i)-1) = T_a_step;
        T_ms_curve(idx : idx+Nt(i)-1) = T_ms_step;
        Power_curve(idx : idx+Nt(i)-1) = Power_step;
        T_h_curve(idx : idx+Nt(i)-1) = T_h_step;

        idx = idx + Nt(i);

        % Assemble derivatives in their correct format
        if fm.settings.store_derivatives
            dP_dx = Assemble_Derivatives(dP_dx, fm, i);
        end
    end
    
    % Sum up the total derivative
    if fm.settings.store_derivatives
        fm.derivatives.dP_dx_full = dP_dx;
    end
end