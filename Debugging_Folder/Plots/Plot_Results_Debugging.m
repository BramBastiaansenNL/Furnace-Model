function Plot_Results_Debugging(fm, t, T_f_desired, varargin)
    %% Flexible plotting for both furnace model simulation and optimization outputs
    % Usage:
    %   Plot_Results(fm, t, T_f_desired, T_walls, T_furnace, T_alloy, T_ms, T_heater, Power_Curve)
    %   Plot_Results(fm, t, T_f_desired, results_struct)
    
    % Optimization results
    if nargin == 4 && isstruct(varargin{1})
        results = varargin{1};
        T_walls = results.T_w;
        T_f = results.T_f_curve;
        T_m = results.T_m_curve;
        T_ms = results.T_ms_curve;
        T_h = results.T_h_curve;
        Power_Curve = results.Power_curve;
        mechanical_properties = results.mechanical_properties;
        phase_fractions = results.phase_fractions;

        % Plot mechanical properties
        Plot_Mechanical_Properties(t, T_m, mechanical_properties, phase_fractions, fm)

    % Single simulation results
    elseif nargin == 9
        T_walls = varargin{1};
        T_f = varargin{2};
        T_m = varargin{3};
        T_ms = varargin{4};
        T_h = varargin{5};
        Power_Curve = varargin{6};
    else
        error('Invalid input to Plot_Results. Must provide either 6 separate curves or a results struct.');
    end
   
    %% Plot wall temperature
    if fm.settings.plot_all_walls
        Plot_Walls_Temperature(T_walls, fm)
    else
        Plot_Wall_Temperature(T_walls(1, :), fm.walls.side1)
    end
    
    %% Plot Time-Temperature Curves
    Plot_Time_Temperature_Curves(t, T_f_desired, T_f, T_m, T_ms, T_h, fm.model.dt)
    
    %% Plot Power Consumption
    % Plot_Power_Curve(t, Power_Curve, fm)
end