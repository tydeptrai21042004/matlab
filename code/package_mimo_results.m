function zipFile = package_mimo_results(rootDir,profile)
% PACKAGE_MIMO_RESULTS  Verify all outputs, zip them, and verify the archive.
% Author(s): [Insert authors and student IDs before submission].

    if nargin < 2, profile='full'; end
    p = mimo_parameters(profile);
    validate_mimo_outputs(rootDir,profile);
    zipFile = fullfile(rootDir,['MIMO_ALL_RESULTS_',upper(profile),'.zip']);
    if exist(zipFile,'file'), delete(zipFile); end
    zip(zipFile,{p.resultFolder,p.figureFolder},rootDir);

    d = dir(zipFile);
    if isempty(d) || d(1).bytes <= 1000
        error('MIMO:BadArchive','ZIP was not saved correctly: %s',zipFile);
    end

    % Verify real archive contents, not merely a nonzero ZIP placeholder.
    verifyDir = tempname;
    mkdir(verifyDir);
    cleanupVerify = onCleanup(@() safe_remove(verifyDir)); %#ok<NASGU>
    unzip(zipFile,verifyDir);
    validate_mimo_outputs(verifyDir,profile);
    fprintf('PASS: ZIP extracted and all expected exports validated.\n');
    fprintf('FINAL RESULT ZIP: %s\n',zipFile);
end

function safe_remove(folder)
    if exist(folder,'dir'), rmdir(folder,'s'); end
end
