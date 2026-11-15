MATLAB MIMO - 3D FIGURE PATCH
===========================
Replace these three existing files inside matlab-main/code/:
  plot_mimo_results.m
  validate_mimo_outputs.m
  run_mimo_project.m

Keeps the eight original 2D figures with improved line colors/weights.
Adds three 3D figures: ZF, MMSE, MRC BER versus SNR and Nr.
Validates all 11 figures as PNG, PDF, FIG.

Existing corrected full simulation data:
  cd matlab-main/code
  rebuild_figures_and_zip('full')

No saved data / full run needed:
  run_all_and_zip('full')

Do not use demo figures in the submitted report.
No MATLAB run was possible in the editing environment, so execute
in MATLAB and verify the exported plots before submitting.
