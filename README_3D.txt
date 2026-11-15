MIMO 2026 - 3D FIGURES (REVISED)
================================

The project creates 8 analytical 2D plots and 3 supplementary 3D plots.
In 3D, one plot3 trace is drawn per actually simulated receive-antenna
configuration (Nr = 4, 5, 6). Lines join SNR samples for each individual
configuration; no surfaces are interpolated between different antenna counts.

Files (PNG, PDF, FIG) in figures/:
    Fig_3D_ZF_BERLandscape
    Fig_3D_MMSE_BERLandscape
    Fig_3D_MRC_BERLandscape

3D axes: X = Es/N0 per stream (dB), Y = receive antennas Nr,
Z = log10(measured BER). No invented BER values for zero observed errors.

Run a new full experiment:        run_all_and_zip('full')
Regenerate from an existing MAT: rebuild_figures_and_zip('full')

A figures-only rebuild does NOT fix insufficient precision or upgrade
an older saved result from 16M bits to the new 40M-bit maximum.
All report-critical BER/theory comparisons are retained as 2D log plots.
