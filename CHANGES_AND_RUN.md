# Corrected MATLAB MIMO project — changes and execution

## Fixed from the uploaded `matlab-main.zip`

1. **Empty figures:** replaced unchecked `print()` with a robust `exportgraphics` (MATLAB R2020a+) → `print()` → `saveas()` sequence, checking file sizes and PNG/PDF signatures before accepting exports.
2. **Reproducible archive:** the result ZIP is automatically generated, extracted into a temporary directory, and rechecked. A missing/0-byte figure now fails explicitly instead of printing `ALL EXPERIMENTS COMPLETED`.
3. **Statistical precision:** Monte Carlo uses at least 2,000 independent fading blocks in `full` mode; stopping requires sufficient observed errors and an approximate 95% confidence-interval half-width no greater than 20%, subject to a cap of 16 million bits per SNR and antenna configuration. Confidence intervals treat fading blocks, not individual bits, as independent clusters.
4. **Zero observed errors:** does not claim zero true BER or a zero-width confidence interval. Outputs are clearly flagged as unresolved where simulation budget is insufficient.
5. **Compatibility:** ZF uses `H \ eye(Nr)` (numerically more stable than solving the normal equations); BPSK and Rayleigh/AWGN and MMSE/MRC definitions are unchanged.
6. **Safe `demo` mode:** demo saves to `results_demo/` and `figures_demo/` instead of overwriting full-run outputs.
7. **Additional outputs:** 95% confidence intervals, relative CI widths, and theoretical-BER validation scores added to CSVs. Standard eight BER/SINR plots are still generated.

## Run from inside `code/` in MATLAB

```matlab
run_all_and_zip('demo')
run_all_and_zip('full')
```

To regenerate figures from an **existing corrected-version** `results/mimo_full_results.mat` without rerunning the simulation:

```matlab
rebuild_figures_and_zip('full')
```

`MIMO_ALL_RESULTS_FULL.zip` appears in the project root after a successful full run. Its contents are verified as nonempty and in valid PNG/PDF formats.

## Limitations

- MATLAB is not installed in the environment used to prepare these files. Do an actual `demo` test followed by a `full` run on your MATLAB installation.
- The software package is not a substitute for the required original report, slide PDF, presentation video, and proper disclosure of external/AI assistance under the assignment.
