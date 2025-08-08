function loss = Simultaneous_Calibration_Loss_Function(parameters, ...
     time_measurement_step, T_measurement_step, P_measurement_step, ...
     time_measurement_cone, T_measurement_cone, P_measurement_cone, fm)
    %% Defines the error between simulated and measured data for both datasets
    
    % Dataset 1: Step
    fm.settings.material_entry = 274;
    T_sim_step = Furnace_Model_Wrapper(parameters, ...
        time_measurement_step, P_measurement_step, T_measurement_step, fm);

    % Dataset 2: Cone
    fm.settings.material_entry = 0;
    T_sim_cone = Furnace_Model_Wrapper(parameters, ...
        time_measurement_cone, P_measurement_cone, T_measurement_cone, fm);

    % Define weights per signal
    weight_furnace = 1.0;
    weight_material = 1.0;
    weight_step = 1.0;
    weight_cone = 20.0;

    % Step loss
    error_furnace_step = T_sim_step.T_f_curve - T_measurement_step.T_furnace;
    error_material_step = T_sim_step.T_m_curve - T_measurement_step.T_material_ext;

    loss_step = weight_furnace * sum(error_furnace_step.^2) + ...
                weight_material * sum(error_material_step.^2);

    % Cone loss
    error_furnace_cone = T_sim_cone.T_f_curve - T_measurement_cone.T_furnace;
    error_material_cone = T_sim_cone.T_m_curve - T_measurement_cone.T_material_ext;

    loss_cone = weight_furnace * sum(error_furnace_cone.^2) + ...
                weight_material * sum(error_material_cone.^2);

    % Total combined loss
    loss = weight_step * loss_step + weight_cone * loss_cone;
end