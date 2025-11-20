function x_repaired = Repair_Mechanical_Fmincon(x, furnace_model, constraints)
    fun = @(x_) 0.5 * norm(x_ - x)^2;
    nonlcon = @(x_) Nonlinear_Mech_Constraints(x_, furnace_model, constraints);
    opts = optimoptions('fmincon','Display','none','Algorithm','sqp',...
                        'MaxIterations',100,'OptimalityTolerance',1e-6,...
                        'StepTolerance',1e-8);
    [x_repaired,~,exitflag] = fmincon(fun,x,[],[],[],[],[],[],nonlcon,opts);
    if exitflag <= 0
        warning('Mechanical projection repair failed — keeping current iterate.');
        x_repaired = x;
    end
end

function [c,ceq] = Nonlinear_Mech_Constraints(x,furnace_model,constraints)
    N = furnace_model.model.N;
    T_f = x(1:N); alpha = x(N+1:2*N); t_total = x(end);
    M = Get_Or_Run_Simulation(x, furnace_model).mechanical_properties;
    c = [constraints.YS_min  - M.YS(end);
         constraints.UTS_min - M.UTS(end);
         constraints.UE_min  - M.UE(end)];
    ceq = [];
end
