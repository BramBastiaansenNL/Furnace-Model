function [T_f_generated, fm] = Generate_Desired_Temperature_Curve(T_f_desired, t, fm, alpha)
    %% Main wrapper: dispatch to AD or non-AD version
    
    if isfield(fm.settings,'automatic_differentiation') && fm.settings.automatic_differentiation
        [T_f_generated, fm] = Generate_Desired_Temperature_Curve_AD(T_f_desired, t, fm, alpha);
    else
        [T_f_generated, fm] = Generate_Desired_Temperature_Curve_Num(T_f_desired, t, fm, alpha);
    end
end