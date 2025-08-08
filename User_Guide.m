%% -------------- USER GUIDE --------------- %%
% Details a number of actions you can take to change the settings, simulation or
% optimization procedures

%% Load paths and initialize the furnace model
Add_Paths2();
fm = Furnace_Model();

%% Tune settings

% Flag to store derivatives
fm.settings.store_derivatives = true;

% Flag to use the point-iterative method for computing gradients (default = false)
fm.settings.point_iterative_derivative = true;

% Flag to check and compare analytical to numerical cost gradients
fm.settings.compare_cost_gradients = true;

% Flag to specify whether the alloy/material is currently present in the furnace
fm.settings.alloy_present = false; % default assumption is true

% If you want to see a dynamic plot of the (side) wall's temperature distribution over time
fm.settings.dynamic_wall_plotting = true;

% If you want to see the residual norm of Newton-Raphson
fm.settings.dynamic_residual_plotting = true;

% If you want to display additional plots and information during the simulation
fm.settings.debugging = true;

% If you want to compare the analytical Jacobian to the numerical gradients
% of the Newton-Raphson residual system
fm.settings.debug_jacobian = true;

% If you want to see the final temperature distribution of all six walls instead of just one
fm.settings.plot_all_walls = true;
% For disabling the wall 1, node 1 addition to the main plot
fm.settings.add_wall_plot = false;

% Changing the numerical method used to solve the system of ODEs and PDEs
fm.method = "implicit";    % Using Newton-Raphson iterations
fm.method = "fsolve";      % Using MATLAB's fsolve
fm.method = "comparison";  % Compares results between implicit and fsolve

% Changing the algorithm used by fmincon
fm.settings.algorithm = 'interior-point';   % default algorithm is 'sqp'

% Changing the optimization method used (default is fmincon)
fm.settings.optimizer = 'projected gradient descent';
fm.settings.optimizer = 'comparison'; % Compares the two optimization procedures

% Toggling the penalty term for mechancial loss (deviation from desired
% values), neccessary when using projected gradient descent
fm.settings.mechanical_loss = true;  

% Changing the discretization method for the wall (default is FVM)
fm.discretization_method = 'FEM';
fm.discretization_method = 'FVM';

% Dictates whether the power input has been provided apriori
fm.settings.power_input = true;

% Dictates whether the desired temperature curve is provided (for plotting purposes)
fm.setting.desired_temperature_curve = true;

%% Changing Parameters

% Changing the relative importance of the mechanical penalty term
fm.model.mech_w = 50;

% Updating all furnace model fields with new parameters
fm = Update_Furnace_Model(fm, t);