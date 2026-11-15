MIMO SPATIAL MULTIPLEXING - MATLAB PROJECT (2026)
================================================
Authors: [Fill in group members and student IDs before submission]
MATLAB: R2018a / R2018b or later, base MATLAB functions only.
No Communications Toolbox, Simulink, or additional toolbox required.

1. PROJECT PURPOSE
------------------
Rayleigh-fading spatial multiplexing, Nt=4 and Nr=4,5,6.
One independent BPSK stream from each transmit antenna.
Receiver detectors: Zero-Forcing (ZF), MMSE, MRC/Matched Filter.
Monte Carlo BER vs. Es/N0 and exact ZF theoretical BER comparison.

2. RUN IN MATLAB
----------------
Open MATLAB > Home > Set Path/Current Folder to the 'code' folder.
In the MATLAB Command Window type:

    run_mimo_project('demo')

This runs all three configurations and methods quickly, but is only a
functional smoke test and does not provide final-quality low BER statistics.
For results to use in your report, type:

    run_mimo_project('full')

Or simply:

    run_mimo_project

The full run may take significantly longer, depending on the computer.
The maximum bit count is limited to four million bits per SNR/configuration.

A consistent seed is used, so re-running the same profile with the same
MATLAB RNG implementation reproduces the numerical data. Execution times
are not expected to be identical.

3. FILES
--------
code/run_mimo_project.m        - Main entry point, logs, tests, orchestration
code/mimo_parameters.m        - One place for all simulation parameters
code/mimo_filters.m           - Matrix-based implementations of ZF/MMSE/MRC
code/mimo_post_sinr.m         - Post-filter SINR formula
code/simulate_mimo_ber.m      - Full Monte Carlo engine
code/zf_bpsk_theory.m         - Exact theoretical BPSK/ZF average BER
code/estimate_snr_threshold.m- BER threshold estimation without zero tricks
code/export_mimo_results.m   - MAT/CSV files and quantitative comparison
code/plot_mimo_results.m     - Grayscale BER/SINR figures, PNG and PDF
code/run_self_tests.m        - Internal formula/implementation consistency tests
HUONG_DAN_BAO_CAO.md         - Report structure, mathematical derivations
HUONG_DAN_THUYET_TRINH.md    - 10-15 min video plan and defense questions
CHECKLIST_DE_BAI.txt         - Requirement-by-requirement audit

4. GENERATED FILES (AFTER YOU ACTUALLY RUN MATLAB)
--------------------------------------------------
results/mimo_full_results.mat      - All parameters, arrays, counts, timings
results/mimo_ber_results.csv       - BER, errors, counts, SINR, runtime
results/zf_theory_validation.csv   - Measured vs exact analytical ZF BER
results/ber_target_snr_summary.csv - SNR for target BER=1e-2
results/interpretation_notes.txt   - Interpretation and caveats
results/run_log_full.txt           - Command Window full-run trace
figures/Fig_Detectors_4x4(.png/.pdf)
figures/Fig_Detectors_4x5(.png/.pdf)
figures/Fig_Detectors_4x6(.png/.pdf)
figures/Fig_ZF_AntennaComparison(.png/.pdf)
figures/Fig_MMSE_AntennaComparison(.png/.pdf)
figures/Fig_MRC_AntennaComparison(.png/.pdf)
figures/Fig_ZF_TheoryValidation(.png/.pdf)
figures/Fig_PostDetectorSINR(.png/.pdf)

5. MODEL/SNR CONVENTION
-----------------------
Y = H*X + Z; H_ij ~ CN(0,1), one independent H per fading block.
BPSK X_ij is -1 or +1 with Es=1 per transmit stream.
Z_ij ~ CN(0,N0), implemented using sqrt(N0/2)*(randn+1i*randn).
Es/N0 (per transmit stream) = 10^(EsN0dB/10) and N0=1/(Es/N0).
Total transmit energy per channel use is Nt (4). Nt stays FIXED in
all plotted antenna comparisons. Thus no hidden power variation across Nr.
Perfect receiver CSI; transmitters do not know H.
The detector outputs are hard decision in BPSK: real(W*Y) >= 0.

6. SCIENTIFIC CAUTIONS
----------------------
- MATLAB detector blocks are implemented directly from matrix equations,
  not from built-in detection/equalizer functions.
- MRC in spatial multiplexing is a matched filter; it cannot remove
  interference between simultaneously transmitted streams.
- Block fading means errors within the same channel block can correlate.
  We also require a minimum number of independently faded blocks.
- A measured BER=0 means zero errors OBSERVED in finite trials; figures
  omit those points on a log axis instead of pretending that BER=0.
- If LowErrorCount=true, a detector has fewer than the desired 200 errors
  and the BER estimate has limited numerical precision. Extend maxBits
  in mimo_parameters.m and repeat the full experiment when needed.
- If the required SNR threshold is NaN, a measured positive BER crossing
  was not observed. Do not invent a numerical crossing.
- The theory comparison is exact for the stated channel and BPSK/ZF
  assumptions. It is not automatically the BER theory for MMSE or MRC.

7. REPORT/VIDEO
---------------
This ZIP contains REAL SOURCE CODE and writing/speaking GUIDES, not a
completed report/video. The students must run MATLAB, inspect figures,
write their own explanations, create their own presentation, and understand
all code/assumptions. Follow the school's requirements for attribution,
original work and declaring any AI assistance.

8. SUBMISSION CHECK
-------------------
The assignment requests the archive format DAMH2026_MSSV_HoTen.zip with:
  BaoCao.pdf (include video URL on cover)
  code/ (MATLAB scripts and README.txt)
  figures/ (figures actually included in the report)
  simulated result data (.mat or .csv)
  Slide.pdf (presentation used in the video)
Please build the final submission archive from the files you actually use.
