function fm = Furnace_Model(scheme, discretization_method)
    % Initializes all furnace-related parameters into a struct.

    %% Method type
    if nargin < 1
        % Default method
        fm.method = 'implicit';
        fm.discretization_method = 'FVM';
    elseif nargin < 2
        fm.method = scheme;  
        fm.discretization_method = 'FVM';
    else
        fm.method = scheme;  
        fm.discretization_method = discretization_method;
    end

    %% Load parameter structs
    fm.model = Model_Parameters();
    fm.walls = Wall_Parameters(fm);
    fm.furnace = Furnace_Parameters();
    fm.alloy = Alloy_Parameters();
    fm.metal_sheet = Metal_Sheet_Parameters();
    fm.heater = Heater_Parameters(fm.furnace);
    fm.controller = Furnace_Controller();
    fm.settings = Furnace_Settings();
    fm.constants = System_Constants(fm);
    fm.derivatives = Derivative_Storage(fm);
    fm.matrices = Matrices_Storage(fm);
    fm.param_subset = [];
    fm.default_values = Default_Values();

    %% Load external parameters
    fm.external_parameters = Load_External_Code();
end