function power_cost = Compute_Power_Cost(Power_curve, P_max, Nt)
    % Sums up the (normalized) power expenditure given a power curve

    power_cost = sum(Power_curve) / (P_max * Nt);
end