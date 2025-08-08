function external_parameters = Load_External_Code()
    %% Placeholder function to compute mechanical properties based on temperature profile

    % Load parameters for the mechanical submodel
    external_parameters.x_opt_YS = load("x_opt_YS.mat", "x_opt").x_opt;
    external_parameters.x_opt_UTS = load("x_opt_UTS.mat", "x_opt").x_opt;
    external_parameters.x_opt_UE = load("x_opt_UE.mat", "x_opt").x_opt;
end