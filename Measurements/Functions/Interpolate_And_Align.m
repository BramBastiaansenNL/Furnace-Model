function [T_interp, t_common, idx_valid] = Interpolate_And_Align(t_furnace, t_external, T_external, t_cutoff)
    %% Only keep furnace timestamps after external starts and before external ends

    idx_start = find(t_furnace >= t_external(1), 1, 'first');
    idx_end   = find(t_furnace <= t_external(end), 1, 'last');
    idx_range = idx_start:idx_end;

    t_common = t_furnace(idx_range) - t_furnace(idx_start);  % zeroed time
    T_interp = interp1(t_external, T_external, t_furnace(idx_range), 'linear', 'extrap');

    % Apply optional cutoff
    idx_valid = idx_range(t_common <= t_cutoff);
    t_common = t_common(t_common <= t_cutoff);
    T_interp = T_interp(1:length(t_common))' + 273.15;  % Kelvin
end
