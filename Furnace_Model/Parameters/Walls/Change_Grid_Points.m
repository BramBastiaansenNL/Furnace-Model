function fm = Change_Grid_Points(fm, Nx)
    %% Function to change the number of grid points in the furnace walls.
    
    % Change the number of grid points and time-steps
    fm.walls.Nx = Nx;
    fm.walls.dt = fm.model.dt;

    % Different walls
    fm.walls.side1 = Wall_Side(fm.walls);
    fm.walls.side2 = Wall_Side(fm.walls);
    fm.walls.top   = Wall_Top(fm.walls);
    fm.walls.bottom = Wall_Bottom(fm.walls);
    fm.walls.front = Wall_Front(fm.walls);
    fm.walls.back  = Wall_Back(fm.walls);
end