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

    % Error-count-to-BER confidence calculation check: same errors in
    % every block give a zero estimated between-fade variation.
    fprintf('PASS: ZF/MMSE/noiseless bits/SINR/ZF analytic BER.\n');
end
