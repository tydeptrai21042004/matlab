function Pb = zf_bpsk_theory(EsN0, diversityOrder)
% ZF_BPSK_THEORY  Exact average bit error probability for BPSK + ZF.
% Author(s): [Add group members and student IDs].
%
% Assumptions: Nr >= Nt, i.i.d. CN(0,1) Rayleigh H, perfect CSI,
% independent BPSK symbols of energy Es=1, z ~ CN(0,N0*I).
% gamma_ZF ~ Gamma(shape=d, scale=Es/N0) with d=Nr-Nt+1.
% Pb = (1/pi) * integral_0^(pi/2) (1+EsN0/sin(t)^2)^(-d) dt.
% Below is the finite sum (valid for integer d >= 1).

    if ~isscalar(EsN0) || EsN0 <= 0 || diversityOrder < 1 || ...
            diversityOrder ~= floor(diversityOrder)
        error('EsN0 must be positive and diversityOrder must be a positive integer.');
    end

    mu = sqrt(EsN0/(1 + EsN0));
    a = (1 - mu)/2;
    b = (1 + mu)/2;
    factor = 0;
    for k = 0:diversityOrder-1
        factor = factor + nchoosek(diversityOrder-1+k, k)*b^k;
    end
    Pb = a^diversityOrder*factor;
end
