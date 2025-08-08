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
    settings.optimizer = 'fmincon';
    settings.store_derivatives = false;
    settings.compare_cost_gradients = false;
    settings.NR_converged = false;
    settings.material_entry = 0;
    settings.desired_temperature_curve = false;
    settings.point_iterative_derivative = false;
    settings.monolithic_derivative = true;
    settings.add_wall_plot = true;
    settings.power_input = false;
    settings.curve_parameterization = 'constant';
end