function run_self_tests()
% RUN_SELF_TESTS  Formula checks; no toolboxes required.
% Author(s): [Insert authors and student IDs before submission].

    rng(7,'twister');
    Nt = 4; Nr = 6;
    H = (randn(Nr,Nt)+1i*randn(Nr,Nt))/sqrt(2);
    bits = randi([0,1],Nt,100);
    X = 2*double(bits)-1;
    [Wzf,Wmmse0,~] = mimo_filters(H,0);
    assert(norm(Wzf*H-eye(Nt),'fro') < 1e-10, ...
        'ZF must invert a full-column-rank channel.');
    assert(norm(Wzf-Wmmse0,'fro') < 1e-10, ...
        'MMSE with N0=0 must agree with ZF.');
    assert(nnz((real(Wzf*(H*X))>=0) ~= logical(bits)) == 0, ...
        'Noise-free ZF failed BPSK detection.');

    N0=0.3;
    [W1,W2,W3] = mimo_filters(H,N0);
    for W = {W1,W2,W3}
        sinr = mimo_post_sinr(W{1},H,N0);
        assert(all(isfinite(sinr)) && all(sinr>0), ...
            'Post-filter SINR must be finite and positive.');
    end

    for d=1:3
        gamma=2.5;
        exactValue = zf_bpsk_theory(gamma,d);
        numerical = integral(@(t) ...
            (1+gamma./sin(t).^2).^(-d),0,pi/2)/pi;
        assert(abs(exactValue-numerical) < 1e-10, ...
            'Exact ZF BER formula differs from numerical Craig integral.');
    end

    % A direct check against independently calculated block residuals.
    e = [2,0,1,3];
    n = [8,8,8,8];
    nBlocks = numel(e);
    totalErrors = sum(e);
    totalBits = sum(n);
    directSE = sqrt(nBlocks/(nBlocks-1) * ...
        sum((e - totalErrors/totalBits*n).^2))/totalBits;
    codeSE = mimo_cluster_se(totalErrors,sum(e.^2),sum(e.*n), ...
        sum(n.^2),totalBits,nBlocks);
    assert(abs(codeSE-directSE)<1e-13, ...
        'Fade-cluster BER standard error failed its independent check.');

    % Independently fading channel realizations; this tests the complete
    % channel/noise/ZF/decision chain against the analytic BPSK result.
    % Fixed seed plus a conservative tolerance keeps this a stable test.
    rng(73,'twister');
    Nt = 4; Nr = 4; gamma = 1; N0 = 1/gamma;
    nFades = 5000;
    errors = 0;
    for k = 1:nFades
        b = randi([0,1],Nt,1);
        x = 2*double(b)-1;
        h = (randn(Nr,Nt)+1i*randn(Nr,Nt))/sqrt(2);
        z = sqrt(N0/2)*(randn(Nr,1)+1i*randn(Nr,1));
        w = h \ eye(Nr);
        errors = errors + nnz((real(w*(h*x+z))>=0) ~= logical(b));
    end
    measured = errors/(Nt*nFades);
    expected = zf_bpsk_theory(gamma,Nr-Nt+1);
    assert(abs(measured-expected) < 0.025, ...
        'Independent-fade ZF Monte Carlo does not match theoretical BER.');
    fprintf(['PASS: ZF/MMSE/noiseless bits/SINR/analytic BER/', ...
        'cluster SE/Monte Carlo regression.\n']);
end
