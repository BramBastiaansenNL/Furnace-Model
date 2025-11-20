function settings = Furnace_Settings()
    %% Struct for all the default furnace model settings

    settings.dynamic_wall_plotting = false;
    settings.dynamic_residual_plotting = false;
    settings.plot_all_walls = false;
    settings.alloy_present = true;
    settings.debug_jacobian = false;
    settings.debugging = false;
    settings.debugging_optimizer = false;
    settings.algorithm = 'sqp';
    settings.mechanical_loss = false;
    settings.mechanical_constraints = false;
    settings.optimizer = 'fmincon';
    settings.symbolic_differentiation = false;
    settings.automatic_differentiation = false;
    settings.compare_cost_gradients = false;
    settings.NR_converged = false;
    settings.material_entry = 0;
    settings.desired_temperature_curve = true;
    settings.desired_temp_curve_specified = false;
    settings.point_iterative_derivative = false;
    settings.monolithic_derivative = true;
    settings.add_wall_plot = true;
    settings.power_input = false;
    settings.curve_parameterization = 'constant';
    settings.show_calibration = false;
    settings.adaptive_step_size = false;
    settings.constant_step_size = false;
    settings.alloy_temperature_distribution = false;
end