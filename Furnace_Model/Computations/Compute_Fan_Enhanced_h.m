function h = Compute_Fan_Enhanced_h(fan_speed, fm)
    % Re-computes all convective heat transfer coefficients based on fan velocity

    % Extract parameters
    u = fan_speed;                        % Fan-induced air velocity [m/s]
    rho = fm.furnace.rho;                 % Density of air
    mu = fm.furnace.mu;                   % Dynamic viscosity
    cp = fm.furnace.Cp;                   % Specific heat capacity
    k = fm.furnace.k;                     % Thermal conductivity
    L = fm.alloy.A;                       % Convective surface area

    % Compute dimensionless numbers
    Re = (rho * u * L) / mu;                  % Reynolds number
    Pr = (cp * mu) / k;                       % Prandtl number

    % Compute Nusselt number using empirical correlations
    if Re < 5e5
        Nu = 0.332 * Re^0.5 * Pr^(1/3);       % Laminar
    else
        Nu = 0.037 * Re^(4/5) * Pr^(1/3);     % Turbulent
    end

    % Compute heat transfer coefficient
    h = (Nu * k) / L;
end