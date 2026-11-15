function se = mimo_cluster_se(errors,sumE2,sumEN,sumN2,nBits,nBlocks)
% MIMO_CLUSTER_SE  Cluster-robust standard error for BER estimates.
% Author(s): [Insert authors and student IDs before submission].
% One independent fade/block is one cluster, rather than each bit.
%
% se = sqrt(B/(B-1) * sum_b (e_b - BER*n_b)^2) / sum_b n_b.
% Supports vector inputs, one component per detector.

    if nBlocks < 2 || nBits <= 0
        se = NaN(size(errors));
        return;
    end
    ber = errors/nBits;
    residualSumSquares = sumE2 - 2*ber.*sumEN + ber.^2*sumN2;
    se = sqrt(nBlocks/(nBlocks-1)*max(0,residualSumSquares))/nBits;
end
