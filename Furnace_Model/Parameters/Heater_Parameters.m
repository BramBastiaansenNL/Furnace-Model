function heater = Heater_Parameters(furnace)
    % Struct for the parameters of the thin metal sheet

    %% Physical Parameters
    heater.mass = 82.453652;
    heater.Cp = 100;
    heater.A = 10;
       
    %% Radiation Parameters
    heater.sigma = 5.67e-8;                 % Stefan-Boltzmann constant (W/m^2K^4)
    heater.T_initial = furnace.T_initial;   % Initial heater temperature (K)
    heater.D = 0.02;                        % Heater element diameter (m)
    heater.s = 0.098;                       % Space between heater elements (m)

    %% View Factors
    D = heater.D;
    s = heater.s;
    % View factor from heater to metal sheet
    heater.VF_h_ms = 1 - sqrt(1 - (D/s)^2) + (D/s) * atan(sqrt((s^2 - D^2)/D^2));            
    heater.VF_h_w = heater.VF_h_ms;         % View factor from heater to wall is the same
end