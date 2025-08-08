function Plot_Mechanical_Properties(t, T_m, M, X, fm)
    %% Plots mechanical properties in a tiled layout

    % INPUT:
    %   t   - Total process time (s)
    %   T_m - Material (alloy) temperature (°C)
    %   X   - Phase fractions (matrix NxNt)
    %   YS  - Yield strength (MPa)
    %   UTS - Ultimate tensile strength (MPa)
    %   UE  - Uniform elongation (%)
    %   fm  - Furnace_Model() struct
    
    % Extract mechanical properties
    YS = M.YS; 
    UTS = M.UTS; 
    UE = M.UE;

    % Display minimum mechanical properties
    YS_target = fm.model.sigma_y_min;
    UTS_target = fm.model.sigma_u_min;
    UE_target = fm.model.epsilon_u_min;

    % Convert time to hours
    t_total = sum(t);
    t_h = t_total / 3600; 
    C2K = 273.15;   % Celcius to degrees
    T_m = T_m - C2K;
    t_grid = linspace(0, t_h, length(T_m)); 

    % Define figure properties
    fig = figure();
    fig_size = 650;
    ratio = 0.8;
    options = []; % Latexify options
    
    % Create tiled layout
    tile = tiledlayout(5, 1, "TileSpacing", "tight", "Padding", "compact");

    % Plot 1: Furnace Temperature
    nexttile(tile)
    plot(t_grid, T_m, 'LineWidth', 1.9, 'Color', 'r');
    ax = gca(); ax.XTickLabel = {}; xlim([0, max(t_grid)]);
    Latexify(fig, 0, fig_size, ratio, options);
    ylabel("$T_m$ ($^{\circ}$C)", 'Interpreter', 'latex', 'FontSize', 12);
    ylim([min(T_m) - 0.05 * max(T_m), max(T_m) + 0.05 * max(T_m)]);
    grid on;

    % Plot 2: Phase Fractions (X)
    nexttile(tile)
    plot(t_grid, X', 'LineWidth', 1.9); 
    ax = gca(); ax.XTickLabel = {}; xlim([0, max(t_grid)]);
    Latexify(fig, 0, fig_size, ratio, options);
    ylabel("Phase fractions $x$", 'Interpreter', 'latex', 'FontSize', 12);
    grid on;

    % Plot 3: Yield Strength (YS)
    nexttile(tile)
    plot(t_grid, YS, 'LineWidth', 1.9, 'Color', [0, 0.45, 0.74]); % MATLAB blue
    yline(YS_target, '--', 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
    ax = gca(); ax.XTickLabel = {}; xlim([0, max(t_grid)]);
    Latexify(fig, 0, fig_size, ratio, options);
    ylabel("$\sigma_y$ (MPa)", 'Interpreter', 'latex', 'FontSize', 12);
    
    y_min = min([YS(:); YS_target]) - 0.05 * max(YS);
    y_max = max([YS(:); YS_target]) + 0.05 * max(YS);
    ylim([y_min, y_max]);
    grid on;

    % Plot 4: Ultimate Tensile Strength (UTS)
    nexttile(tile)
    plot(t_grid, UTS, 'LineWidth', 1.9, 'Color', [0.85, 0.33, 0.1]); % MATLAB red-orange
    yline(UTS_target, '--', 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
    ax = gca(); ax.XTickLabel = {}; xlim([0, max(t_grid)]);
    Latexify(fig, 0, fig_size, ratio, options);
    ylabel("$\sigma_u$ (MPa)", 'Interpreter', 'latex', 'FontSize', 12);

    y_min = min([UTS(:); UTS_target]) - 0.05 * max(UTS);
    y_max = max([UTS(:); UTS_target]) + 0.05 * max(UTS);
    ylim([y_min, y_max]);
    grid on;

    % Plot 5: Uniform Elongation (UE)
    nexttile(tile)
    plot(t_grid, UE, 'LineWidth', 1.9, 'Color', [0.47, 0.67, 0.19]); % MATLAB green
    yline(UE_target, '--', 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
    Latexify(fig, 0, fig_size, ratio, options); xlim([0, max(t_grid)]);
    ylabel("$\varepsilon_u$ (\%)", 'Interpreter', 'latex', 'FontSize', 10);
    xlabel("$t$ (h)", 'Interpreter', 'latex', 'FontSize', 14);
    
    y_min = min([UE(:); UE_target]) - 0.05 * max(UE);
    y_max = max([UE(:); UE_target]) + 0.05 * max(UE);
    ylim([y_min, y_max]);
    grid on;

    % Final figure adjustments
    set(gcf, 'Color', 'w');
    set(gca, 'TickLabelInterpreter', 'latex');
end