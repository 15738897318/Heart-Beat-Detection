function [indices] = QRSDetect(fileName, alpha, frequency)
    %%% Input
    % fileName: name of the file to load
    % alpha: constant, used for calculation of trimmed moving average
    % frequency: sampling frequency of the signal
    %%% Output
    % indices: indices of QRS beats 
    
    sig = cell2mat(struct2cell(load(fileName)));
    
    lead_length = frequency * 30;       % take first 30 seconds of the signal
    lead_1 = sig(1, 1:lead_length);     % ECG
    lead_2 = sig(2, 1:lead_length);     % BP
    
    % check which signal to use
    [indices_ecg, delay_ecg] = QRS_BP_Detect('ECG', lead_1, alpha, frequency);
    [indices_bp, delay_bp] = QRS_BP_Detect('BP', lead_2, alpha, frequency);
    
    % disp(['Found ECG: ', num2str(length(indices_ecg))]);
    % disp(['Found BP: ', num2str(length(indices_bp))]);
    
    if (length(indices_ecg) >= 20 && length(indices_ecg) <= 60)
        mode = 'ECG';
        [indices, ~] = QRS_BP_Detect(mode, sig(1, :), alpha, frequency);
        indices = indices - delay_ecg;
    elseif (length(indices_bp) >= 20 && length(indices_bp) <= 60)
        mode = 'BP'; 
        [indices, ~] = QRS_BP_Detect(mode, sig(2, :), alpha, frequency);
        indices = indices - delay_bp;
    else
        mode = 'Unknown';
        disp('Mode ECG or BP should be selected.');
    end
    
    disp(['Mode: ', mode]);
    disp(['Beats found: ', num2str(length(indices))]);
end
