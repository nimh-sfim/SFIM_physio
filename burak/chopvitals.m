load BinHold_phys.mat

scandur=duration(0,0,600);
scan_stop=scan_start+scandur;
fileList = dir(fullfile(pwd, '*_vitals*.csv'));
v=readtable(fileList.name);

tarray=table2array(v(:,2));

dump=datevec(scan_start-tarray);
vals=dump(:,4:6);
[aa,bb]=min(sum(vals'));

dump2=datevec(scan_stop-tarray);
vals2=dump2(:,4:6);
[aa2,bb2]=min(sum(vals2'));
in_index=bb:bb2;
MAPin=table2array(v(in_index,3));
HRin=table2array(v(in_index,4));



