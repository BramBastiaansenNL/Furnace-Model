function [cached_result] = Get_Or_Run_Simulation(x, furnace_model)
    %% Either grabs the last cached result or runs a new simulation
    
    % Disable caching if automatic differentiation is enabled
    if furnace_model.settings.automatic_differentiation
        % Always run the simulation fresh
        [cached_result, ~] = Furnace_Simulation_Cache(x, furnace_model, 'set');
        return;
    end

    % Normal caching behavior
    [cached_result, found] = Furnace_Simulation_Cache(x, furnace_model, 'get');
    if ~found
        [cached_result, ~] = Furnace_Simulation_Cache(x, furnace_model, 'set');
    end
end