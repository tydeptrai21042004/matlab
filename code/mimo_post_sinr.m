function sinrLinear = mimo_post_sinr(W, H, N0)
% MIMO_POST_SINR  Instantaneous post-filter SINR for every Tx stream.
% Author(s): [Add group members and student IDs].
% x streams are uncorrelated with unit energy and z ~ CN(0,N0*I).
% SINR_i = |(WH)_ii|^2 / [sum_{j != i}|(WH)_ij|^2 + N0||W_i,:||^2].

    A = W*H;
    signalPower = abs(diag(A)).^2;
    totalSignal = sum(abs(A).^2, 2);
    interferencePower = max(0, totalSignal - signalPower);
    outputNoise = N0*sum(abs(W).^2, 2);
    sinrLinear = signalPower ./ (interferencePower + outputNoise);
end
