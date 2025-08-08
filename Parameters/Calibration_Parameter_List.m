function parameter_list = Calibration_Parameter_List()
    % Stores all of the possible calibration parameters

    parameter_list = {
        'epsilon_w';                  
        'Cp_alloy';                   
        'mass_alloy';                 
        'A_alloy';                    
        'h_f_w';                      
        'h_ms_f';                     
        'h_f_al';                     
        'h_h_f';                      
        'h_out';                      
        'epsilon_ms';                 
        'Cp_f';                       
        'Cp_ms';                      
        'mass_ms';                    
        'Cp_wall1';                   
        'Cp_wall2';                   
        'lambda_wall1';               
        'lambda_wall2';               
        'rho_wall1';                  
        'rho_wall2';                  
        'n_heaters';    
        'mass_h';
        'A_h';
        'Kp';                         
        'Ki';                         
        'Kd'                          
    };
end