function [Wzf, Wmmse, Wmrc] = mimo_filters(H, N0)
% MIMO_FILTERS  Hand-coded linear detection matrices, no equalizer toolbox.
% Author(s): [Insert authors and student IDs before submission].
% H is Nr-by-Nt; W matrices are Nt-by-Nr.
% ZF formula: (H'*H)^(-1)*H'; MATLAB \ uses QR for better stability.
% MMSE: (H'*H + N0*I)^(-1)*H'; MRC/MF: per-column matched filter.

    [Nr,Nt] = size(H);
    if Nr < Nt || N0 < 0
        error('Require Nr>=Nt and N0>=0.');
    end
    Hh = H';
    Gram = Hh*H;

    % Numerically better than explicitly forming inv(H'*H)*H'.
    Wzf = H \ eye(Nr);
    Wmmse = (Gram + N0*eye(Nt)) \ Hh;

    desiredGain = real(diag(Gram));
    Wmrc = bsxfun(@rdivide, Hh, max(desiredGain, eps));
end
