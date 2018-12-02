function [indices, index_delay] = QRS_BP_Detect(mode, signal, alpha, frequency)
    %%% Input
    % mode: 'ECG' or 'BP'
    % signal: signal of particular lead (ECG or BP)
    % alpha: constant, used for calculation of trimmed moving average
    % frequency: sampling frequency of the signal
    %%% Output
    % indices: indices of QRS beats 
    % index_delay: delay of BP indices according to ECG signal
    
    signal_length = length(signal);
    
    %%% trimmed moving average filter
    window_length = 0.04 * frequency;   % original: 0.2*frequency
    k = ceil(window_length * alpha / 2);
    delay = window_length / 2;
    TMA_factor = (1 / (window_length - 2*k));
    sig_tma = zeros(1, signal_length);
    
    for i = delay+1 : signal_length-delay
        x_t = signal(i-delay : i+delay);   
        x_t_sorted = sort(x_t);
        sig_tma(1, i) = TMA_factor * sum(x_t_sorted(k+1 : window_length-k));    % TMA_i
    end
    
    %%% standardization
    % sig_standard = (sig_tma - mean(sig_tma)) / std(sig_tma);
    
    %%% range filter
    range_max = zeros(1, signal_length);
    range_min = zeros(1, signal_length);
    range_mean = zeros(1, signal_length);
    beat_extraction = zeros(1, signal_length);
    
    for i = delay+1 : signal_length-delay
        range_max(1, i) = max(sig_tma(i-delay : i+delay));
        range_min(1, i) = min(sig_tma(i-delay : i+delay));
        range_mean(1, i) = (range_max(1, i) + range_min(1, i)) / 2;
        beat_extraction(1, i) = (sig_tma(1, i) - range_mean(1, i));
    end
    
    delay = delay * 2;
    max_value = 0;
    beat_extraction_2 = zeros(1, signal_length);
    for i = delay+1 : signal_length-delay
        beat_extraction_2(1, i) = max(beat_extraction(i-delay : i+delay)) ^ 2;
        if (beat_extraction_2(1, i) > max_value)
            max_value = beat_extraction_2(1, i);
        end
    end
    threshold = mean(beat_extraction_2);
    
    indices = [];
    max_value = -Inf;
    max_index = 0;
    i = 1;
    while i <= signal_length
        if (beat_extraction_2(1, i) > threshold)
            while (i <= signal_length && beat_extraction_2(1, i) > threshold)
                if (signal(1, i) > max_value)
                    max_value = signal(1, i);
                    max_index = i;
                end
                i = i + 1;
            end
            indices = [indices, max_index];
            max_value = -Inf;
            max_index = 0;
        else
            i = i + 1;
        end
    end
    
    %%% check RR intervals
    RR_differences = indices(2 : end) - indices(1 : end-1);
    RR_mean = mean(RR_differences);
    
    possible_wrong_indices = [];
    for i = 1 : length(RR_differences)-1
        if (RR_differences(i) < 0.5 * RR_mean)      % too early
            if (RR_differences(i) + RR_differences(i+1) >= 0.5 * RR_mean && RR_differences(i) + RR_differences(i+1) <= 1.5 * RR_mean)
                possible_wrong_indices = [possible_wrong_indices, indices(i+1)];
            else
                possible_wrong_indices = [possible_wrong_indices, indices(i)];
            end
        end
    end
    
    indices = setdiff(indices, possible_wrong_indices);

    %%% delay
    if (strcmp(mode, 'ECG'))
        index_delay = 0;
    elseif (strcmp(mode, 'BP'))
        sig_standard = abs((signal - mean(signal)) / std(signal));
        t = max(sig_standard) * 0.3;
        for i = 1 : length(sig_standard) - 5
            if (sig_standard(i) > t)
                [~, max_ind] = max(sig_standard(i : i+5));
                max_index = i + max_ind - 1;
                index_delay = indices(1) - max_index;
                break;
            end
        end
    end
end

