function [berTable,summaryTable] = export_mimo_results(r,rootDir)
% EXPORT_MIMO_RESULTS  Save MAT/CSV, uncertainty and BER threshold summary.
% Author(s): [Insert authors and student IDs before submission].

    p = r.p;
    resultDir = fullfile(rootDir,p.resultFolder);
    if ~exist(resultDir,'dir'), mkdir(resultDir); end

    save(fullfile(resultDir,['mimo_',p.profile,'_results.mat']),'r');

    nRows = numel(p.NrList)*numel(p.snrDb);
    Nt = zeros(nRows,1); Nr = Nt; EsN0_dB = Nt;
    BER_ZF = Nt; BER_MMSE = Nt; BER_MRC = Nt; BER_ZF_theory = Nt;
    Errors_ZF = Nt; Errors_MMSE = Nt; Errors_MRC = Nt;
    BitsSimulated = Nt; FadingBlocks = Nt; TimeSeconds = Nt;
    MeanSINR_ZF_dB = Nt; MeanSINR_MMSE_dB = Nt; MeanSINR_MRC_dB = Nt;
    BER_ZF_SE = Nt; BER_MMSE_SE = Nt; BER_MRC_SE = Nt;
    BER_ZF_CI95_L = Nt; BER_ZF_CI95_U = Nt;
    BER_MMSE_CI95_L = Nt; BER_MMSE_CI95_U = Nt;
    BER_MRC_CI95_L = Nt; BER_MRC_CI95_U = Nt;
    ZF_RelCI95 = Nt; MMSE_RelCI95 = Nt; MRC_RelCI95 = Nt;
    LowErrorCount = false(nRows,1);
    PrecisionTargetMet = false(nRows,1);
    MaxBudgetReached = false(nRows,1);

    k = 0;
    for c = 1:numel(p.NrList)
        for s = 1:numel(p.snrDb)
            k = k+1;
            Nt(k) = p.Nt;
            Nr(k) = p.NrList(c);
            EsN0_dB(k) = p.snrDb(s);
            BER_ZF(k) = r.ber(1,s,c);
            BER_MMSE(k) = r.ber(2,s,c);
            BER_MRC(k) = r.ber(3,s,c);
            BER_ZF_theory(k) = r.zfTheory(s,c);
            Errors_ZF(k) = r.errors(1,s,c);
            Errors_MMSE(k) = r.errors(2,s,c);
            Errors_MRC(k) = r.errors(3,s,c);
            BitsSimulated(k) = r.bits(s,c);
            FadingBlocks(k) = r.blocks(s,c);
            TimeSeconds(k) = r.seconds(s,c);
            MeanSINR_ZF_dB(k) = r.meanSinrDb(1,s,c);
            MeanSINR_MMSE_dB(k) = r.meanSinrDb(2,s,c);
            MeanSINR_MRC_dB(k) = r.meanSinrDb(3,s,c);
            BER_ZF_SE(k) = r.berSE(1,s,c);
            BER_MMSE_SE(k) = r.berSE(2,s,c);
            BER_MRC_SE(k) = r.berSE(3,s,c);
            BER_ZF_CI95_L(k) = r.berCI95Low(1,s,c);
            BER_ZF_CI95_U(k) = r.berCI95High(1,s,c);
            BER_MMSE_CI95_L(k) = r.berCI95Low(2,s,c);
            BER_MMSE_CI95_U(k) = r.berCI95High(2,s,c);
            BER_MRC_CI95_L(k) = r.berCI95Low(3,s,c);
            BER_MRC_CI95_U(k) = r.berCI95High(3,s,c);
            ZF_RelCI95(k) = r.relativeCIHalfWidth(1,s,c);
            MMSE_RelCI95(k) = r.relativeCIHalfWidth(2,s,c);
            MRC_RelCI95(k) = r.relativeCIHalfWidth(3,s,c);
            LowErrorCount(k) = any(r.errors(:,s,c)<p.minErrors);
            PrecisionTargetMet(k) = all(r.precisionTargetMet(:,s,c));
            MaxBudgetReached(k) = r.maxBudgetReached(s,c);
        end
    end

    berTable = table(Nt,Nr,EsN0_dB,BER_ZF,BER_MMSE,BER_MRC, ...
        BER_ZF_theory,Errors_ZF,Errors_MMSE,Errors_MRC, ...
        BitsSimulated,FadingBlocks,TimeSeconds, ...
        MeanSINR_ZF_dB,MeanSINR_MMSE_dB,MeanSINR_MRC_dB, ...
        BER_ZF_SE,BER_MMSE_SE,BER_MRC_SE, ...
        BER_ZF_CI95_L,BER_ZF_CI95_U, ...
        BER_MMSE_CI95_L,BER_MMSE_CI95_U, ...
        BER_MRC_CI95_L,BER_MRC_CI95_U, ...
        ZF_RelCI95,MMSE_RelCI95,MRC_RelCI95, ...
        LowErrorCount,PrecisionTargetMet,MaxBudgetReached);
    writetable(berTable,fullfile(resultDir,'mimo_ber_results.csv'));

    RelativeError = NaN(nRows,1);
    positiveTheory = BER_ZF_theory > 0;
    RelativeError(positiveTheory) = abs(BER_ZF(positiveTheory)- ...
        BER_ZF_theory(positiveTheory))./BER_ZF_theory(positiveTheory);
    ZFTheoryWithin95CI = (BER_ZF_theory>=BER_ZF_CI95_L) & ...
        (BER_ZF_theory<=BER_ZF_CI95_U);
    ZFTheoryZScore = NaN(nRows,1);
    validSE = BER_ZF_SE>0;
    ZFTheoryZScore(validSE) = (BER_ZF(validSE)- ...
        BER_ZF_theory(validSE))./BER_ZF_SE(validSE);
    theoryTable = table(Nt,Nr,EsN0_dB,BER_ZF,BER_ZF_theory, ...
        Errors_ZF,BitsSimulated,FadingBlocks,BER_ZF_SE, ...
        BER_ZF_CI95_L,BER_ZF_CI95_U,RelativeError, ...
        ZFTheoryZScore,ZFTheoryWithin95CI);
    writetable(theoryTable,fullfile(resultDir,'zf_theory_validation.csv'));

    nSummary = numel(p.NrList)*numel(r.methods);
    Nt = repmat(p.Nt,nSummary,1);
    Nr = zeros(nSummary,1);
    Detector = cell(nSummary,1);
    TargetBER = repmat(p.targetBER,nSummary,1);
    RequiredEsN0_dB = NaN(nSummary,1);
    Observation = cell(nSummary,1);
    k = 0;
    for c = 1:numel(p.NrList)
        for m = 1:numel(r.methods)
            k = k+1;
            Nr(k) = p.NrList(c);
            Detector{k} = r.methods{m};
            curve = squeeze(r.ber(m,:,c));
            RequiredEsN0_dB(k) = estimate_snr_threshold( ...
                p.snrDb,curve,p.targetBER);
            if isnan(RequiredEsN0_dB(k))
                Observation{k} = 'No observed positive BER crossing in tested SNR range';
            else
                Observation{k} = 'Log-BER interpolation; estimated from sampled SNR grid';
            end
        end
    end
    summaryTable = table(Nt,Nr,Detector,TargetBER,RequiredEsN0_dB,Observation);
    writetable(summaryTable,fullfile(resultDir,'ber_target_snr_summary.csv'));

    fid = fopen(fullfile(resultDir,'interpretation_notes.txt'),'w');
    assert(fid>=0,'Cannot write interpretation_notes.txt');
    fprintf(fid,'MIMO SPATIAL MULTIPLEXING - INTERPRETATION NOTES\n');
    fprintf(fid,'Profile: %s; Seed: %d; Nt: %d; Nr:',p.profile,p.seed,p.Nt);
    fprintf(fid,' %d',p.NrList);
    fprintf(fid,'\n');
    fprintf(fid,'BPSK Es=1 per stream; H~CN(0,1); noise CN(0,N0); N0=10^(-EsN0dB/10).\n');
    fprintf(fid,'Perfect CSI; independent H every block of %d symbol times.\n',p.blockSymbols);
    fprintf(fid,'The plotted SNR is per-stream Es/N0, not aggregate receive SNR.\n');
    fprintf(fid,'ZF theoretical BER is exact for stated assumptions; d=Nr-Nt+1.\n');
    fprintf(fid,'MRC/MF does not eliminate co-channel interference.\n');
    fprintf(fid,'Block-aware 95%% CI uses independent fade blocks as clusters.\n');
    fprintf(fid,'Target CI relative half-width <= %.0f%%; min errors %d; max bits %d.\n', ...
        100*p.targetRelHalfWidth,p.minErrors,p.maxBits);
    fprintf(fid,'The CI is an asymptotic estimate, not a guarantee for rare events.\n');
    fprintf(fid,'ZFTheoryWithin95CI may be false for some points even if theory is correct.\n');
    fprintf(fid,'Measured BER=0 is not zero true probability; omitted from log plots.\n');
    fprintf(fid,'BER target NaN means no observed interpolation crossing.\n');
    fprintf(fid,'SINR plotted is the arithmetic average of SINR in dB across fades.\n');
    fprintf(fid,'A precision flag false means inspect uncertainty before drawing conclusions.\n');
    fclose(fid);
end
