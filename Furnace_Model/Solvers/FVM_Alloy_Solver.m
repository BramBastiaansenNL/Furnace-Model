function [T_alloy_new, fm] = FVM_Alloy_Solver(T_furnace, T_alloy_old, fm)
    %% Updates temperatures for all 6 walls using implicit finite volume method and Thomas algorithm
    
    % Load scripts
    furnace = fm.furnace;
    alloy = fm.alloy;

    % Unpack parameters
    N      = alloy.N;        % Number of nodes (cell centers)
    R      = alloy.R;        % Cylinder radius
    L      = alloy.L;
    k      = alloy.k;
    dr     = R / (N-1);      % Uniform spacing if you place centers at boundaries
    rho    = alloy.rho;
    Cp     = alloy.Cp;
    dt     = fm.model.dt;
    h_f_al = furnace.h_f_al;  % Convection coeff. furnace<->alloy
    rho_cp = rho*Cp; 

    % Preallocate tridiagonal system
    gamma = zeros(N-1,1);  % lower diag
    beta  = zeros(N-1,1);  % upper diag
    alpha = zeros(N,1);    % main diag
    b     = zeros(N,1);    % RHS

    % Cell volumes in cylindrical coords
    V    = pi * ( ( ( (0:N-1)+0.5 )*dr ).^2 - ( (0:N-1)-0.5 ).^2 * dr^2 ) * L;  
    V(1) = pi * ((dr/2)^2) * L;
    V(N) = pi * (R*dr - (dr/2)^2) * L;

    % Loop over nodes to build system
    for i = 1:N
        r = (i-1)*dr;   % radius at node center
        r_ip = min(R, r + dr/2);   % east face radius
        r_im = max(0, r - dr/2);   % west face radius
        % V_i = pi*L* (r_ip^2 - r_im^2);
        Ae = 2*pi*r_ip*L; 
        Aw = 2*pi*r_im*L;

        if i == 1
            % --- Symmetry boundary at r=0 ---
            alpha(i) = rho_cp*V(i)/dt + k/dr * Ae;
            beta(i)  = -k/dr * Ae;
            b(i)     = rho_cp*V(i)/dt * T_alloy_old(i);

        elseif i == N
            % --- Outer surface: convection with furnace ---
            alpha(i) = rho_cp*V(i)/dt + k/dr * Aw + h_f_al * Ae;
            gamma(i-1) = -k/dr * Aw;
            b(i)     = rho_cp*V(i)/dt * T_alloy_old(i) + h_f_al * Ae * T_furnace;

        else
            % --- Internal nodes ---
            De = k*Ae/dr;
            Dw = k*Aw/dr;

            alpha(i)   = rho_cp*V(i)/dt + De + Dw;
            gamma(i-1) = -Dw;
            beta(i)    = -De;
            b(i)       = rho_cp*V(i)/dt * T_alloy_old(i);
        end
    end

    % Solve system (Thomas algorithm for tridiagonal)
    T_alloy_new = Thomas_Solver(gamma, alpha, beta, b);
end