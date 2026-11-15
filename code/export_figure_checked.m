function export_figure_checked(fig,folder,stem)
% EXPORT_FIGURE_CHECKED  Export PNG/PDF/FIG and verify binary signatures.
% Author(s): [Insert authors and student IDs before submission].
% Uses a local temporary export before copying to MATLAB Drive.
% For 3D axes, PDF is rasterized at 300 dpi for reliable output.

    if ~exist(folder,'dir'), mkdir(folder); end
    drawnow;
    set(fig,'PaperPositionMode','auto');

    try
        write_one(fig,fullfile(folder,[stem,'.png']),'png',false);
        is3D = strncmp(stem,'Fig_3D_',7);
        write_one(fig,fullfile(folder,[stem,'.pdf']),'pdf',is3D);
        savefig(fig,fullfile(folder,[stem,'.fig']));
        fprintf('Saved checked figure: %s (.png/.pdf/.fig)\n',stem);
    catch ME
        try
            savefig(fig,fullfile(folder,[stem,'_RECOVERY.fig']));
        catch
        end
        close(fig);
        rethrow(ME);
    end
    close(fig);
end

function write_one(fig,targetPath,kind,is3D)
% Generate locally first, verify, then atomically rename in target folder.
    scratchDir = tempname(tempdir);
    mkdir(scratchDir);
    cleaner = onCleanup(@() remove_scratch(scratchDir)); %#ok<NASGU>
    [targetFolder,name,ext] = fileparts(targetPath);
    localPath = fullfile(scratchDir,['mimo_export',ext]);
    stagedPath = fullfile(targetFolder,[name,'__verified_write',ext]);
    lastMessage = 'no export attempt was successful';

    for method = 1:3
        if exist(localPath,'file'), delete(localPath); end
        if exist(stagedPath,'file'), delete(stagedPath); end
        try
            drawnow;
            switch method
                case 1
                    if exist('exportgraphics','file') == 0
                        error('exportgraphics unavailable.');
                    end
                    if strcmp(kind,'png')
                        exportgraphics(fig,localPath,'Resolution',300);
                    elseif is3D
                        exportgraphics(fig,localPath, ...
                            'ContentType','image','Resolution',300);
                    else
                        exportgraphics(fig,localPath,'ContentType','vector');
                    end
                case 2
                    if strcmp(kind,'png')
                        print(fig,localPath,'-dpng','-r300');
                    elseif is3D
                        print(fig,localPath,'-dpdf','-opengl','-r300');
                    else
                        print(fig,localPath,'-dpdf','-painters');
                    end
                case 3
                    saveas(fig,localPath,kind);
            end

            if ~wait_valid(localPath,kind)
                error('Exporter created an incomplete or invalid %s file.',kind);
            end

            [copied,message] = copyfile(localPath,stagedPath,'f');
            if ~copied, error('Could not stage output: %s',message); end
            if ~wait_valid(stagedPath,kind)
                error('Invalid %s after copying to output folder.',kind);
            end

            [moved,message] = movefile(stagedPath,targetPath,'f');
            if ~moved, error('Could not finalize output: %s',message); end
            if ~wait_valid(targetPath,kind)
                error('Invalid %s after final rename in output folder.',kind);
            end
            return;
        catch ME
            lastMessage = ME.message;
            fprintf('  %s export attempt %d failed: %s\n', ...
                upper(kind),method,lastMessage);
        end
    end

    if exist(stagedPath,'file'), delete(stagedPath); end
    error('MIMO:FigureExportFailed', ...
        'Could not produce a valid %s at %s. Last error: %s', ...
        upper(kind),targetPath,lastMessage);
end

function ok = wait_valid(filePath,kind)
% MATLAB Drive can take a moment to make copied files readable.
    ok = false;
    previousSize = -1;
    for attempt = 1:12
        d = dir(filePath);
        if ~isempty(d) && d(1).bytes >= 100
            if file_signature_ok(filePath,kind)
                if d(1).bytes == previousSize || attempt >= 3
                    ok = true;
                    return;
                end
            end
            previousSize = d(1).bytes;
        end
        pause(0.15);
    end
end

function ok = file_signature_ok(filePath,kind)
    ok = false;
    fid = fopen(filePath,'rb');
    if fid < 0, return; end
    cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
    if strcmp(kind,'png')
        data = fread(fid,8,'*uint8')';
        ok = isequal(data,uint8([137 80 78 71 13 10 26 10]));
        return;
    end

    % A valid PDF header is allowed within the first 1024 bytes.
    fseek(fid,0,'eof');
    bytes = ftell(fid);
    if bytes < 100, return; end
    fseek(fid,0,'bof');
    head = fread(fid,min(1024,bytes),'*uint8')';
    if isempty(strfind(char(head),'%PDF-')) %#ok<STREMP>
        return;
    end
    fseek(fid,max(0,bytes-4096),'bof');
    tail = fread(fid,Inf,'*uint8')';
    ok = ~isempty(strfind(char(tail),'%%EOF')); %#ok<STREMP>
end

function remove_scratch(folder)
    if exist(folder,'dir'), rmdir(folder,'s'); end
end
