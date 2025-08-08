function fm = Compute_Air_Density(T_furnace, fm)
    % Temperature-dependent density of furnace air using ideal gas law

    % Example coefficients
    P = 101325;           % Pa (1 atm)
    M = 0.02897;          % kg/mol (average molar mass of dry air)
    R = 8.314;            % J/mol·K

    rho = (P * M) ./ (R * T_furnace);

    fm.furnace.density = rho;
    fm.furnace.mass = fm.furnace.density * fm.furnace.volume;
    fm.furnace.mass_times_Cp = fm.furnace.mass * fm.furnace.Cp;
    fm.furnace.constants.m_fCp_f = fm.furnace.mass_times_Cp;
end