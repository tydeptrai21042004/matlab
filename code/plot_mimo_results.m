function plot_mimo_results(r, rootDir)
% PLOT_MIMO_RESULTS  Publication-ready B/W figures with different line styles.
% Author(s): [Add group members and student IDs].
% Saves both 300 dpi PNG and vector PDF using standard MATLAB print().

    p = r.p;
    figDir = fullfile(rootDir, 'figures');
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end
    styles = {'-o', '--s', '-.^'};
    colors = {[0 0 0], [0.33 0.33 0.33], [0.58 0.58 0.58]};

    % (A) Three detectors + analytical ZF, within each antenna configuration.
    for c = 1:numel(p.NrList)
        fig = new_figure();
        hold on;
        h = gobjects(1,4);
        for m = 1:3
            curve = squeeze(r.ber(m,:,c));
            curve(curve <= 0) = NaN;
            h(m) = semilogy(p.snrDb,curve,styles{m}, ...
                'Color',colors{m},'LineWidth',1.4,'MarkerSize',6);
        end
        h(4) = semilogy(p.snrDb,squeeze(r.zfTheory(:,c))',':d', ...
            'Color',[0.1 0.1 0.1],'LineWidth',1.5,'MarkerSize',5);
        style_ber_axes(p.snrDb);
        title(sprintf('BPSK spatial multiplexing: %d x %d',p.Nt,p.NrList(c)));
        legend(h,{'ZF simulation','MMSE simulation', ...
                  'MRC/MF simulation','ZF theoretical BER'}, ...
                  'Location','southwest');
        save_figure(fig,figDir,sprintf('Fig_Detectors_%dx%d',p.Nt,p.NrList(c)));
    end

    % (B) Compare all three Nr for the same detector.
    for m = 1:3
        fig = new_figure();
        hold on;
        h = gobjects(1,numel(p.NrList));
        labels = cell(1,numel(p.NrList));
        for c = 1:numel(p.NrList)
            curve = squeeze(r.ber(m,:,c));
            curve(curve <= 0) = NaN;
            h(c) = semilogy(p.snrDb,curve,styles{c}, ...
                'Color',colors{c},'LineWidth',1.4,'MarkerSize',6);
            labels{c} = sprintf('%d x %d',p.Nt,p.NrList(c));
        end
        style_ber_axes(p.snrDb);
        title(sprintf('%s: changing receive antennas (Nt=%d)',r.methods{m},p.Nt));
        legend(h,labels,'Location','southwest');
        save_figure(fig,figDir,sprintf('Fig_%s_AntennaComparison',r.methods{m}));
    end

    % (C) Isolate the central numerical verification: ZF vs analytical BER.
    fig = new_figure();
    hold on;
    legendLabels = cell(1,2*numel(p.NrList));
    handles = gobjects(1,2*numel(p.NrList));
    for c = 1:numel(p.NrList)
        curve = squeeze(r.ber(1,:,c));
        curve(curve <= 0) = NaN;
        handles(2*c-1) = semilogy(p.snrDb,curve,styles{c}, ...
            'Color',colors{c},'LineWidth',1.4,'MarkerSize',6);
        handles(2*c) = semilogy(p.snrDb,squeeze(r.zfTheory(:,c))',':', ...
            'Color',colors{c},'LineWidth',1.7);
        legendLabels{2*c-1} = sprintf('%d x %d simulation',p.Nt,p.NrList(c));
        legendLabels{2*c} = sprintf('%d x %d theory',p.Nt,p.NrList(c));
    end
    style_ber_axes(p.snrDb);
    title('ZF: Monte Carlo validation against exact Rayleigh BER');
    legend(handles,legendLabels,'Location','southwest');
    save_figure(fig,figDir,'Fig_ZF_TheoryValidation');

    % (D) Illustrate the post-detector SINR used in the discussion.
    fig = new_figure();
    hold on;
    c = 1; % base 4x4 case; the other configurations are also in CSV
    h = gobjects(1,3);
    for m = 1:3
        h(m) = plot(p.snrDb,squeeze(r.meanSinrDb(m,:,c)),styles{m}, ...
            'Color',colors{m},'LineWidth',1.4,'MarkerSize',6);
    end
    grid on;
    box on;
    set(gca,'FontSize',11);
    xlabel('E_s/N_0 per transmit stream (dB)');
    ylabel('Mean instantaneous post-filter SINR (dB)');
    title(sprintf('Post-filter SINR for MIMO %d x %d',p.Nt,p.NrList(c)));
    legend(h,{'ZF','MMSE','MRC/MF'},'Location','northwest');
    save_figure(fig,figDir,'Fig_PostDetectorSINR');
end

function fig = new_figure()
    fig = figure('Visible','off','Color','w', 'Position',[100,100,960,600]);
end

function style_ber_axes(snrDb)
    grid on;
    box on;
    set(gca,'FontSize',11,'YScale','log');
    xlabel('E_s/N_0 per transmit stream (dB)');
    ylabel('Bit error rate (BER)');
    xlim([snrDb(1),snrDb(end)]);
    ylim([1e-7,1]);
end

function save_figure(fig,folder,stem)
    set(fig,'PaperPositionMode','auto');
    print(fig,fullfile(folder,[stem,'.png']),'-dpng','-r300');
    print(fig,fullfile(folder,[stem,'.pdf']),'-dpdf','-painters');
    close(fig);
end
