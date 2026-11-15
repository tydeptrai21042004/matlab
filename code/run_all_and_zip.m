function zipFile = run_all_and_zip(profile)
% RUN_ALL_AND_ZIP  The only command needed for simulation and final ZIP.
% Author(s): [Insert authors and student IDs before submission].
%
% From the code/ directory:
%   run_all_and_zip('demo')  % quick check, separate outputs
%   run_all_and_zip('full')  % all actual experiments, figures and ZIP

    if nargin < 1 || isempty(profile), profile='full'; end
    run_mimo_project(profile);
    rootDir = fileparts(fileparts(mfilename('fullpath')));
    zipFile = package_mimo_results(rootDir,profile);
end
