function mech_loss = Compute_Mechanical_Loss(M, furnace_model)
    %% Function to compute mechanical loss based on temperature profile

    % INPUT:
    %   M   - Mechanical properties
    %   furnace_model - Struct for all furnace model parameters and nested structs
    
    % OUTPUT:
    %   mech_loss - Mean Squared Error (predicted values - desired)
    
    % Initialize
    model = furnace_model.model;
    UTS_min = model.sigma_u_min;      % Target ultimate tensile strength
    UE_min = model.epsilon_u_min;     % Target elongation 
    YS_min = model.sigma_y_min;       % Target yield strength

    % Weights for each property (to be tuned based on importance)
    w_YS = model.w_YS;    % Weight for yield strength
    w_UTS = model.w_UTS;  % Weight for ultimate tensile strength
    w_UE = model.w_UE;    % Weight for uniform elongation

    % Final mechanical properties
    YS = M.YS(end);
    UTS = M.UTS(end);
    UE = M.UE(end);

    % Define normalized deviation from minimum (positive if above)
    delta_YS = (YS - YS_min) / YS_min;
    delta_UTS = (UTS - UTS_min) / UTS_min;
    delta_UE = (UE - UE_min) / UE_min;   

    % Define piecewise reward-penalty: penalize below min, reward above
    reward_gain = model.mech_reward_gain;

    loss_YS  = w_YS  * ((delta_YS < 0) * (delta_YS)^2 - reward_gain * (delta_YS >= 0) * (delta_YS)^2);
    loss_UTS = w_UTS * ((delta_UTS < 0) * (delta_UTS)^2 - reward_gain * (delta_UTS >= 0) * (delta_UTS)^2);
    loss_UE  = w_UE  * ((delta_UE < 0) * (delta_UE)^2 - reward_gain * (delta_UE >= 0) * (delta_UE)^2);

    % Total mechanical loss
    mech_loss = loss_YS + loss_UTS +  loss_UE;
end