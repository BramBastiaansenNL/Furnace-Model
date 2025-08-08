function fm = Remove_Alloy(fm)
    %% Function to remove the presence of the alloy from the furnace simulation
    
    % Set the convective heat transfer from furnace air to alloy to zero
    fm.furnace.h_f_al = 0;
    fm.constants.h_f_aA_a = 0;
end