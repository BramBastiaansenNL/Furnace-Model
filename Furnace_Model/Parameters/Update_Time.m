function furnace_model = Update_Time(furnace_model, t, dt)
    %% Function to update time parameters in the furnace model
    
    % Optional input: dt — time step size
    if nargin < 3  % dt not provided
        dt = furnace_model.model.dt;
    else
        furnace_model.model.dt = dt;  % Update dt in the model
    end

    % Update total process time
    furnace_model.model.t_final = sum(t);
    
    % Recalculate number of time steps
    furnace_model.model.Nt = round(sum(t) / dt);
    furnace_model.constants.dth_f_wA_w = dt * furnace_model.furnace.h_f_w * furnace_model.walls.A;
end