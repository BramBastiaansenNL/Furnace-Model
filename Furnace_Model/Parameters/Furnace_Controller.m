function controller = Furnace_Controller()
    % Struct for all the furnace controller unit's parameters

    %% Controller Gain Parameters
    controller.Kp = 100;        % Proportional gain
    controller.Ki = 0.012493;          % Integral gain
    controller.Kd = 10;          % Derivative gain
    controller.P_max = 13000;      % Maximum power (W)
    controller.n_heaters = 10;  % Number of heating elements
    controller.power_saturated = false; % Tracks power saturation
    controller.power_saturated_series = {0}; % Tracks power saturation time-steps
end