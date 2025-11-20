function Plot_Just_Alloy_Results(fm, t, T_f_desired, varargin)
    %% Flexible plotting for just the alloy and mechanical properties
    %   Plot_Results(fm, t, T_f_desired, results_struct)
    
    % Optimization results
    if nargin == 4 && isstruct(varargin{1})
        results = varargin{1};
        T_walls = results.T_w_curve;
        T_f = results.T_f_curve;
        T_m = results.T_m_curve;
        T_ms = results.T_ms_curve;
        T_h = results.T_h_curve;
        Power_Curve = results.Power_curve;

        mechanical_properties = results.mechanical_properties;
        phase_fractions = results.phase_fractions;

        % Plot mechanical properties
        Plot_Mechanical_Properties_Separated(t, T_m, mechanical_properties, phase_fractions, fm)
        

        if isfield(results, 'alpha_opt') && ~isempty(results.alpha_opt)
            alpha_opt = results.alpha_opt;
            Plot_Alloy_Time_Temperature_Curve(t, T_f_desired, T_f, T_walls, T_m, T_ms, T_h, fm, alpha_opt)
        else
            Plot_Alloy_Time_Temperature_Curve(t, T_f_desired, T_f, T_walls, T_m, T_ms, T_h, fm)
        end

    % Single simulation results
    elseif nargin == 9
        T_walls = varargin{1};
        T_f = varargin{2};
        T_m = varargin{3};
        T_ms = varargin{4};
        T_h = varargin{5};
        Power_Curve = varargin{6};
        Plot_Time_Temperature_Curves(t, T_f_desired, T_f, T_walls, T_m, T_ms, T_h, fm)
    else
        error('Invalid input to Plot_Results. Must provide either 6 separate curves or a results struct.');
    end
end