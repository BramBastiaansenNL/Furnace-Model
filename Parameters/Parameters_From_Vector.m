function parameters = Parameters_From_Vector(p)
    %% Converts a parameter vector into a structured parameter set

    parameters.k_wall = p(1);      % thermal conductivity
    parameters.h_conv = p(2);      % convection coefficient
    parameters.epsilon = p(3);     % emissivity
    parameters.cp_alloy = p(4);    % specific heat of alloy
    % Add more as needed
end