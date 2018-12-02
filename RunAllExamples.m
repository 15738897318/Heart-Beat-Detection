function RunAllExamples()
    examples = string(100 : 199);
    for i = 1 : length(examples)
        disp(examples(i));
        Detector(examples(i));
    end
end

