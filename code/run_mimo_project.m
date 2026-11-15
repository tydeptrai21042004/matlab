function results = run_mimo_project(profile)
% RUN_MIMO_PROJECT  Self-test, simulation, output tables and checked plots.
% Author(s): [Insert authors and student IDs before submission].
%   run_mimo_project('demo') : smoke test only, separate output folders.
%   run_mimo_project('full') : report-quality full run.
%   run_all_and_zip('full')  : full run + verified output ZIP.

    if nargin<1 || isempty(profile), profile='full'; end
    p = mimo_parameters(profile);
    codeDir = fileparts(mfilename('fullpath'));
    rootDir = fileparts(codeDir);
    resultDir = fullfile(rootDir,p.resultFolder);
    figureDir = fullfile(rootDir,p.figureFolder);
    if ~exist(resultDir,'dir'),mkdir(resultDir);end
    if ~exist(figureDir,'dir'),mkdir(figureDir);end

    diary('off');
    logFile = fullfile(resultDir,['run_log_',p.profile,'.txt']);
    diary(logFile);
    diaryCleaner = onCleanup(@() diary('off')); %#ok<NASGU>

    fprintf('MIMO SPATIAL MULTIPLEXING 2026 - %s\n',upper(p.profile));
    fprintf('MATLAB version: %s\n',version);
    fprintf('No Communications Toolbox used.\n');
    fprintf('Y=H*X+Z; Rayleigh H; BPSK Es=1; complex AWGN CN(0,N0).\n');
    fprintf('Per-stream Es/N0(dB) horizontal axis; Nt=%d; Nr =',p.Nt);
    fprintf(' %d',p.NrList);
    fprintf('\n');
    fprintf('Seed=%d; min fades=%d; min errors=%d; max bits=%d.\n', ...
        p.seed,p.minBlocks,p.minErrors,p.maxBits);
    fprintf('Desired relative 95%% CI half-width <= %.0f%%.\n\n', ...
        100*p.targetRelHalfWidth);

    run_self_tests();
    results = simulate_mimo_ber(p);
    allMet = squeeze(all(results.precisionTargetMet,1));
    countMet = nnz(allMet);
    countTotal = numel(allMet);
    fprintf('\nPrecision target met: %d/%d SNR/configuration cases.\n', ...
        countMet,countTotal);
    if countMet < countTotal
        for c = 1:numel(p.NrList)
            for s = 1:numel(p.snrDb)
                if ~allMet(s,c)
                    fprintf('  Unresolved: Nr=%d, Es/N0=%+g dB.\n', ...
                        p.NrList(c),p.snrDb(s));
                end
            end
        end
    end
    [~,summaryTable] = export_mimo_results(results,rootDir);
    plot_mimo_results(results,rootDir);

    % Never report success if any output image was empty or invalid.
    validate_mimo_outputs(rootDir,p.profile);

    fprintf('\nBER target %.1e: interpolated SNR thresholds (dB)\n',p.targetBER);
    disp(summaryTable(:,{'Nr','Detector','RequiredEsN0_dB'}));
    fprintf('PASS: all 11 PNG, all 11 PDF, all 11 FIG files verified.\n');
    fprintf('Data folder: %s\nFigure folder: %s\n',resultDir,figureDir);
    if strcmp(p.profile,'demo')
        fprintf('WARNING: demo results are NOT for the final report.\n');
    end
end
