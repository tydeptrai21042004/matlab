function plot_mimo_results(r,rootDir)
% PLOT_MIMO_RESULTS  Eight 2D figures and three 3D measured-data plots.
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
    ylabel('Mean instantaneous SINR (dB; dB-domain average)');
    title(sprintf('Post-filter SINR: MIMO %d x %d',p.Nt,p.NrList(c)));
    legend(h,{'ZF','MMSE','MRC/MF'},'Location','northwest');
    export_figure_checked(fig,figDir,'Fig_PostDetectorSINR');

    % Discrete 3D traces use only simulated antenna configurations.
    plot_3d_ber_landscapes(r,figDir,colors);
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
% Adapt the log axis to measured positive BER while preserving the 1e0 top.
% Never create an artificial BER floor for zero observed errors.
    ax = gca;
    grid(ax,'on');
    box(ax,'on');
    set(ax,'FontSize',11,'FontName','Arial','LineWidth',0.9, ...
        'TickDir','out','GridAlpha',0.14,'YScale','log', ...
        'YMinorGrid','off','XMinorGrid','off');
    xlabel(ax,'E_s/N_0 per transmit stream (dB)');
    ylabel(ax,'Bit error rate (BER)');
    xlim(ax,[snrDb(1),snrDb(end)]);
    set(ax,'XTick',unique([snrDb(1):4:snrDb(end),snrDb(end)]));

    drawnLines = findobj(ax,'Type','line');
    positiveValues = [];
    for k = 1:numel(drawnLines)
        y = get(drawnLines(k),'YData');
        y = y(isfinite(y) & y>0);
        positiveValues = [positiveValues;y(:)]; %#ok<AGROW>
    end
    if isempty(positiveValues)
        ylim(ax,[1e-5,1]);
    else
        bottom = 10^floor(log10(min(positiveValues)));
        ylim(ax,[min(bottom,0.1),1]);
    end
end

function plot_3d_ber_landscapes(r,figDir,colors)
% Actual measured data only: one curve for each integer receive-antenna
% configuration. There is no interpolation across untested antenna counts.
% A zero observed BER is omitted, not replaced with a fictitious floor.

    p = r.p;
    lineStyles = {'-o','--s','-.^'};
    nConfigs = numel(p.NrList);
    for m = 1:numel(r.methods)
        values = squeeze(r.ber(m,:,:));  % [nSNR x nConfigs]
        measured = values(isfinite(values) & values>0);
        if isempty(measured)
            warning('MIMO:EmptyBERLandscape', ...
                'No positive BER values for %s.',r.methods{m});
            continue;
        end

        bottom = floor(log10(min(measured)));
        fig = make_figure();
        ax = axes('Parent',fig);
        hold(ax,'on');
        h = gobjects(1,nConfigs);
        labels = cell(1,nConfigs);

        for c = 1:nConfigs
            curve = squeeze(r.ber(m,:,c));
            z = NaN(size(curve));
            good = isfinite(curve) & curve>0;
            z(good) = log10(curve(good));
            y = p.NrList(c)*ones(size(p.snrDb));
            sty = lineStyles{mod(c-1,numel(lineStyles))+1};
            color = colors{mod(c-1,numel(colors))+1};
            h(c) = plot3(ax,p.snrDb,y,z,sty, ...
                'Color',color,'LineWidth',2.1,'MarkerSize',5.8, ...
                'MarkerFaceColor','w');
            labels{c} = sprintf('N_r = %d',p.NrList(c));
        end

        xlabel(ax,'E_s/N_0 (dB)');
        ylabel(ax,'Receive antennas N_r');
        zlabel(ax,'log_{10}(BER)');
        title(ax,sprintf('%s: BER versus SNR and N_r',r.methods{m}), ...
            'FontWeight','normal');

        xlim(ax,[p.snrDb(1),p.snrDb(end)]);
        ylim(ax,[min(p.NrList)-0.15,max(p.NrList)+0.15]);
        zlim(ax,[min(bottom,-1),0]);
        set(ax,'XTick',unique([p.snrDb(1):4:p.snrDb(end),p.snrDb(end)]), ...
            'YTick',p.NrList,'ZTick',min(bottom,-1):0, ...
            'FontName','Arial','FontSize',11,'LineWidth',0.9, ...
            'GridAlpha',0.15,'TickDir','out');
        view(ax,-50,25);
        grid(ax,'on');
        box(ax,'on');
        legend(ax,h,labels,'Location','northeast');
        export_figure_checked(fig,figDir, ...
            sprintf('Fig_3D_%s_BERLandscape',r.methods{m}));
    end
end
