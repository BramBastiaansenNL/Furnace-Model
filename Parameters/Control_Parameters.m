%% File to list all unknown parameters by relative importance

% Alloy (Material) Parameters
Alloy Initial temperature: alloy.T_initial = 298.15 (K) (assumed room temperature)
Alloy mass: alloy.mass = ? (kg) (depends on alloy)
Alloy specific heat capacity: alloy.Cp = 900 (J/kg·K) (depends on alloy)
Alloy surface area exposed to the furnace air: alloy.A = ? (m²) (depends on alloy)
! parameters (a,b,c) for computing temperature dependent specific heat Cp = a + bT + cT^2?
! character surface area exposed to fan

% Furnace Controller Unit
Proportional gain: controller.Kp = ? (not relevant for calibration if power is given)
Integral gain: controller.Ki = ? (not relevant for calibration if power is given)
Derivative gain: controller.Kd = ? (not relevant for calibration if power is given)
Maximum power: controller.P_max = 13000 (W) (from furnace manual)
Number of heating units: controller.n_heaters = 20 (from schematics)

% Furnace Parameters
Furnace Initial temperature: furnace.T_initial = 298.15 (K) (assumed room temperature)
Density of furnace air: furnace.density = 1.0 (kg/m³) (not relevant for calibration since it is computing explicitly in every time step)
Furnace Volume: furnace.volume = 0.172872 (m³) (from manual)
Furnace Mass: furnace.mass = furnace.density * furnace.volume (kg) (not relevant for calibration since it is computed and volume is known)
Furnace Specific Heat Capacity: furnace.Cp = 100? (J/kg·K) (UNKNOWN!)
Furnace Surface Area for Convection: furnace.A_f = 0.49 * 0.72 (m²) (from schematics)
Furnace Fan Induced conduction parameters: (not used so not relevant in calibration)
    Dynamic viscosity: furnace.mu = 1 (Pa·s)
    Thermal conductivity: furnace.k = 1 (W/m·K)
Heat transfer coefficients (UNKNOWN!)
    furnace.h_f_w = 20 (W/m²·K)
    furnace.h_ms_f = 20 (W/m²·K)
    furnace.h_f_al = 10 (W/m²·K)
    furnace.h_h_f = 20  (W/m²·K)
    walls.h_out = 10 (W/m²·K)

% Heater Element Parameters (all known from schematics)
Heater Initial temperature: heater.T_initial = 298.15 (K) (assumed room temperature)
Heater Diameter: heater.D = 0.02 (m) (from schematics)
Heater Spacing between heater elements: heater.s = 0.098 (m) (rough estimate)

% Metal Sheet (separating heaters from main furnace chamber)
MS Initial temperature: metal_sheet.T_initial = 298.15 (K) (assumed room temperature)
MS Mass: metal_sheet.mass = 0.1 (kg) (UNKNOWN!)
MS Specific Heat Capacity: metal_sheet.Cp = 100 (J/kg·K) (UNKNOWN!)
MS Radiative Emmissivity: metal_sheet.epsilon_ms = 1.0 (UNKOWN!)

% Wall Parameters (wall layer 1: high-temperature-rock-wool-panel, layer 2: steel/metal sheet)?
Wall Number of Grid Points: walls.Nx = 15 (not finalized value)
Wall Initial temperatures: walls.T_initial = 298.15 * ones(1, walls.Nx)
Wall Radiative Emmissivity: walls.epsilon = 1 (UNKNOWN!)
Wall Thermal Conductivity Layer 1: walls.lambda1 = 0.05 (W/m·K) (UNKNOWN!)
Wall Thermal Conductivity Layer 1: walls.lambda2 = 45 (W/m·K) (UNKNOWN!)
Wall Density Layer 1: walls.rho1 = 200 (kg/m³) (UNKNOWN!)
Wall Density Layer 2: walls.rho2 = 7800 (kg/m³) (UNKNOWN!)
Wall Specific Heat Capacity Layer 1: walls.Cp1 = 1000 (J/kg·K) (UNKNOWN!)
Wall Specific Heat Capacity Layer 2: walls.Cp2 = 500 (J/kg·K) (UNKNOWN!)

% Constraints on all unknown parameters (UNKNOWN!)

%% Ranking Unknown Parameters by Relative Importance
In terms of model accuracy and calibration impact, based on:
    Sensitivity: How strongly the parameter influences the outputs
    Direct involvement in energy balances
    Whether the parameter appears in multiple parts of the system
    Whether the parameter can be lumped with others to reduce calibration effort

% -- HIGH PRIORITY -- %

1. Alloy Parameters (significant impact) --  EN AW-6082 [Al Si1 Mg Mn]
    -Specific Heat Capacity (a,b,c -> Cp)
    -Exposed Surface Area (tensile test specimens/dog-bone samples)
    -Mass
    -See https://www.enzemfg.com/6082-aluminum-alloy-everything-you-need-to-know/
    -https://www.matweb.com/search/DataSheet.aspx?MatGUID=26d19f2d20654a489aefc0d9c247cebf&ckck=1
    -See sources folder

2. Heat Transfer Coefficients (directly impact heat flow)
    -furnace.h_f_al
    -furnace.h_ms_f
    -furnace.h_f_w
    -furnace.h_h_f
    -walls.h_out
    -https://www.researchgate.net/post/How_much_heat_transfer_coefficient_of_air
    -https://quickfield.com/natural_convection.htm
    -https://www.engineersedge.com/thermodynamics/overall_heat_transfer-table.htm
    -https://www.engineeringtoolbox.com/convective-heat-transfer-d_430.html

3. Radiative Emmissivity (affects efficiency of radiative power)
    -metal_sheet.epsilon_ms
    -walls.epsilon

4. Furnace Air Cp (influences temperature rises)

% -- MEDIUM PRIORITY -- %

5. Metal Sheet Parameters 
    -metal_sheet.Cp
    -metal_sheet.mass

6. Wall Layer Parameters
    -walls.lambda1, walls.lambda2
    -walls.Cp1, walls.Cp2
    -walls.epsilon
    -walls.rho1, walls.rho2