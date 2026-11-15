function [Wzf, Wmmse, Wmrc] = mimo_filters(H, N0)
% MIMO_FILTERS  ZF, MMSE and MRC/matched-filter weights from the formulas.
% Author(s): [Add group members and student IDs].
% No communications toolbox or built-in equalizer is used.
% H: Nr-by-Nt, W: Nt-by-Nr, N0: noise variance per complex Rx sample.

    Nt = size(H, 2);
    Gram = H' * H;
    Hh = H';

    % Never use inv(Gram): the backslash solves the equivalent systems.
    Wzf = Gram \ Hh;
    Wmmse = (Gram + N0*eye(Nt)) \ Hh;

    % For spatial multiplexing, MRC is a matched filter, NOT interference-
    % cancelling diversity combining. Its other streams remain interference.
    % Desired gain h_i^H*h_i is real and positive, so normalization leaves
    % hard BPSK decisions unchanged while fixing the output amplitude.
    channelGains = real(diag(Gram));
    Wmrc = bsxfun(@rdivide, Hh, channelGains);
end
