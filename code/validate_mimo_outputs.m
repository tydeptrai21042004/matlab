function validate_mimo_outputs(rootDir,profile)
% VALIDATE_MIMO_OUTPUTS  Check all expected result files and figure formats.
% Author(s): [Insert authors and student IDs before submission].
% PDF validation accepts a header within 1024 bytes and checks for %%EOF.

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
        check_magic(png,'png');
        check_magic(pdf,'pdf');
    end
    fprintf('PASS: %d verified figures with PNG, PDF and FIG versions.\n',numel(stems));
end

function check_size(path,smallest)
    d = dir(path);
    if isempty(d) || d(1).bytes < smallest
        error('MIMO:MissingOrEmptyFile','Missing/empty output: %s',path);
    end
end

function check_magic(path,kind)
    % Retry briefly for freshly copied files in MATLAB Drive.
    for attempt = 1:10
        if signature_ok(path,kind), return; end
        pause(0.2);
    end
    fid = fopen(path,'rb');
    if fid >= 0
        b = fread(fid,16,'*uint8')';
        fclose(fid);
        firstBytes = sprintf('%02X ',b);
    else
        firstBytes = '(file cannot be opened)';
    end
    error('MIMO:InvalidImage', ...
        'Invalid %s file: %s\nFirst bytes (hex): %s', ...
        upper(kind),path,firstBytes);
end

function ok = signature_ok(path,kind)
    ok = false;
    fid = fopen(path,'rb');
    if fid < 0, return; end
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    if strcmp(kind,'png')
        b = fread(fid,8,'*uint8')';
        ok = isequal(b,uint8([137 80 78 71 13 10 26 10]));
        return;
    end
    fseek(fid,0,'eof');
    bytes = ftell(fid);
    if bytes < 100, return; end
    fseek(fid,0,'bof');
    head = fread(fid,min(bytes,1024),'*uint8')';
    if isempty(strfind(char(head),'%PDF-')) %#ok<STREMP>
        return;
    end
    fseek(fid,max(0,bytes-4096),'bof');
    tail = fread(fid,Inf,'*uint8')';
    ok = ~isempty(strfind(char(tail),'%%EOF')); %#ok<STREMP>
end
