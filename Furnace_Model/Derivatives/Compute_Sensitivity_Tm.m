function S_T = Compute_Sensitivity_Tm(t, T_m, X, u, par, beta)
%BUILD_TERMINAL_SENSITIVITY_TM
%   Liefert S_T = ∂x_end/∂T_m(1..Nt)  (Nx x Nt) für implizites Euler
%
%   t   : Zeitvektor [1 x Nt]
%   T_m : Materialtemperatur in K [1 x Nt]
%   X   : Zustände aus Vorwärtslauf, X(:,k) = x_k  [Nx x Nt]
%   u   : Parametervektor (enthält k0, E, n, eta über par.idx_*)
%   par : Struct mit M_f, M_fk, idx_* etc.
%   beta: Heizrate (Skalar); verwende 1, wenn bereits in F enthalten
%
%   Hinweis: Für implizites Euler wird bei Schritt k die Jacobi bei (x_{k+1}, T_k)
%   ausgewertet. Die letzte Spalte von S_T ist i.d.R. Null, wenn T(Nt) in
%   deinem Integrator nicht verwendet wird (k=1..Nt-1).

    Nx = size(X,1);
    Nt = numel(T_m);
    dt = diff(t);                         % [1 x (Nt-1)]
    beta_inv = 1 / beta;

    % Starte ohne Vergangenheit (keine Spalten) und baue bis Endzeit auf
    S_T = zeros(Nx, 0);

    % Indizes/Parameter aus u holen
    n   = u(par.idx_n);
    eta = u(par.idx_eta);
    E   = u(par.idx_E);
    k0  = u(par.idx_k0);

    I = eye(Nx);

    for k = 1:Nt-1
        % --- Lokale Kinetik & Ableitungen bei (x_{k+1}, T_k) ---
        Tk = T_m(k);
        xkp1 = X(:,k+1);                  % implizit: Zustand am Ende des Schritts

        [k_T, ~, ~, dk_dT] = k_fun(k0, E, Tk, 1);

        x_M = par.M_f * xkp1;
        [f_x, df_dx] = f_SZ(x_M, n, eta, 1, 0, par);

        % F_x und F_T für F = beta_inv * M_fk * ( f_x .* k_T )
        dF_dx = beta_inv * par.M_fk * diag(df_dx .* k_T) * par.M_f;  % [Nx x Nx]
        dF_dT = beta_inv * par.M_fk * (f_x .* dk_dT);                % [Nx x 1]

        A = I - dt(k) * dF_dx;             % implizit-Euler-Systemmatrix

        % a) Alte Spalten (Vergangenheit) durch Schritt propagieren
        if ~isempty(S_T)
            S_T = A \ S_T;                 % [Nx x (k-1)]
        end

        % b) Neue Spalte für aktuelle Temperaturprobe T_m(k) anhängen
        new_col = A \ (dt(k) * dF_dT);     % [Nx x 1]
        S_T = [S_T, new_col];              % [Nx x k]
    end

    % Optional: auf Nt Spalten auffüllen (letzte Spalte i.d.R. 0)
    if size(S_T,2) < Nt
        S_T(:,Nt) = 0;
    end
end