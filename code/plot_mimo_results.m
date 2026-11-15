function plot_mimo_results(r,rootDir)
% PLOT_MIMO_RESULTS  Eight 2D figures and three 3D figures, checked exports.
% Author(s): [Insert authors and student IDs before submission].

    p = r.p;
    figDir = fullfile(rootDir,p.figureFolder);
    if ~exist(figDir,'dir'), mkdir(figDir); end
    styles = {'-o','--s','-.^'};
    colors = {[0.08 0.37 0.64],[0.86 0.35 0.17],[0.16 0.51 0.41]};

    for c = 1:numel(p.NrList)
        fig = make_figure();
        hold on;
        h = gobjects(1,4);
        for m = 1:3
            curve = squeeze(r.ber(m,:,c));
            curve(curve<=0) = NaN;
            h(m) = semilogy(p.snrDb,curve,styles{m}, ...
                'Color',colors{m},'LineWidth',1.8,'MarkerSize',6);
        end
        h(4) = semilogy(p.snrDb,squeeze(r.zfTheory(:,c))',':d', ...
            'Color',[0.20 0.20 0.20],'LineWidth',1.8,'MarkerSize',5);
        ber_axes(p.snrDb);
        title(sprintf('BPSK spatial multiplexing: %d x %d',p.Nt,p.NrList(c)));
        legend(h,{'ZF simulation','MMSE simulation', ...
            'MRC/MF simulation','ZF theory'},'Location','southwest');
        export_figure_checked(fig,figDir, ...
            sprintf('Fig_Detectors_%dx%d',p.Nt,p.NrList(c)));
    end

    for m = 1:3
        fig = make_figure();
        hold on;
        h = gobjects(1,numel(p.NrList));
        labels = cell(1,numel(p.NrList));
        for c = 1:numel(p.NrList)
            curve = squeeze(r.ber(m,:,c));
            curve(curve<=0) = NaN;
            sty = styles{mod(c-1,numel(styles))+1};
            color = colors{mod(c-1,numel(colors))+1};
            h(c) = semilogy(p.snrDb,curve,sty, ...
                'Color',color,'LineWidth',1.8,'MarkerSize',6);
            labels{c} = sprintf('%d x %d',p.Nt,p.NrList(c));
        end
        ber_axes(p.snrDb);
        title(sprintf('%s: antenna comparison',r.methods{m}));
        legend(h,labels,'Location','southwest');
        export_figure_checked(fig,figDir, ...
            sprintf('Fig_%s_AntennaComparison',r.methods{m}));
    end

    fig = make_figure();
    hold on;
    labels = cell(1,2*numel(p.NrList));
    handles = gobjects(1,2*numel(p.NrList));
    for c = 1:numel(p.NrList)
        curve = squeeze(r.ber(1,:,c));
        curve(curve<=0) = NaN;
        handles(2*c-1) = semilogy(p.snrDb,curve,styles{c}, ...
            'Color',colors{c},'LineWidth',1.8,'MarkerSize',6);
        handles(2*c) = semilogy(p.snrDb,squeeze(r.zfTheory(:,c))',':', ...
            'Color',colors{c},'LineWidth',1.8);
        labels{2*c-1} = sprintf('%d x %d simulation',p.Nt,p.NrList(c));
        labels{2*c} = sprintf('%d x %d theory',p.Nt,p.NrList(c));
    end
    ber_axes(p.snrDb);
    title('ZF: Monte Carlo versus analytical Rayleigh BER');
    legend(handles,labels,'Location','southwest');
    export_figure_checked(fig,figDir,'Fig_ZF_TheoryValidation');

    fig = make_figure();
    hold on;
    h = gobjects(1,3);
    c = 1;
    for m = 1:3
        h(m) = plot(p.snrDb,squeeze(r.meanSinrDb(m,:,c)),styles{m}, ...
            'Color',colors{m},'LineWidth',1.8,'MarkerSize',6);
    end
    grid on; box on;
    set(gca,'FontSize',11,'FontName','Arial','LineWidth',0.9, ...
        'TickDir','out','GridAlpha',0.15);
    xlabel('E_s/N_0 per transmit stream (dB)');
    ylabel('Average instantaneous post-filter SINR (dB)');
    title(sprintf('Post-filter SINR: MIMO %d x %d',p.Nt,p.NrList(c)));
    legend(h,{'ZF','MMSE','MRC/MF'},'Location','northwest');
    export_figure_checked(fig,figDir,'Fig_PostDetectorSINR');

    % Supplementary 3D landscapes; the original eight 2D plots are retained.
    plot_3d_ber_landscapes(r,figDir);
