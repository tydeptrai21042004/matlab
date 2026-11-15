function [berTable, summaryTable] = export_mimo_results(r, rootDir)
% EXPORT_MIMO_RESULTS  Store reproducible MAT/CSV data and numeric summaries.
% Author(s): [Add group members and student IDs].

    p = r.p;
    resultDir = fullfile(rootDir, 'results');
    if ~exist(resultDir, 'dir')
        mkdir(resultDir);
    end

    % Full data: includes bit counts, channel block counts and execution time.
    save(fullfile(resultDir, 'mimo_full_results.mat'), 'r');

    nRows = numel(p.NrList)*numel(p.snrDb);
    Nt = zeros(nRows,1);
    Nr = zeros(nRows,1);
    EsN0_dB = zeros(nRows,1);
    BER_ZF = zeros(nRows,1);
    BER_MMSE = zeros(nRows,1);
    BER_MRC = zeros(nRows,1);
    BER_ZF_theory = zeros(nRows,1);
    Errors_ZF = zeros(nRows,1);
    Errors_MMSE = zeros(nRows,1);
    Errors_MRC = zeros(nRows,1);
    BitsSimulated = zeros(nRows,1);
    FadingBlocks = zeros(nRows,1);
    TimeSeconds = zeros(nRows,1);
    MeanSINR_ZF_dB = zeros(nRows,1);
    MeanSINR_MMSE_dB = zeros(nRows,1);
    MeanSINR_MRC_dB = zeros(nRows,1);
    LowErrorCount = false(nRows,1);

    index = 0;
    for c = 1:numel(p.NrList)
        for s = 1:numel(p.snrDb)
            index = index+1;
            Nt(index) = p.Nt;
            Nr(index) = p.NrList(c);
            EsN0_dB(index) = p.snrDb(s);
            BER_ZF(index) = r.ber(1,s,c);
            BER_MMSE(index) = r.ber(2,s,c);
            BER_MRC(index) = r.ber(3,s,c);
            BER_ZF_theory(index) = r.zfTheory(s,c);
            Errors_ZF(index) = r.errors(1,s,c);
            Errors_MMSE(index) = r.errors(2,s,c);
            Errors_MRC(index) = r.errors(3,s,c);
            BitsSimulated(index) = r.bits(s,c);
            FadingBlocks(index) = r.blocks(s,c);
            TimeSeconds(index) = r.seconds(s,c);
            MeanSINR_ZF_dB(index) = r.meanSinrDb(1,s,c);
            MeanSINR_MMSE_dB(index) = r.meanSinrDb(2,s,c);
            MeanSINR_MRC_dB(index) = r.meanSinrDb(3,s,c);
            LowErrorCount(index) = any(r.errors(:,s,c) < p.minErrors);
        end
    end

    berTable = table(Nt, Nr, EsN0_dB, BER_ZF, BER_MMSE, BER_MRC, ...
        BER_ZF_theory, Errors_ZF, Errors_MMSE, Errors_MRC, ...
        BitsSimulated, FadingBlocks, TimeSeconds, ...
        MeanSINR_ZF_dB, MeanSINR_MMSE_dB, MeanSINR_MRC_dB, LowErrorCount);
    writetable(berTable, fullfile(resultDir, 'mimo_ber_results.csv'));

    % Compare ZF simulation against its Rayleigh/BPSK analytical expression.
    RelativeError = NaN(nRows,1);
    for k = 1:nRows
        if BER_ZF(k) > 0 && BER_ZF_theory(k) > 0
            RelativeError(k) = abs(BER_ZF(k)-BER_ZF_theory(k))/BER_ZF_theory(k);
        end
    end
    theoryTable = table(Nt, Nr, EsN0_dB, BER_ZF, BER_ZF_theory, ...
        Errors_ZF, BitsSimulated, RelativeError);
    writetable(theoryTable, fullfile(resultDir, 'zf_theory_validation.csv'));

    nMethods = numel(r.methods);
    nSummary = numel(p.NrList)*nMethods;
    Nt = repmat(p.Nt,nSummary,1);
    Nr = zeros(nSummary,1);
    Detector = cell(nSummary,1);
    TargetBER = repmat(p.targetBER,nSummary,1);
    RequiredEsN0_dB = NaN(nSummary,1);
    Observation = cell(nSummary,1);

    index = 0;
    for c = 1:numel(p.NrList)
        for m = 1:nMethods
            index = index+1;
            Nr(index) = p.NrList(c);
            Detector{index} = r.methods{m};
            curve = squeeze(r.ber(m,:,c));
            RequiredEsN0_dB(index) = estimate_snr_threshold( ...
                p.snrDb, curve, p.targetBER);
            if isnan(RequiredEsN0_dB(index))
                Observation{index} = 'No reliable measured crossing in SNR range';
            else
                Observation{index} = 'Log-BER interpolation of measured curve';
            end
        end
    end

    summaryTable = table(Nt, Nr, Detector, TargetBER, ...
        RequiredEsN0_dB, Observation);
    writetable(summaryTable, fullfile(resultDir, 'ber_target_snr_summary.csv'));

    fid = fopen(fullfile(resultDir, 'interpretation_notes.txt'), 'w');
    if fid == -1
        error('Unable to write interpretation_notes.txt.');
    end
    fprintf(fid, 'MIMO SPATIAL MULTIPLEXING - RESULT READING NOTES\n');
    fprintf(fid, '================================================\n');
    fprintf(fid, 'Profile: %s\n', p.profile);
    fprintf(fid, 'RNG seed: %d\n', p.seed);
    fprintf(fid, 'Transmit antennas: %d; receive antennas:',p.Nt);
    fprintf(fid, ' %d',p.NrList);
    fprintf(fid,'\n');
    fprintf(fid, 'BPSK, per-stream Es=1, Rayleigh iid CN(0,1), block fading.\n');
    fprintf(fid, 'At Es/N0 = S dB, N0 = 10^(-S/10), with complex AWGN CN(0,N0).\n');
    fprintf(fid, 'Perfect CSI. Nt fixed; total mean transmitted power = Nt.\n');
    fprintf(fid, 'ZF BER theory: exact for these assumptions, d = Nr-Nt+1.\n');
    fprintf(fid, 'MRC is a matched filter and does not cancel inter-stream interference.\n');
    fprintf(fid, 'A measured BER of zero only means zero errors OBSERVED.\n');
    fprintf(fid, 'Zero samples are left blank on log-BER graphs, never replaced by a floor.\n');
    fprintf(fid, 'SINR_dB: fade-average of 10*log10(SINR) over streams and blocks.\n');
    fprintf(fid, 'LowErrorCount=true means at least one detector recorded fewer than %d errors.\n', p.minErrors);
    fprintf(fid, 'Interpolation: log10(BER) between adjacent POSITIVE measured BER points.\n');
    fprintf(fid, 'NaN required SNR means no reliable crossing was measured in this range.\n');
    fprintf(fid, 'Do not report an unsupported threshold or a measured zero BER as exact.\n');
    fprintf(fid, 'Final simulation results depend on actually running the MATLAB code.\n');
    fclose(fid);
end
