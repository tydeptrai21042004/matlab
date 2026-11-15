MIMO - PDF EXPORT & VALIDATION FIX (2026-11-15)
============================================
Source: matlab-main-3D-figures.zip (8 x 2D figures + 3 x 3D figures).

Problem observed on MATLAB R2026b Update 2 / MATLAB Drive:
   Invalid image format: Fig_Detectors_4x6.pdf

This patch only changes two files inside code/:
   export_figure_checked.m
   validate_mimo_outputs.m

Fixes:
- Export first in local tempdir, validate, copy then finalize in figures/.
- For 3D surface PDF: raster ContentType at 300 DPI (avoids vector warnings).
- PDF signature check searches first 1024 bytes for %%PDF- and checks %%EOF.
- Diagnostic error reports actual first bytes in hexadecimal if invalid.
- No modification of BER data, mathematical model, plots or simulation code.

IMPORTANT: Apply patch to the MATLAB Drive clone used for the run.
MATLAB command (from folder matlab-main/code):
   rebuild_figures_and_zip('full')

This REUSES the saved results/mimo_full_results.mat and does not rerun
Monte Carlo. If simulation results file is absent, do a full run:
   run_all_and_zip('full')

zip result: matlab-main/MIMO_ALL_RESULTS_FULL.zip

Source code was inspected and patched but MATLAB itself is not installed in
the editing environment. Please test exports in MATLAB R2026b before submission.
