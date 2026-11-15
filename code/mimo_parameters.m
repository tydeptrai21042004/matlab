function p = mimo_parameters(profile)
% MIMO_PARAMETERS  Central configuration for the MIMO spatial-multiplexing project.
% Author(s): [Add group members and student IDs].
% MATLAB R2018a or newer; no specialized toolboxes are required.
%
% The model is y = H*x + z, where:
% H_ij ~ CN(0,1); z_i ~ CN(0,N0); x_j in {-1,+1}, E[|x_j|^2]=1.
% Therefore, Es/N0(dB) = 10*log10(1/N0), per transmitted stream.

    if nargin < 1 || isempty(profile)
        profile = 'full';
    end

    p.profile = lower(char(profile));
    p.seed = 2026;
    p.Nt = 4;
    p.NrList = [4, 5, 6];
    p.snrDb = -10:2:12;
    p.modulation = 'BPSK';
    p.Es = 1;
    p.targetBER = 1e-2;
    p.csi = 'Perfect receiver CSI';
    p.fading = 'Independent block Rayleigh (CN(0,1))';
    p.powerPolicy = 'Es=1 per Tx stream; Nt is fixed in comparisons';

    switch p.profile
        case 'full'
            % Report-quality run: up to four million transmitted bits per point.
            p.blockSymbols = 128;    % One independent H per block
            p.minBlocks = 400;      % Minimum number of independent fades
            p.minErrors = 200;      % Desired errors in EACH detector
            p.maxBits = 4000000;    % A budget cap, not a fabricated BER floor
        case 'demo'
            % Fast functional check: do not use demo BER as final evidence.
            p.blockSymbols = 64;
            p.minBlocks = 30;
            p.minErrors = 30;
            p.maxBits = 50000;
        otherwise
            error('Unknown profile. Use ''demo'' or ''full''.');
    end

    if p.Nt < 2 || numel(p.NrList) < 3 || any(p.NrList < p.Nt)
        error('Required: Nt >= 2 and at least three configurations with Nr >= Nt.');
    end
    if p.maxBits < p.Nt*p.blockSymbols || p.minBlocks < 1
        error('Invalid Monte Carlo configuration.');
    end
end