end

function fig = make_figure()
    visibility = 'off';
    % Visible figures are more reliable in MATLAB Online/desktop exporters.
    if usejava('desktop')
        visibility = 'on';
    end
    fig = figure('Visible',visibility,'Color','w', ...
        'Position',[100,100,960,600]);
end

function ber_axes(snrDb)
    grid on; box on;
    set(gca,'FontSize',11,'FontName','Arial','LineWidth',0.9, ...
        'TickDir','out','GridAlpha',0.15,'YScale','log');
    xlabel('E_s/N_0 per transmit stream (dB)');
    ylabel('Bit error rate (BER)');
    xlim([snrDb(1),snrDb(end)]);
    ylim([1e-7,1]);
end


function plot_3d_ber_landscapes(r,figDir)
% 3D view of actual measured BER on the sampled SNR and Nr grid.
% A measured BER=0 means no error was observed, not perfect reliability.
% Leave such points missing rather than inventing a numerical BER floor.

    p = r.p;
    [snrGrid,nrGrid] = meshgrid(p.snrDb,p.NrList);

    for m = 1:numel(r.methods)
        % r.ber has dimensions [detector, SNR, receive configuration].
        berGrid = squeeze(r.ber(m,:,:)).';
        valid = isfinite(berGrid) & berGrid > 0;
        if ~any(valid(:))
            warning('MIMO:EmptyBERLandscape', ...
                'Skipping 3D %s: no positive measured BER values.',r.methods{m});
            continue;
        end

        logBer = NaN(size(berGrid));
        logBer(valid) = log10(berGrid(valid));
        zLower = min(-5,floor(min(logBer(valid))));

        fig = make_figure();
        ax = axes('Parent',fig);
        hold(ax,'on');
        surf(ax,snrGrid,nrGrid,logBer,logBer, ...
            'FaceColor','interp','EdgeColor',[0.48 0.53 0.57], ...
            'LineWidth',0.45);
        scatter3(ax,snrGrid(valid),nrGrid(valid),logBer(valid), ...
            12,[0.12 0.17 0.21],'filled');

        colormap(ax,parula(128));
        caxis(ax,[zLower 0]);
        cb = colorbar(ax);
        cb.Label.String = 'log_{10}(BER)';

        xlabel(ax,'E_s/N_0 per transmit stream (dB)');
        ylabel(ax,'Receive antennas N_r');
        zlabel(ax,'log_{10}(BER)');
        title(ax,sprintf('%s: BER versus SNR and receive antennas', ...
            r.methods{m}),'FontWeight','normal');

        xlim(ax,[p.snrDb(1),p.snrDb(end)]);
        ylim(ax,[min(p.NrList),max(p.NrList)]);
        zlim(ax,[zLower 0]);
        set(ax,'YTick',p.NrList,'FontName','Arial', ...
            'FontSize',11,'LineWidth',0.9,'GridAlpha',0.16, ...
            'TickDir','out');
        view(ax,-52,28);
        grid(ax,'on');
        box(ax,'on');
        % Surface cells between adjacent measured Nr values are visual
        % connections only; no additional antenna configurations were run.
        export_figure_checked(fig,figDir, ...
            sprintf('Fig_3D_%s_BERLandscape',r.methods{m}));
    end
end
