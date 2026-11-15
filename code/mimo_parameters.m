function p = mimo_parameters(profile)
% MIMO_PARAMETERS  Central settings. MATLAB R2018a+; base MATLAB only.
% Author(s): [Insert authors and student IDs before submission].
%
% Y = H*X + Z, H_ij ~ CN(0,1), z_i ~ CN(0,N0), X_ij in {-1,+1}.
% Per-stream Es=1, so Es/N0 = 1/N0 (not the total Nt*Es/N0).

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
    p.fading = 'Independent block Rayleigh CN(0,1)';
    p.powerPolicy = 'Unit energy per Tx stream; Nt held fixed';

    switch p.profile
        case 'full'
            % One independent fading matrix per block of 128 time slots.
            % At least 2000 independent blocks per Es/N0 point; adaptively
            % continue until the block-aware 95% CI is sufficiently narrow,
            % if possible within the bit budget. No fabricated BER floors.
            p.blockSymbols = 128;
            p.minBlocks = 2000;
            p.minErrors = 200;
            p.maxBits = 40000000;
            p.targetRelHalfWidth = 0.20;
            p.checkEveryBlocks = 100;
        case 'demo'
            % Only for a fast code/output smoke test, NOT for reporting BER.
            p.blockSymbols = 64;
            p.minBlocks = 30;
            p.minErrors = 20;
            p.maxBits = 50000;
            p.targetRelHalfWidth = 0.50;
            p.checkEveryBlocks = 10;
        otherwise
            error('Profile must be ''demo'' or ''full''.');
    end

    p.resultFolder = 'results';
    p.figureFolder = 'figures';
    if strcmp(p.profile, 'demo')
        p.resultFolder = 'results_demo';
        p.figureFolder = 'figures_demo';
    end

    if p.Nt < 2 || numel(p.NrList) < 3 || any(p.NrList < p.Nt)
        error('Require Nt>=2 and at least 3 receive configurations with Nr>=Nt.');
    end
    % The entire receiver/SINR implementation assumes BPSK Es = 1.
    % Do not silently change only N0 while transmitted symbols remain +/-1.
    if ~isscalar(p.Es) || ~isfinite(p.Es) || p.Es ~= 1
        error('MIMO:InvalidEs', ...
            'This BPSK implementation requires p.Es = 1.');
    end
    if p.minBlocks < 2 || p.maxBits < p.Nt*p.blockSymbols
        error('Invalid Monte Carlo settings.');
    end
    if p.targetRelHalfWidth <= 0 || p.targetRelHalfWidth >= 1
        error('targetRelHalfWidth must be in (0,1).');
    end
end
