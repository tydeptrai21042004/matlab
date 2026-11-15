# MATLAB MIMO 2026 — code changes and usage

This is the complete updated source package based on the two files supplied
by the user (`matlab-main (1).zip` and `MIMO_ALL_RESULTS_FULL(2).zip`).

## Corrections

- Full-run Monte Carlo bit cap: 16M → **40M** per SNR/configuration. The independent-fading-block minimum, error minimum, and relative 95% CI criterion remain unchanged. This provides additional sampling for the sole unresolved configuration in the earlier data (Nr=6, 12 dB), but does not guarantee convergence.
- The unit-energy BPSK assumption is enforced (`p.Es=1`). ZF, MMSE, and MRC/MF mathematical formulas, random seed, fading model, and SNR definition remain unchanged.
- 2D BER plots use logarithmic axes adjusted to the measured **positive** BER range, avoiding 4–5 wasted decades. Dense minor grid lines are removed.
- 3D figures now consist of three **discrete** SNR–Nr–logBER curves (for Nr=4,5,6), not artificially interpolated surfaces. The filenames remain the same for report compatibility.
- The confidence interval standard-error formula was extracted to `mimo_cluster_se.m` for independent unit testing; its formula is unchanged.
- `run_self_tests.m` additionally validates standard error arithmetic and uses a fixed-seed, independent-fade ZF Monte Carlo regression against theory.
- `validate_mimo_outputs.m` continues validating all PDF/PNG files and now checks that the `.mat` BER values match error counts and bit counts.
- All 11 expected figures are still exported in `.png`, `.pdf`, and `.fig` formats.

## MATLAB Command Window

```matlab
cd('/MATLAB Drive');
repoDir = fullfile(pwd,'mimo_corrected');
if ~isfolder(repoDir)
    [status,msg] = system(sprintf('git clone https://github.com/tydeptrai21042004/matlab.git "%s"',repoDir));
else
    [status,msg] = system(sprintf('git -C "%s" pull --ff-only',repoDir));
end
assert(status==0,'Git operation failed: %s',msg);
cd(fullfile(repoDir,'code'));
zipFile = run_all_and_zip('full');
disp(zipFile);
```

For old MAT results, use `rebuild_figures_and_zip('full')` **only** to
regenerate figures; it cannot improve Monte Carlo precision. If the new
40M-bit budget is required, run `run_all_and_zip('full')` again.

## Verification caveat

MATLAB is not installed in the code-preparation container. The code and
file packaging were inspected statically, not executed in MATLAB. Run a
demo smoke test then the full simulation and inspect all generated figures.
