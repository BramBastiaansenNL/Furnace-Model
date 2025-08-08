function matrices = Matrices_Storage(fm)
    %% Struct storing all relevant matrices and vectors
    
    % Dimensions
    Nx = fm.walls.Nx;
    wall_names = {'side1', 'side2', 'top', 'bottom', 'front', 'back'};
    num_walls = length(wall_names);

    if strcmpi(fm.discretization_method, 'FVM')
        % A and b
        for i = 1:num_walls
            name = wall_names{i};
            wall = fm.walls.(name);
            gamma = wall.gamma';
            alpha = wall.alpha';
            beta = wall.beta';
            A = diag(gamma, -1) + diag(alpha) + diag(beta, 1);
            A_sparse = sparse(A);
        
            matrices.A_template{i} = A_sparse;
            matrices.alpha_1_series{i} = {0};
        end
    else % strcmpi(fm.discretization_method, 'FEM')
        % Mass, stiffness matrices
        for i = 1:num_walls
            name = wall_names{i};
            wall = fm.walls.(name);
            dx   = wall.dx;
            rho  = wall.rho;
            Cp   = wall.Cp;
            k    = wall.lambda;
            rhoCp = rho .* Cp;
            
            % Mass matrix and stiffness matrix
            M = zeros(Nx,Nx);
            A = zeros(Nx,Nx);
            B = zeros(Nx,Nx);

            for j = 1:Nx-1

                % Local mass matrix (2×2)
                M_loc = (rhoCp(j) * dx / 6) * [2 1; 1 2];
                % Local stiffness matrix
                A_loc = (k(j) / dx) * [1 -1; -1 1];
                idx = [j, j+1];
                M(idx,idx) = M(idx,idx) + M_loc;
                A(idx,idx) = A(idx,idx) + A_loc;
            end

            matrices.M{i} = sparse(M);
            matrices.A{i} = sparse(A);
            matrices.B{i} = sparse(B);
            matrices.B_11_series{i} = {0};
        end
    end
end