MIMO SPATIAL MULTIPLEXING - CORRECTED MATLAB PROJECT (2026)
============================================================
MATLAB R2018a or newer. Base MATLAB only; NO Communications Toolbox.
Authors: [Fill in student names / IDs before submitting].

START HERE
----------
Open MATLAB, navigate to this project's code/ folder, then run:

    run_all_and_zip('demo')  % quick smoke test; separate folders
    run_all_and_zip('full')  % complete simulation and verified ZIP

For the actual report, ALWAYS use the FULL run outputs.

One command, complete output:
    run_all_and_zip('full')

Outputs in project root:
    MIMO_ALL_RESULTS_FULL.zip         (validated ZIP, re-opened for checks)
    results/mimo_full_results.mat
    results/mimo_ber_results.csv
    results/zf_theory_validation.csv
    results/ber_target_snr_summary.csv
    results/interpretation_notes.txt
    results/run_log_full.txt
    figures/11 x PNG (300 dpi)
    figures/11 x PDF (vector 2D / image 3D)
    figures/11 x FIG (editable native MATLAB figures)

To REBUILD ONLY FIGURES from a corrected-code MAT result:
    rebuild_figures_and_zip('full')
This does NOT rerun the Monte Carlo simulation. The MAT result must have
been produced by the corrected version of simulate_mimo_ber.m.

GITHUB CLONE IN MATLAB COMMAND WINDOW
-------------------------------------
In MATLAB Drive, after YOU have uploaded/committed this corrected code
on GitHub, use these commands (paste the raw URL, not a Markdown link):

    cd('/MATLAB Drive');
    [status, message] = system('git clone https://github.com/tydeptrai21042004/matlab.git');
    assert(status == 0, '%s', message);
    cd(fullfile(pwd,'matlab','code'));
    run_all_and_zip('full');

If you already cloned the repository, update with git pull (after saving
any local edits), then cd into its code folder and run the final command.

MODEL / SNR
-----------
Y = H*X + Z, Nt=4, Nr=4,5,6. Four DIFFERENT concurrent BPSK streams.
H_ij ~ CN(0,1) independently each fading block; z_i ~ CN(0,N0).
Es=1 per transmit stream; N0=10^(-EsN0dB/10); sum Tx power=Nt=4.
The x axis is Es/N0 PER TRANSMIT STREAM, not total received SNR.
Rayleigh block fading, exact receiver CSI, perfect timing and synchronization.

ZF:  W = (H'*H)^(-1)*H'; implemented through H \\ eye(Nr) for stability.
MMSE: W = (H'*H+N0*I)^(-1)*H'; implemented using left division.
MRC/MF: W = H' (positive gain-normalized); it cannot cancel interference.
The theoretical ZF BER is exact for this BPSK, i.i.d. Rayleigh model.
The detector weights are derived and implemented without communication
receiver/equalizer functions from any specialized toolbox.

STATISTICAL PRECISION
---------------------
The full run uses:
    p.blockSymbols = 128
    p.minBlocks = 2000 (INDEPENDENT Rayleigh fades per SNR/config)
    p.minErrors = 200 (desired in EACH detector)
    p.targetRelHalfWidth = 0.20 (95% CI relative half-width target)
    p.maxBits = 40000000 (per SNR/config, maximum budget)

The algorithm can stop early only after sufficient fades, enough errors
and a confidence-interval width check, or at the bit budget. CI/SE use
independent fading blocks as clusters (not iid transmitted bits).
If the budget is exhausted with unresolved precision, output flags say so.
The 3D figures show measured curves at Nr=4,5,6 (no interpolated surface).
The 2D BER vertical limit is chosen from each figure's positive measured data.
The model enforces BPSK per-stream Es=1 throughout.
Even 40M bits cannot guarantee statistical precision for arbitrarily low BER.

FIGURE EXPORT FIX
-----------------
The original code sometimes produced 0-byte PNG/PDF images in MATLAB Online.
The corrected export_figure_checked.m tries exportgraphics (R2020a+),
then print, then saveas; waits for file completion; checks file size and
PNG/PDF binary signatures; saves a FIG; and errors if an export fails.
The final ZIP is reopened and all files checked again. There is NO silent
"success" after a 0-byte figure export.

DEMO SAFE
---------
The demo run writes results_demo/ and figures_demo/, and produces
MIMO_ALL_RESULTS_DEMO.zip. It does not overwrite full-run outputs.

SOURCE FILES
------------
code/run_all_and_zip.m         Full simulation + verified ZIP
code/run_mimo_project.m       Self-test, simulation, export, plotting
code/mimo_parameters.m        Central simulation profile
code/mimo_filters.m           ZF/MMSE/MRC matrices
code/mimo_post_sinr.m         Per-stream SINR
code/mimo_cluster_se.m        Independent-fade cluster SE
code/simulate_mimo_ber.m      Monte Carlo, block-aware uncertainty
code/zf_bpsk_theory.m         Analytical ZF BER
code/estimate_snr_threshold.m BER threshold interpolation
code/export_mimo_results.m   MAT/CSV and interpretation notes
code/plot_mimo_results.m     Eight 2D + three 3D results figures
code/export_figure_checked.m Verified PNG/PDF/FIG export
code/validate_mimo_outputs.m Checks file count, length, signatures
code/package_mimo_results.m Verified result ZIP
code/rebuild_figures_and_zip.m Re-export figures from correct MAT
code/run_self_tests.m        Analytical/unit consistency tests

REPORT AND VIDEO
----------------
HUONG_DAN_BAO_CAO.md and HUONG_DAN_THUYET_TRINH.md are guides, NOT
completed assignment deliverables. The final assignment also asks for a
15-25-page report, Slide.pdf, a 10-15-minute video and a formatted final
DAMH2026_MSSV_HoTen.zip. Follow the course's attribution/AI-use rules.

IMPORTANT LIMITATION
--------------------
No MATLAB executable is available in the ChatGPT build environment.
The code has been inspected and mathematical checks performed, but you
must execute MATLAB and verify your numerical output in MATLAB R2018+.
