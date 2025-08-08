function furnace = Furnace_Parameters()
    % Struct for all furnace parameters

    %% Furnace Parameters
    furnace.density = 1.0;    % Density of furnace air (kg/m³)
    furnace.volume = 0.172872;     % Volume of furnace (m³)
    furnace.mass = furnace.density * furnace.volume;  % Mass of furnace air (kg)
    furnace.Cp = 1150;        % Specific heat capacity of air (J/kg·K)
    furnace.mass_times_Cp = furnace.mass * furnace.Cp;
    furnace.mu = 1;             % Dynamic viscosity (Pa·s)
    furnace.k = 1;        % thermal conductivity (W/m·K)
    furnace.T_initial = 297.15; % Initial furnace temperature (K)
    
    %% Heat Transfer Coefficients
    furnace.h_f_w = 0.223288;       % Convective heat transfer coefficient between furnace and wall (W/m²·K)
    furnace.h_ms_f = 9.269076;      % Convective heat transfer coefficient between furnace and metal sheet (W/m²·K)
    furnace.h_f_al = 37.901044;      % Convective heat transfer coefficient between furnace and alloy (W/m²·K)
    furnace.h_h_f = 49.999924;       % Convective heat transfer coefficient between furnace and heating elements (W/m²·K)
end