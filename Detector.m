function Detector(record)
    %%%
    % Robust Detection of Heart Beats in Multimodal Data.
    % Uses ECG or BP signals.
    % The algorithm is inspired by the article of Marcus Vollmer: http://cinc.org/archives/2014/pdf/0569.pdf
    %%%

    %%% Input
    % record: a string containing numbers from 100 to 199

    % First convert the record into matlab (creates recordm.mat):
    % wfdb2mat -r record

    fileName = sprintf('../database/%sm.mat', record);
    t = cputime();
    alpha = 0.25;
    frequency = 250;

    idx = QRSDetect(fileName, alpha, frequency);
    fprintf('Running time: %f\n', cputime() - t);
    asciName = sprintf('../database/%s.asc', record);

    fid = fopen(asciName, 'wt');
    for i=1:size(idx, 2)
        fprintf(fid, '0:00:00.00 %d N 0 0 0\n', idx(1, i));
    end
    fclose(fid);

    % Now convert the .asc text output to binary WFDB format:
    % wrann -r record -a qrs < record.asc
    
    % And evaluate against reference annotations (atr) using bxb:
    % bxb -r record -a atr qrs
end







