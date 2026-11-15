function results = run_mimo_project(profile)
% RUN_MIMO_PROJECT  Entry point for the 2026 MIMO spatial-multiplexing BTL.
% Author(s): [Add group members and student IDs].
%
%   run_mimo_project('demo')  Fast end-to-end run (NOT report-quality BER).
%   run_mimo_project('full')  Full Monte Carlo run for the final report.
%   run_mimo_project          Equivalent to 'full'.
%
% MATLAB R2018a+; base MATLAB only. All detectors are programmed from
% matrix formulas. Do not use Communications Toolbox equalizer functions.

    if nargin < 1 || isempty(profile)
        profile = 'full';
    end
    p = mimo_parameters(profile);
    scriptDir = fileparts(mfilename('fullpath'));
    projectRoot = fileparts(scriptDir);
    resultDir = fullfile(projectRoot, 'results');
    if ~exist(resultDir,'dir')
        mkdir(resultDir);
    end
    if ~exist(fullfile(projectRoot,'figures'),'dir')
        mkdir(fullfile(projectRoot,'figures'));
    end

    logFile = fullfile(resultDir,['run_log_',p.profile,'.txt']);
    diary('off');
    diary(logFile);
    diaryCleanup = onCleanup(@() diary('off')); %#ok<NASGU>

    fprintf('MIMO SPATIAL MULTIPLEXING 2026 - %s PROFILE\n',upper(p.profile));
    fprintf('MATLAB version: %s\n',version);
    fprintf('No Communications Toolbox required.\n');
    fprintf('Model: Y=H*X+Z; iid Rayleigh H, BPSK Es=1, AWGN CN(0,N0).\n');
    fprintf('Horizontal axis: per-stream Es/N0 (dB).\n');
    fprintf('Nr cases:'); fprintf(' %d',p.NrList); fprintf('; Nt=%d.\n',p.Nt);
    fprintf('Block fading; independent channels across blocks; perfect CSI.\n');
    fprintf('Seed=%d, minimum fades=%d, target errors=%d, bit budget=%d.\n\n', ...
        p.seed,p.minBlocks,p.minErrors,p.maxBits);

    run_self_tests();
    results = simulate_mimo_ber(p);
    [~, summaryTable] = export_mimo_results(results,projectRoot);
    plot_mimo_results(results,projectRoot);

    fprintf('\nTarget BER = %.1e, estimated Es/N0 thresholds:\n',p.targetBER);
    disp(summaryTable(:,{'Nr','Detector','RequiredEsN0_dB'}));
    fprintf('\nDONE. Numerical data: %s\n',resultDir);
    fprintf('Figures (PNG + vector PDF): %s\n',fullfile(projectRoot,'figures'));
    if strcmp(p.profile,'demo')
        fprintf('WARNING: demo has a small bit budget. Run ''full'' for the report.\n');
    end
end
