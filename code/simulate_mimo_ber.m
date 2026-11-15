function r = simulate_mimo_ber(p)
% SIMULATE_MIMO_BER  Monte Carlo BPSK MIMO with independent block fading.
% Author(s): [Add group members and student IDs].
% One H and one set of bits/noise are shared by all three detectors per block.
% This paired comparison prevents algorithm-dependent random-test conditions.

    rng(p.seed, 'twister');
    methods = {'ZF', 'MMSE', 'MRC'};
    nMethod = numel(methods);
    nSnr = numel(p.snrDb);
    nConfig = numel(p.NrList);

    r.p = p;
    r.methods = methods;
    r.ber = zeros(nMethod, nSnr, nConfig);
    r.errors = zeros(nMethod, nSnr, nConfig);
    r.bits = zeros(nSnr, nConfig);
    r.blocks = zeros(nSnr, nConfig);
    r.seconds = zeros(nSnr, nConfig);
    r.zfTheory = zeros(nSnr, nConfig);
    r.meanSinrDb = zeros(nMethod, nSnr, nConfig);
    r.maxBudgetReached = false(nSnr, nConfig);

    for c = 1:nConfig
        Nr = p.NrList(c);
        d = Nr - p.Nt + 1;
        fprintf('\n=== MIMO %d x %d (ZF diversity order %d) ===\n', p.Nt, Nr, d);

        for s = 1:nSnr
            gamma = 10^(p.snrDb(s)/10);
            N0 = p.Es/gamma;
            errors = zeros(nMethod, 1);
            totalBits = 0;
            nBlocks = 0;
            sumSinrDb = zeros(nMethod, 1);
            runClock = tic;

            while (nBlocks < p.minBlocks || any(errors < p.minErrors)) ...
                    && totalBits < p.maxBits

                symbolsLeft = floor((p.maxBits - totalBits)/p.Nt);
                K = min(p.blockSymbols, symbolsLeft);
                if K < 1
                    break;
                end

                % Each Tx antenna sends its own independent BPSK symbols.
                bits = randi([0, 1], p.Nt, K);
                X = 2*double(bits) - 1;  % 0 -> -1; 1 -> +1; Es=1

                % Independent Rayleigh channel for each fading block.
                H = (randn(Nr, p.Nt) + 1i*randn(Nr, p.Nt))/sqrt(2);

                % Proper CN(0,N0) complex noise: each component has N0/2.
                Z = sqrt(N0/2)*(randn(Nr, K) + 1i*randn(Nr, K));
                Y = H*X + Z;

                [Wzf, Wmmse, Wmrc] = mimo_filters(H, N0);
                W = {Wzf, Wmmse, Wmrc};

                for m = 1:nMethod
                    Yhat = W{m}*Y;
                    bitHat = real(Yhat) >= 0;
                    errors(m) = errors(m) + nnz(bitHat ~= logical(bits));

                    sinrValue = mimo_post_sinr(W{m}, H, N0);
                    % Average per-fade, per-stream SINR measured in dB.
                    sumSinrDb(m) = sumSinrDb(m) + mean(10*log10(sinrValue));
                end

                totalBits = totalBits + numel(bits);
                nBlocks = nBlocks + 1;
            end

            r.errors(:, s, c) = errors;
            r.bits(s, c) = totalBits;
            r.blocks(s, c) = nBlocks;
            r.ber(:, s, c) = errors/totalBits;
            r.meanSinrDb(:, s, c) = sumSinrDb/nBlocks;
            r.zfTheory(s, c) = zf_bpsk_theory(gamma, d);
            r.seconds(s, c) = toc(runClock);
            r.maxBudgetReached(s, c) = totalBits >= p.maxBits;

            fprintf(['Es/N0=%+3d dB | bits=%8d | fades=%5d | ', ...
                     'BER (ZF/MMSE/MRC)=%8.3g / %8.3g / %8.3g | ZF theory=%8.3g\n'], ...
                p.snrDb(s), totalBits, nBlocks, ...
                r.ber(1,s,c), r.ber(2,s,c), r.ber(3,s,c), r.zfTheory(s,c));

            if any(errors < p.minErrors)
                fprintf('  Limited Monte Carlo precision: at least one detector has < %d errors.\n', ...
                    p.minErrors);
            end
        end
    end
end
