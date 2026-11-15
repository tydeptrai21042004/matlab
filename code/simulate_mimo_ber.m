function r = simulate_mimo_ber(p)
% SIMULATE_MIMO_BER  Monte Carlo for BPSK Rayleigh MIMO spatial multiplexing.
% Author(s): [Insert authors and student IDs before submission].
% An independent H is drawn per fading block. All detectors receive the
% SAME bits, H and complex noise in each block (paired comparison).
%
% Errors within a block are correlated. Cluster/independent-fade robust SE:
%  SE(BER) = sqrt(B/(B-1) * sum_b (e_b-BER*n_b)^2) / sum_b n_b.
% This avoids pretending that all bits within one fading block are iid.

    rng(p.seed, 'twister');
    methods = {'ZF','MMSE','MRC'};
    nMethods = numel(methods);
    nSnr = numel(p.snrDb);
    nConfigs = numel(p.NrList);

    r.p = p;
    r.methods = methods;
    r.ber = zeros(nMethods,nSnr,nConfigs);
    r.berSE = zeros(nMethods,nSnr,nConfigs);
    r.berCI95Low = zeros(nMethods,nSnr,nConfigs);
    r.berCI95High = zeros(nMethods,nSnr,nConfigs);
    r.relativeCIHalfWidth = NaN(nMethods,nSnr,nConfigs);
    r.errors = zeros(nMethods,nSnr,nConfigs);
    r.bits = zeros(nSnr,nConfigs);
    r.blocks = zeros(nSnr,nConfigs);
    r.seconds = zeros(nSnr,nConfigs);
    r.zfTheory = zeros(nSnr,nConfigs);
    r.meanSinrDb = zeros(nMethods,nSnr,nConfigs);
    r.maxBudgetReached = false(nSnr,nConfigs);
    r.precisionTargetMet = false(nMethods,nSnr,nConfigs);

    for c = 1:nConfigs
        Nr = p.NrList(c);
        d = Nr-p.Nt+1;
        fprintf('\n=== MIMO %d x %d (ZF diversity order %d) ===\n',p.Nt,Nr,d);

        for s = 1:nSnr
            gamma = 10^(p.snrDb(s)/10);
            N0 = p.Es/gamma;
            errors = zeros(nMethods,1);
            sumErrorSquared = zeros(nMethods,1);
            sumErrorTimesBits = zeros(nMethods,1);
            sumBitSquared = 0;
            totalBits = 0;
            nBlocks = 0;
            sumSinrDb = zeros(nMethods,1);
            stopwatch = tic;

            while totalBits < p.maxBits
                symbolsLeft = floor((p.maxBits-totalBits)/p.Nt);
                K = min(p.blockSymbols, symbolsLeft);
                if K < 1
                    break;
                end

                bits = randi([0,1],p.Nt,K);
                X = 2*double(bits)-1;
                H = (randn(Nr,p.Nt)+1i*randn(Nr,p.Nt))/sqrt(2);
                Z = sqrt(N0/2)*(randn(Nr,K)+1i*randn(Nr,K));
                Y = H*X+Z;
                [Wzf,Wmmse,Wmrc] = mimo_filters(H,N0);
                weights = {Wzf,Wmmse,Wmrc};

                blockBits = numel(bits);
                for m = 1:nMethods
                    detected = real(weights{m}*Y) >= 0;
                    blockErrors = nnz(detected ~= logical(bits));
                    errors(m) = errors(m)+blockErrors;
                    sumErrorSquared(m) = sumErrorSquared(m)+blockErrors^2;
                    sumErrorTimesBits(m) = sumErrorTimesBits(m)+blockErrors*blockBits;
                    sinr = mimo_post_sinr(weights{m},H,N0);
                    sumSinrDb(m) = sumSinrDb(m)+mean(10*log10(sinr));
                end
                sumBitSquared = sumBitSquared+blockBits^2;
                totalBits = totalBits+blockBits;
                nBlocks = nBlocks+1;

                % The independent fading block, not a single bit, is the
                % statistical unit used for precision/stopping checks.
                if nBlocks >= p.minBlocks && ...
                        mod(nBlocks,p.checkEveryBlocks) == 0 && ...
                        all(errors >= p.minErrors)
                    berNow = errors/totalBits;
                    seNow = cluster_se(errors,sumErrorSquared, ...
                        sumErrorTimesBits,sumBitSquared,totalBits,nBlocks);
                    relNow = (1.96*seNow)./max(berNow,realmin);
                    if all(relNow <= p.targetRelHalfWidth)
                        break;
                    end
                end
            end

            ber = errors/totalBits;
            se = cluster_se(errors,sumErrorSquared,sumErrorTimesBits, ...
                sumBitSquared,totalBits,nBlocks);
            lower95 = max(0,ber-1.96*se);
            upper95 = min(1,ber+1.96*se);
            relative95 = (1.96*se)./max(ber,realmin);
            zeroObserved = (errors==0);
            if any(zeroObserved)
                % A zero sample does NOT support a zero-width CI. The
                % exact one-sided 95% bound on the probability that a
                % fading block has any errors is 1-0.05^(1/nBlocks).
                % The BER cannot exceed that event probability.
                se(zeroObserved) = NaN;
                lower95(zeroObserved) = 0;
                upper95(zeroObserved) = 1-0.05^(1/nBlocks);
                relative95(zeroObserved) = Inf;
            end

            r.errors(:,s,c) = errors;
            r.ber(:,s,c) = ber;
            r.berSE(:,s,c) = se;
            r.berCI95Low(:,s,c) = lower95;
            r.berCI95High(:,s,c) = upper95;
            r.relativeCIHalfWidth(:,s,c) = relative95;
            r.bits(s,c) = totalBits;
            r.blocks(s,c) = nBlocks;
            r.seconds(s,c) = toc(stopwatch);
            r.meanSinrDb(:,s,c) = sumSinrDb/nBlocks;
            r.zfTheory(s,c) = zf_bpsk_theory(gamma,d);
            r.maxBudgetReached(s,c) = totalBits >= p.maxBits;
            r.precisionTargetMet(:,s,c) = ...
                (errors >= p.minErrors) & (relative95 <= p.targetRelHalfWidth);

            fprintf(['Es/N0=%+3g dB | bits=%9d | fades=%6d | ', ...
                'BER(ZF/MMSE/MRC)=%9.3g / %9.3g / %9.3g | ZF theory=%9.3g\n'], ...
                p.snrDb(s),totalBits,nBlocks,ber(1),ber(2),ber(3),r.zfTheory(s,c));
            if any(~r.precisionTargetMet(:,s,c))
                fprintf(['  Precision note: one or more detectors did not reach ', ...
                    '%d errors and <=%.0f%% relative 95%% CI half-width.\n'], ...
                    p.minErrors,100*p.targetRelHalfWidth);
            end
        end
    end
end

function se = cluster_se(errors,sumE2,sumEN,sumN2,nBits,nBlocks)
    if nBlocks < 2 || nBits == 0
        se = NaN(size(errors));
        return;
    end
    ber = errors/nBits;
    residualSumSquares = sumE2-2*ber.*sumEN+ber.^2*sumN2;
    se = sqrt(nBlocks/(nBlocks-1)*max(0,residualSumSquares))/nBits;
end
