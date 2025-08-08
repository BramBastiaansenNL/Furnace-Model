function constants = System_Constants(fm)
    %% Struct for storing and computing all the constants (for efficiency)

    walls = fm.walls;
    furnace = fm.furnace;
    alloy = fm.alloy;
    ms = fm.metal_sheet;
    heater = fm.heater;

    A_w = walls.A;                  % Control area (cross-sectional)
    A_a = alloy.A;                  % Material surface area exposed to furnace air
    A_h = heater.A;                 % Surface area of heater units exposed to convective heat transfer
    A_ms = ms.A;                    % Cross-sectional surface area of metal sheet
    sigma = heater.sigma;           % Stefan-Boltzmann constant for radiation
    h_f_w = furnace.h_f_w;          % Convective heat transfer coefficient between furnace and wall
    h_f_a = furnace.h_f_al;         % Convective heat transfer coefficient between furnace and alloy
    h_ms_f = furnace.h_ms_f;        % Convective heat transfer coefficient between furnace and metal sheet
    h_h_f = furnace.h_h_f;          % Convective heat transfer coefficient between furnace and heating element
    epsilon_ms = ms.epsilon_ms;     % Emmissivity of metal sheet
    epsilon_w = walls.epsilon;      % Emmissivity of the wall

    % View factors
    VF_h_ms = heater.VF_h_ms;       % View factor from heater to metal sheet
    VF_h_w = heater.VF_h_w;         % View factor from heater to wall
    
    constants.m_fCp_f = fm.furnace.mass * fm.furnace.Cp;
    constants.m_aCp_a = alloy.mass * alloy.Cp;
    constants.m_msCp_ms = ms.mass * ms.Cp;
    constants.m_hCp_h = heater.mass * heater.Cp;
    
    constants.rad_constant_h_ms = sigma * VF_h_ms * epsilon_ms * A_ms;
    constants.rad_constant_h_w = sigma * VF_h_w * epsilon_w * A_w;
    
    constants.h_f_aA_a = h_f_a * A_a;
    constants.h_f_wA_w = h_f_w * A_w;
    constants.h_ms_fA_ms = h_ms_f * A_ms;
    constants.h_h_fA_h = h_h_f * A_h;
end