function fm = Compute_Specific_Heat(T_material, fm)
    % Computes the temperature-dependent specific heat capacity of alloy material

    % Example coefficients for a generic aluminum alloy (units: J/kg·K)
    a = 1498.45;    % base (constant) part
    b = -2.5395;    % linear coefficient
    c = 0.00413;    % quadratic coefficient
    
    % Temperature dependent and mechanical part
    Temp_dependent_part = a + b*T_material + c*T_material.^2; % Increases as temp increases
    Mechanical_part = 0;
    
    % Return specific heat capacity
    C_p = Temp_dependent_part + Mechanical_part;
    
    fm.alloy.Cp = C_p;
    fm.constants.m_aCp_a = fm.alloy.mass * fm.alloy.Cp;
end

% ----------------- Optional: Use Look-up Table for more precision

% function  C_p = Compute_Specific_Heat(T_material
%     % Tabulated temperatures [K] and cp values [J/kg·K]
%     T_data = [300 400 500 600 700 800 900];
%     cp_data = [900 950 1000 1050 1100 1150 1200];
% 
%     cp = interp1(T_data, cp_data, T, 'linear', 'extrap');
% end