function export_figure_checked(fig,folder,stem)
% EXPORT_FIGURE_CHECKED  Robust PNG/PDF export for MATLAB Online and R2018+.
% Author(s): [Insert authors and student IDs before submission].
% Exportgraphics (R2020a+) is preferred; print/saveas are fallbacks.
% Each file is checked for nonzero content AND its expected magic bytes.
% A failed export causes an error; an empty figure can never be zipped as OK.

    if ~exist(folder,'dir'), mkdir(folder); end
    drawnow;
    set(fig,'PaperPositionMode','auto');
    pngPath = fullfile(folder,[stem,'.png']);
    pdfPath = fullfile(folder,[stem,'.pdf']);

    try
        write_one(fig,pngPath,'png');
        write_one(fig,pdfPath,'pdf');
        savefig(fig,fullfile(folder,[stem,'.fig']));
        fprintf('Saved checked figure: %s (.png/.pdf/.fig)\n',stem);
    catch ME
        % Retain figure for inspection if either image export failed.
        try
            savefig(fig,fullfile(folder,[stem,'_RECOVERY.fig']));
        catch
        end
        close(fig);
        rethrow(ME);
    end
    close(fig);
end

function write_one(fig,filePath,kind)
    [folder,name,ext] = fileparts(filePath);
    tempPath = fullfile(folder,[name,'__writing',ext]);
    if exist(filePath,'file'), delete(filePath); end
    if exist(tempPath,'file'), delete(tempPath); end

    lastMessage = 'no exporter succeeded';
    for method = 1:3
        if exist(tempPath,'file'), delete(tempPath); end
        try
            drawnow;
            pause(0.10);
            switch method
                case 1
                    if exist('exportgraphics','file') == 0
                        error('exportgraphics unavailable on this MATLAB release');
                    end
                    if strcmp(kind,'png')
                        exportgraphics(fig,tempPath,'Resolution',300);
                    else
                        exportgraphics(fig,tempPath,'ContentType','vector');
                    end
                case 2
                    if strcmp(kind,'png')
                        print(fig,tempPath,'-dpng','-r300');
                    else
                        print(fig,tempPath,'-dpdf','-painters');
                    end
                case 3
                    saveas(fig,tempPath,kind);
            end
            if wait_for_complete_file(tempPath,kind)
                [moved,message] = movefile(tempPath,filePath,'f');
                if ~moved
                    error('Move failed: %s',message);
                end
                if wait_for_complete_file(filePath,kind)
                    return;
                end
                error('Final file is missing or invalid after moving.');
            else
                error('File was empty, truncated, or had an invalid signature');
            end
        catch ME
            lastMessage = ME.message;
            fprintf('  %s export method %d failed: %s\n',kind,method,lastMessage);
        end
    end
    if exist(tempPath,'file'), delete(tempPath); end
    error('MIMO:FigureExportFailed', ...
        'Could not export a VALID %s file: %s\nLast error: %s', ...
        kind,filePath,lastMessage);
end

function ok = wait_for_complete_file(filePath,kind)
    ok = false;
    previousSize = -1;
    for attempt = 1:8
        drawnow;
        d = dir(filePath);
        if ~isempty(d) && d(1).bytes >= 100 && d(1).bytes == previousSize
            if signature_correct(filePath,kind)
                ok = true;
                return;
            end
        end
        if ~isempty(d), previousSize = d(1).bytes; end
        pause(0.15);
    end
end

function ok = signature_correct(filePath,kind)
    ok = false;
    fid = fopen(filePath,'rb');
    if fid<0, return; end
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    if strcmp(kind,'png')
        actual = fread(fid,8,'uint8')';
        expected = uint8([137 80 78 71 13 10 26 10]);
    else
        actual = fread(fid,5,'uint8')';
        expected = uint8([37 80 68 70 45]); % '%PDF-'
    end
    ok = isequal(actual,expected);
end
