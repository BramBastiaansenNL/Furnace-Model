function fm = Update_Furnace_Model(fm, t, N)
    %% Recomputes dependent fields in the furnace model.
        
    % Handle default case
    if nargin < 3, N = 1; end

    % Update time-related parameters
    fm = Update_Time(fm, t);

    if N == 1
        % Update grid-related parameters (e.g., reinitialize spatial grid)
        fm = Change_Grid_Points(fm, fm.walls.Nx);
    end

    if fm.settings.alloy_temperature_distribution
        fm.alloy.A = 2* pi * fm.alloy.R * fm.alloy.L;
        fm.alloy.volume = pi * fm.alloy.R^2 * fm.alloy.L;
        fm.alloy.mass = fm.alloy.density * fm.alloy.volume;
    end

    % Reset derivative storage with updated model
    if fm.settings.symbolic_differentiation
        dT_f_desired_dx = fm.derivatives.dT_f_desired_dx;
        fm.derivatives = Derivative_Storage(fm);
        fm.derivatives.dT_f_desired_dx = dT_f_desired_dx;
    end

    % Recompute system constants
    fm.constants = System_Constants(fm);

    % Recompute discretization matrices
    fm.matrices = Matrices_Storage(fm);
end
