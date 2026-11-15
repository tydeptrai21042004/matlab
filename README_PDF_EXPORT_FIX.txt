MIMO 2026 - FIGURE PDF EXPORT AND VALIDATION
=============================================

The supplied export_figure_checked.m exports PNG, PDF and native FIG files.
It uses a temporary local folder, checks file signatures, stages/copies each
output into MATLAB Drive, and verifies it after the final rename.

2D figures: prefer vector PDF export.
3D axes: export 300-DPI image-content PDF to avoid overly complex vectors.
Fallbacks: exportgraphics, print, saveas, in that order.

validate_mimo_outputs.m checks all 11 expected figures and their signatures.
It also checks the saved MAT result for valid dimensions and internally
consistent BER = counted errors / simulated bits.

run_all_and_zip('full') runs simulation, generates figures, validates output,
packages ZIP, extracts that ZIP, and validates its contents again.

An earlier PDF validation failure was due to invalid or incomplete exported
PDF content. The exporter now avoids accepting incomplete file copies.
