function fm = Compute_Specific_Heat(T_material, fm)
    % Computes the temperature-dependent specific heat capacity of alloy material

    % Example coefficients for a generic aluminum alloy (units: J/kg·K)
    a = 750;    % base (constant) part (should be 750 not 1498.45)
    b = 0.5;    % linear coefficient (should be 0.5 not -2.5395)
    c = 0;    % quadratic coefficient (should be 0 not 0.00413)
    
    % Temperature dependent and mechanical part
    Temp_dependent_part = a + b*T_material + c*T_material.^2; % Increases as temp increases
    Mechanical_part = 0;
    
    % Return specific heat capacity
    C_p = Temp_dependent_part + Mechanical_part;
    
    fm.alloy.Cp = C_p;
    fm.constants.m_aCp_a = fm.alloy.mass * fm.alloy.Cp;
end