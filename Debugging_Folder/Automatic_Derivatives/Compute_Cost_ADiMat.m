function [J] = Compute_Cost_ADiMat(x)
    J = x^2;
end
%     % Use persistent variables to store the fixed inputs
%     persistent fm constraints N
% 
%     if isempty(fm)
%         fm = Furnace_Model();       % your actual furnace_model struct
%         constraints = Model_Constraints();  % your constraints struct/array
%         N = 3;                 % number of steps
%     end
% 
%     % Call your original cost function
%     J = Compute_Cost_Function(x, fm, constraints, N);
% end
