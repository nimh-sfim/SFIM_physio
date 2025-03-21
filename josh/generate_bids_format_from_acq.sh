#!/bin/bash
# bash generate_bids_format_from_acq.sh

# Requires bidsphysio module. 
# NOTE: Upon initial download of bidsphysio, an error will be thrown when running script: AttributeError: 'NoneType' object has no attribute 'timestamp'
# I was only able to resolve this error upon editing the file in ~/bidsphysio/acq2bids/acq2bidsphysio.py
# At line 121, change physiostarttime.timestamp() to physiostarttime=0
# Since the phys data started upon the first trigger of the MRI scan, I believe this to be okay.
# Info about bidsphysio can be found here: https://github.com/cbinyu/bidsphysio/blob/master/bidsphysio.acq2bids/bidsphysio/acq2bids/acq2bidsphysio.py

fileOI='outhold'    #resting, inhold, outhold

# for resting, sub10 is resting1.acq --> sub10_resting.acq
# for resting, sub19 is KyleRest.acq --> sub19_resting.acq

# 'sub10' 'sub11' 'sub12' 'sub13' 'sub14' 'sub15' 'sub16' 'sub17' 'sub18' 'sub19' 'sub20' 'sub21' 'sub22' 'sub23' 'sub24' 'sub25'
for subjid in 'sub11' 'sub12' 'sub13' 'sub14' 'sub15' 'sub16' 'sub17' 'sub18' 'sub19' 'sub20' 'sub21' 'sub22' 'sub23' 'sub24' 'sub25' 'sub26' 'sub27' 'sub28' 'sub29' 'sub30' 'sub31' 'sub32' 'sub33' 'sub34'
do

    echo $subjid

    acq_file_dir=/data/SFIM_physio/physio/physio_files/${subjid}/${subjid}_${fileOI}.acq
    bids_file_prefix2=/data/SFIM_physio/physio/physio_files/${subjid}/${subjid}_${fileOI}

    physio2bidsphysio --infile ${acq_file_dir} --bidsprefix ${bids_file_prefix2}

done

