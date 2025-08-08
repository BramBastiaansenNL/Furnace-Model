function [Q_furnace_wall, Q_furnace_alloy, Q_heater_ms, Q_ms_furnace, Q_heater_furnace, Q_heater_wall] = ...
         Compute_Heat_Transfers(T_w_surface_vec, T_f, T_a, T_ms, T_h, fm, T_w_old_surface_vec)
    %% Computes convective and radiative heat transfers

    % Load scripts
    walls = fm.walls;
    furnace = fm.furnace;
    alloy = fm.alloy;
    ms = fm.metal_sheet;
    heater = fm.heater;

    % Load parameters
    A_w = walls.A;                  % Control area (cross-sectional)
    A_alloy = alloy.A;              % Material surface area exposed to furnace air
    A_h = heater.A;                 % Surface area of heater units exposed to convective heat transfer
    A_ms = ms.A;                    % Cross-sectional surface area of metal sheet
    h_f_w = furnace.h_f_w;          % Convective heat transfer coefficient between furnace and wall
    h_f_al = furnace.h_f_al;        % Convective heat transfer coefficient between furnace and alloy
    h_ms_f = furnace.h_ms_f;        % Convective heat transfer coefficient between furnace and metal sheet
    h_h_f = furnace.h_h_f;          % Convective heat transfer coefficient between furnace and heating element
    sigma = heater.sigma;           % Stefan-Boltzmann constant for radiation
    epsilon_ms = ms.epsilon_ms;     % Emmissivity of metal sheet
    epsilon_w = walls.epsilon;      % Emmissitivty of furnace walls
    VF_h_ms = heater.VF_h_ms;       % View factor from heater to metal sheet
    VF_h_w = heater.VF_h_w;         % View factor from heater to wall

    T_w_surface_exposed = T_w_surface_vec(1:4);
    T_w_old_exposed = T_w_old_surface_vec(1:4);
    h_rad = sigma * VF_h_w * epsilon_w;

    % Compute heat transfers
    Q_furnace_wall = h_f_w * A_w * sum(T_f - T_w_surface_vec);
    Q_furnace_alloy = h_f_al * A_alloy * (T_f - T_a);
    Q_heater_ms = sigma * VF_h_ms * epsilon_ms * A_ms * (T_h^4 - T_ms^4);
    Q_ms_furnace = h_ms_f * A_ms * (T_ms - T_f);
    Q_heater_furnace = h_h_f * A_h * (T_h - T_f);
    % Q_heater_wall = h_rad * A_w * sum(T_h^4 - T_w_surface_exposed.^4);
    Q_heater_wall = h_rad * A_w * sum(T_h^4 - T_w_old_exposed.^4) ...
                    - 4 * h_rad * A_w * sum(T_w_old_exposed.^3 .* (T_w_surface_exposed - T_w_old_exposed));
end