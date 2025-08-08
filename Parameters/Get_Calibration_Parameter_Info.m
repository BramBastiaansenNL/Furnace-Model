function param_info = Get_Calibration_Parameter_Info()
    %% Returns master list of calibratable parameters and their locations in fm

    param_info = {
        % Parameter name              Field path in fm.model or fm.substruct
        'epsilon_w',                  'walls.epsilon'
        'Cp_alloy',                   'alloy.Cp'
        'mass_alloy',                 'alloy.mass'
        'A_alloy',                    'alloy.A'
        'h_f_w',                      'furnace.h_f_w'
        'h_ms_f',                     'furnace.h_ms_f'
        'h_f_al',                     'furnace.h_f_al'
        'h_h_f',                      'furnace.h_h_f'
        'h_out',                      'walls.h_out'
        'epsilon_ms',                 'metal_sheet.epsilon_ms'
        'Cp_f',                       'furnace.Cp'
        'Cp_ms',                      'metal_sheet.Cp'
        'mass_ms',                    'metal_sheet.mass'
        'Cp_wall1',                   'walls.Cp1'
        'Cp_wall2',                   'walls.Cp2'
        'lambda_wall1',               'walls.lambda1'
        'lambda_wall2',               'walls.lambda2'
        'rho_wall1',                  'walls.rho1'
        'rho_wall2',                  'walls.rho2'
        'n_heaters',                  'controller.n_heaters'
        'mass_h',                     'heater.mass'
        'A_h',                        'heater.A'
        'Kp',                         'controller.Kp'
        'Ki',                         'controller.Ki'
        'Kd',                         'controller.Kd'
    };
end
