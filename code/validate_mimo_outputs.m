function validate_mimo_outputs(rootDir,profile)
% VALIDATE_MIMO_OUTPUTS  Stop packaging if results/figures are absent or empty.
% Author(s): [Insert authors and student IDs before submission].

    if nargin<2, profile='full'; end
    p = mimo_parameters(profile);
    dataDir = fullfile(rootDir,p.resultFolder);
    figDir = fullfile(rootDir,p.figureFolder);
    requiredData = {['mimo_',p.profile,'_results.mat'], ...
        'mimo_ber_results.csv','zf_theory_validation.csv', ...
        'ber_target_snr_summary.csv','interpretation_notes.txt', ...
        ['run_log_',p.profile,'.txt']};
    for k = 1:numel(requiredData)
        check_size(fullfile(dataDir,requiredData{k}),30);
    end

    stems = cell(1,11);
    for c = 1:3
        stems{c} = sprintf('Fig_Detectors_%dx%d',p.Nt,p.NrList(c));
    end
    stems(4:8) = {'Fig_ZF_AntennaComparison', ...
        'Fig_MMSE_AntennaComparison','Fig_MRC_AntennaComparison', ...
        'Fig_ZF_TheoryValidation','Fig_PostDetectorSINR'};
    stems(9:11) = {'Fig_3D_ZF_BERLandscape', ...
        'Fig_3D_MMSE_BERLandscape','Fig_3D_MRC_BERLandscape'};

    for k = 1:numel(stems)
        png = fullfile(figDir,[stems{k},'.png']);
        pdf = fullfile(figDir,[stems{k},'.pdf']);
        fig = fullfile(figDir,[stems{k},'.fig']);
        check_size(png,100);
        check_size(pdf,100);
        check_size(fig,100);
        check_magic(png,uint8([137 80 78 71 13 10 26 10]));
        check_magic(pdf,uint8([37 80 68 70 45]));
    end
    fprintf('PASS: %d verified figures with PNG, PDF and FIG versions.\n',numel(stems));
end

function check_size(path,smallest)
    d = dir(path);
    if isempty(d) || d(1).bytes < smallest
        error('MIMO:MissingOrEmptyFile','Missing/empty output: %s',path);
    end
end

function check_magic(path,expected)
    fid = fopen(path,'rb');
    if fid<0, error('Cannot read %s',path); end
    c = onCleanup(@() fclose(fid)); %#ok<NASGU>
    actual = fread(fid,numel(expected),'uint8')';
    if ~isequal(actual,expected)
        error('MIMO:InvalidImage','Invalid image format: %s',path);
    end
end
