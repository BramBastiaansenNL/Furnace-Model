function Add_Paths2()
    % Adds required directories to MATLAB path dynamically for Bram_Master_Thesis

    % Get current file's directory
    scriptDir = fileparts(mfilename('fullpath'));
    
    % Traverse up to Bram_Master_Thesis directory
    repoRoot = scriptDir;
    while ~endsWith(repoRoot, 'Bram_Master_Thesis') && ~strcmp(repoRoot, filesep)
        repoRoot = fileparts(repoRoot);
    end
    
    % Check if we found the root
    if ~endsWith(repoRoot, 'Bram_Master_Thesis')
        error('Bram_Master_Thesis root directory not found.');
    end

    % Define parent directory that contains Bram_Master_Thesis and others
    parentDir = fileparts(repoRoot);
    
    % Define paths relative to Bram_Master_Thesis root
    furnaceModelPath = fullfile(repoRoot, 'Furnace_Model');
    furnaceOptPath = fullfile(repoRoot, 'Furnace_Optimization');
    furnaceDebuggingPath = fullfile(repoRoot, 'Debugging_Folder');

    % Define paths located one level up in 'calculations' or similar
    zugprobenPath = fullfile(parentDir, '02_Data_Analysis', 'Zugproben');
    optimalControlPath = fullfile(parentDir, 'Optimal_Control');
    mathModelPath = fullfile(parentDir, 'Mathematical_Model_new');
    generalFuncsPath = fullfile(parentDir, 'General_Functions');
    
    % Add paths
    addpath(genpath(furnaceModelPath));
    addpath(genpath(furnaceOptPath));
    addpath(genpath(furnaceDebuggingPath));
    
    addpath(genpath(zugprobenPath));
    addpath(genpath(optimalControlPath));
    addpath(genpath(mathModelPath));
    addpath(genpath(generalFuncsPath));
    
    disp('Paths added successfully for Bram_Master_Thesis.');
end