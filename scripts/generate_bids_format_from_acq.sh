#!/bin/bash
# bash generate_bids_format_from_acq.sh

# https://github.com/cbinyu/bidsphysio/blob/master/bidsphysio.acq2bids/bidsphysio/acq2bids/acq2bidsphysio.py

# there are several options for sub10 and sub19. Revisit these. 

fileOI='BoutHold'

for subjid in 'sub17'   #'sub11' 'sub12' 'sub13' 'sub14' 'sub15' 'sub16' 'sub17' 'sub18' 'sub20' 'sub21'   #'sub10', 'sub19'
do

    acq_file_dir=/Users/deanjn/Documents/NIH/burak_phys/physio_bids/physio_files/${subjid}/test/${fileOI}.acq
    bids_file_prefix2=physio_bids/physio_files/${subjid}/test/${subjid}_${fileOI}

    physio2bidsphysio --infile ${acq_file_dir} --bidsprefix ${bids_file_prefix2}

done

