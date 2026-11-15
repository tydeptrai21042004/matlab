function run_self_tests()
% RUN_SELF_TESTS  Consistency checks, no Communications Toolbox required.
% Author(s): [Add group members and student IDs].
% These checks do not replace verifying the final Monte Carlo plots.

    rng(7, 'twister');
    Nt = 4; Nr = 6;
    H = (randn(Nr,Nt) + 1i*randn(Nr,Nt))/sqrt(2);
    bits = randi([0,1],Nt,100);
    X = 2*double(bits) - 1;
    [Wzf, Wmmse0, ~] = mimo_filters(H, 0);
    e = Wzf*H - eye(Nt);
    assert(norm(e,'fro') < 1e-10, 'ZF does not invert a full-rank channel.');
    assert(norm(Wzf-Wmmse0,'fro') < 1e-10, ...
        'MMSE with N0=0 must coincide with ZF.');
    assert(nnz((real(Wzf*(H*X)) >= 0) ~= logical(bits)) == 0, ...
        'Noise-free ZF should recover all BPSK bits.');

    N0 = 0.3;
    [W1, W2, W3] = mimo_filters(H, N0);
    for W = {W1, W2, W3}
        sinr = mimo_post_sinr(W{1},H,N0);
        assert(all(isfinite(sinr)) && all(sinr > 0), ...
            'Expected finite positive post-filter SINR.');
    end

    % Exact closed-form BER and independently evaluated Craig integral.
    for d = 1:3
        gamma = 2.5;
        exactValue = zf_bpsk_theory(gamma,d);
        integralValue = integral(@(t) ...
            (1 + gamma./sin(t).^2).^(-d), 0, pi/2)/pi;
        assert(abs(exactValue-integralValue) < 1e-10, ...
            'Closed-form and integral forms of ZF BER disagree.');
    end

    fprintf('PASS: ZF inversion, MMSE limit, noiseless bits, SINR and ZF BER formula.\n');
end
