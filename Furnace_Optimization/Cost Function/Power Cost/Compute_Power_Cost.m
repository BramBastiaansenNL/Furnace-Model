function power_cost = Compute_Power_Cost(Power_curve, dt, P_max, t)
    % Sums up the (normalized) power expenditure given a power curve

    % power_cost = sum(Power_curve) * dt / (P_max * t);
    % Don't know why I was using the one above
    power_cost = sum(Power_curve) * dt / (P_max);
end