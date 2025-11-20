function Plot_Mechanical_Properties_Distribution(t, T_m, M, X, fm, rep_nodes)
    %% Plots mechanical properties in a tiled layout

    % INPUT:
    %   t   - Total process time (s)
    %   T_m - Material (alloy) temperature (°C)
    %   X   - Phase fractions (matrix NxNt)
    %   YS  - Yield strength (MPa)
    %   UTS - Ultimate tensile strength (MPa)
    %   UE  - Uniform elongation (%)
    %   fm  - Furnace_Model() struct
    %   rep_nodes - Indices of representative nodes

    %% Parameters
    nNodes = numel(rep_nodes);
    C2K = 273.15;
    t_total = sum(t);
    t_h = linspace(0, t_total/3600, length(T_m(1,:)));  % convert to hours

    %% Extract targets
    YS_target = fm.model.sigma_y_min;
    UTS_target = fm.model.sigma_u_min;
    UE_target = fm.model.epsilon_u_min;

    %% Create figure and tiled layout
    fig = figure('Name','Mechanical Properties & Temperature','NumberTitle','off');
    tile = tiledlayout(5,1,'TileSpacing','tight','Padding','compact');
    set(gcf,'Color','w');

    % Use consistent colors for each property
    propColors = lines(4);  % temperature, YS, UTS, UE

    %% ---- 1: Alloy Temperature ----
    nexttile(tile); hold on; grid on;
    firstNode = rep_nodes(1);
    lastNode  = rep_nodes(end);

    T_first = T_m(firstNode,:) - C2K;
    T_last  = T_m(lastNode,:) - C2K;

    fill([t_h, fliplr(t_h)], [T_first, fliplr(T_last)], ...
         propColors(1,:), 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(t_h, T_first, '--', 'Color', propColors(1,:), 'LineWidth', 1.8);
    plot(t_h, T_last, 'Color', propColors(1,:), 'LineWidth', 1.8);

    ylabel('$T_m (^{\circ}C)$','Interpreter','latex','FontSize',12);
    xlim([0, max(t_h)]);
    title('Alloy Temperature');
    legend({'Inner node', 'Surface node'}, ...
           'Interpreter','latex','FontSize',9,'Location','eastoutside');

    %% ---- 2: Phase Fractions ----
    nexttile(tile); hold on; grid on;
    % Phase names
    phaseNames = { ...
        'GP 1', ...
        'GP 2', ...
        'GP 3', ...
        '$\beta^{\prime\prime}$', ...
        '$\beta^{\prime}$', ...
        '$\beta$'};

    % Define consistent colors for phases
    phaseColors = lines(8);
    
    % Get phase fraction matrices
    X_first = X{firstNode}.X;  % [nPhases x Nt]
    X_last  = X{nNodes}.X;   % [nPhases x Nt]

    % Plot filled regions between first and Surface nodes
    for p = 1:size(X_first,1)
        fill([t_h, fliplr(t_h)], ...
             [X_first(p,:), fliplr(X_last(p,:))], ...
             phaseColors(p,:), ...
             'FaceAlpha', 0.25, 'EdgeColor', 'none');
    end
    
    % Plot phase fraction lines for first and Surface node
    for p = 1:size(X_first,1)
        plot(t_h, X_first(p,:), '--', 'LineWidth', 1.8, 'Color', phaseColors(p,:));
        plot(t_h, X_last(p,:), 'LineWidth', 1.8, 'Color', phaseColors(p,:));
    end
    
    ylabel('Phase fractions $x$','Interpreter','latex','FontSize',12);
    xlim([0, max(t_h)]);
    title('Phase Fractions');
    
    % Add legend for phases
    legend(phaseNames, 'Interpreter', 'latex', 'FontSize', 9, 'Location', 'eastoutside');

    %% ---- 3: Yield Strength (YS) ----
    nexttile(tile); hold on; grid on;
    YS_first = M{firstNode}.YS;
    YS_last  = M{nNodes}.YS;

    fill([t_h, fliplr(t_h)], [YS_first, fliplr(YS_last)], ...
         propColors(2,:), 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(t_h, YS_first, '--', 'Color', propColors(2,:), 'LineWidth', 1.8);
    plot(t_h, YS_last, 'Color', propColors(2,:), 'LineWidth', 1.8);

    yline(YS_target,'--','Color',[0.4 0.4 0.4],'LineWidth',1.5);
    ylabel('$\sigma_y$ (MPa)','Interpreter','latex','FontSize',12);
    xlim([0, max(t_h)]);
    title('Yield Strength');
    legend({'Inner node', 'Surface node', 'Target'}, ...
           'Interpreter','latex','FontSize',9,'Location','eastoutside');

    %% ---- 4: Ultimate Tensile Strength (UTS) ----
    nexttile(tile); hold on; grid on;
    UTS_first = M{firstNode}.UTS;
    UTS_last  = M{nNodes}.UTS;

    fill([t_h, fliplr(t_h)], [UTS_first, fliplr(UTS_last)], ...
         propColors(3,:), 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(t_h, UTS_first, '--', 'Color', propColors(3,:), 'LineWidth', 1.8);
    plot(t_h, UTS_last, 'Color', propColors(3,:), 'LineWidth', 1.8);

    yline(UTS_target,'--','Color',[0.4 0.4 0.4],'LineWidth',1.5);
    ylabel('$\sigma_u$ (MPa)','Interpreter','latex','FontSize',12);
    xlim([0, max(t_h)]);
    title('Ultimate Tensile Strength');
    legend({'Inner node', 'Surface node', 'Target'}, ...
           'Interpreter','latex','FontSize',9,'Location','eastoutside');

    %% ---- 5: Uniform Elongation (UE) ----
    nexttile(tile); hold on; grid on;
    UE_first = M{firstNode}.UE;
    UE_last  = M{nNodes}.UE;

    fill([t_h, fliplr(t_h)], [UE_first, fliplr(UE_last)], ...
         propColors(4,:), 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(t_h, UE_first, '--', 'Color', propColors(4,:), 'LineWidth', 1.8);
    plot(t_h, UE_last, 'Color', propColors(4,:), 'LineWidth', 1.8);

    yline(UE_target,'--','Color',[0.4 0.4 0.4],'LineWidth',1.5);
    ylabel('$\varepsilon_u$ (\%)','Interpreter','latex','FontSize',12);
    xlabel('Time [h]','Interpreter','latex','FontSize',14);
    xlim([0, max(t_h)]);
    title('Uniform Elongation');
    legend({'Inner node', 'Surface node', 'Target'}, ...
           'Interpreter','latex','FontSize',9,'Location','eastoutside');

    %% Final adjustments
    set(gca,'TickLabelInterpreter','latex');
end