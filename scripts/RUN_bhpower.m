
subjects=["sub17"];
task=["Baseline"];

pband_vec = [];
ptot_vec = [];
per_power_vec = [];
sub_list = [];
task_list = [];

for sbjid = subjects
    dir=strcat('/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/',sbjid,'/test/');
    filename=strcat(sbjid, '_', task,'_physio');
    filepath=strcat(dir,filename,'.tsv');
    json_filepath=strcat(dir,filename,'.json');
    
    if isfile(filepath)
        Fs=500;
        freqRange=[0, 5];      %[0.90, 1.60]   [0.014,0.02]
                    
        json_info = readstruct(json_filepath);
        resp_idx_counter = 1;
        for i = json_info.Columns
            if i == 'respiratory'
                resp_idx = resp_idx_counter;
                disp([i resp_idx]);
            else
                resp_idx_counter = resp_idx_counter + 1;    %this is the variable that marks the index for which column 'trigger' belongs
            end
        end

        column=resp_idx;        %%what column is the resp data in? If the first column, then idx=1
        
        [pband,ptot,per_power] = bhpower(filepath, json_filepath,Fs,freqRange,column);
        data = load(filepath);
        data = data(:,column);
        
        pband_vec(end+1) = pband;
        ptot_vec(end+1) = ptot;
        per_power_vec(end+1) = per_power;
        sub_list(end+1) = sbjid;
        task_list(end+1) = task;
        
        figure(1)
        [pxx,f] = pwelch(data,Fs,'power');   %pwelch or pspectrum?
        plot(f,10*log10(pxx));       %10*log10(pxx) or pxx?
        xlim(freqRange);
        xlabel('Frequency (Hz)');
        ylabel('PSD (dB/Hz)');
        title(sbjid)
    
    else
        disp("file didn't exist") 

    end
end


