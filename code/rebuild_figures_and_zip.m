function zipFile = rebuild_figures_and_zip(profile)
% REBUILD_FIGURES_AND_ZIP  Re-export from a saved MAT without rerunning MC.
% Author(s): [Insert authors and student IDs before submission].
% Useful if a previous MATLAB run produced correct data but 0-byte images.

    if nargin < 1 || isempty(profile), profile='full'; end
    p = mimo_parameters(profile);
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    matPath = fullfile(rootDir,p.resultFolder, ...
        ['mimo_',p.profile,'_results.mat']);
    if exist(matPath,'file') ~= 2
        error('Missing simulation MAT file: %s',matPath);
    end
    loaded = load(matPath,'r');
    if ~isfield(loaded,'r')
        error('MAT file has no result structure r.');
    end
    r = loaded.r;
    if ~isfield(r,'berSE')
        error(['MAT file is from the older code without cluster-aware SE. ', ...
            'Run run_all_and_zip(''full'') to recompute.']);
    end
    plot_mimo_results(r,rootDir);
    validate_mimo_outputs(rootDir,profile);
    zipFile = package_mimo_results(rootDir,profile);
end
