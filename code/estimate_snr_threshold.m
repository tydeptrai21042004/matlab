function snrValue = estimate_snr_threshold(snrDb, berCurve, targetBer)
% ESTIMATE_SNR_THRESHOLD  BER-target crossing via log(BER) interpolation.
% Author(s): [Add group members and student IDs].
% Returns NaN when the measured positive BER curve gives no valid crossing.
% A measured zero is NOT treated as BER=0 or a valid interpolation endpoint.

    snrValue = NaN;
    for k = 2:numel(snrDb)
        left = berCurve(k-1);
        right = berCurve(k);
        if left > targetBer && right > 0 && right <= targetBer
            logLeft = log10(left);
            logRight = log10(right);
            if abs(logRight-logLeft) > eps
                snrValue = snrDb(k-1) + (snrDb(k)-snrDb(k-1)) * ...
                    (log10(targetBer)-logLeft)/(logRight-logLeft);
            end
            return;
        end
    end
end
