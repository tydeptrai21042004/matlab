function plot_mimo_results(r,rootDir)
% PLOT_MIMO_RESULTS  Eight figures with checked PNG and PDF exports.
% Author(s): [Insert authors and student IDs before submission].

    p = r.p;
    figDir = fullfile(rootDir,p.figureFolder);
    if ~exist(figDir,'dir'), mkdir(figDir); end
    styles = {'-o','--s','-.^'};
    colors = {[0 0 0],[0.35 0.35 0.35],[0.62 0.62 0.62]};

    for c = 1:numel(p.NrList)
        fig = make_figure();
        hold on;
        h = gobjects(1,4);
        for m = 1:3
            curve = squeeze(r.ber(m,:,c));
            curve(curve<=0) = NaN;
            h(m) = semilogy(p.snrDb,curve,styles{m}, ...
                'Color',colors{m},'LineWidth',1.4,'MarkerSize',6);
        end
        h(4) = semilogy(p.snrDb,squeeze(r.zfTheory(:,c))',':d', ...
            'Color',[0.14 0.14 0.14],'LineWidth',1.5,'MarkerSize',5);
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
                'Color',color,'LineWidth',1.4,'MarkerSize',6);
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
            'Color',colors{c},'LineWidth',1.4,'MarkerSize',6);
        handles(2*c) = semilogy(p.snrDb,squeeze(r.zfTheory(:,c))',':', ...
            'Color',colors{c},'LineWidth',1.7);
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
            'Color',colors{m},'LineWidth',1.4,'MarkerSize',6);
    end
    grid on; box on;
    set(gca,'FontSize',11);
    xlabel('E_s/N_0 per transmit stream (dB)');
    ylabel('Average instantaneous post-filter SINR (dB)');
    title(sprintf('Post-filter SINR: MIMO %d x %d',p.Nt,p.NrList(c)));
    legend(h,{'ZF','MMSE','MRC/MF'},'Location','northwest');
    export_figure_checked(fig,figDir,'Fig_PostDetectorSINR');
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
    set(gca,'FontSize',11,'YScale','log');
    xlabel('E_s/N_0 per transmit stream (dB)');
    ylabel('Bit error rate (BER)');
    xlim([snrDb(1),snrDb(end)]);
    ylim([1e-7,1]);
end
