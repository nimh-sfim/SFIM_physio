% Save MAP .tsv as one with a header so that AFNI includes row 1 of data

clc;clear;

phys_type = 'lfo';               %lfo, MAP
taskOI="outhold";                %resting, inhold, outhold
task4letters="bouh";             %rest, binh, bouh
dir1 = '/data/SFIM_physio/physio/physio_results';

%% Define subject list
if strncmp(taskOI,'resting',4)
    %resting: skip 17,28,29,33
    subjects = ["10","11","12","13","14","15","16","18","19","20","21","22","23","24","26","27","30","31","32","34"];
elseif strncmp(taskOI,'inhold',4)
    %inhold: skip 10,17,26,29
    subjects = ["11","12","13","14","15","16","18","19","20","21","22","23","24","25","27","28","30","31","32","33","34"];
elseif strncmp(taskOI,'outhold',4)
    %outhold: skip 10,17,29
    subjects = ["11","12","13","14","15","16","18","19","20","21","22","23","24","25","26","27","28","30","31","32","33","34"];
end

for ii = 1:length(subjects)
    
    sbjid = subjects(ii);

    dir1_expanded = strjoin([dir1 '/sub' sbjid],'');
    phys_1D_filename = strjoin(['sub' sbjid '_' phys_type '_downsampled2TR_arr_' taskOI],'');
    phys_1D_file = strjoin([dir1_expanded '/' phys_1D_filename '.tsv'],'');
    phys_1D = load(phys_1D_file);
    phys_table = array2table(phys_1D);
    
    cd(dir1_expanded)
    phys_table_filename = strjoin([phys_1D_filename '_hdr.tsv'],'');
    writetable(phys_table, phys_table_filename, 'filetype', 'text', 'delimiter', '\t')

end
