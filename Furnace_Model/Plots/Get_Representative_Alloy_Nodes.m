function node_indices = Get_Representative_Alloy_Nodes(N, num_samples)
    % Returns indices for representative nodes in the alloy
    if N == 1
        node_indices = 1;
    else
        % Always include first and last node (surface + core)
        % Spread remaining samples evenly inside
        node_indices = unique(round(linspace(1, N, num_samples)));
    end
end