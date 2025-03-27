%group avg
%2 5 15 3 30 =55 x 10

clear;
bpath="/Users/akinb2/Desktop/allbp/";

cc=0;
 for zz=10:13
% zz=10
    cc=cc+1;
    
    fpath=strcat(bpath,'bp',num2str(zz,'%0.2d'));
    load(strcat(fpath,'/vitals.mat'));
    load(strcat(fpath,'/gmsig.mat'));
    
    
    map_in=interp1(linspace(0,1,length(MAPin)),MAPin,linspace(0,1,length(gm_in)))';
    map_out=interp1(linspace(0,1,length(MAPout)),MAPout,linspace(0,1,length(gm_out)))';
    map_rest=interp1(linspace(0,1,length(MAPrest)),MAPrest,linspace(0,1,length(gm_rest)))';
cval(cc,1)=corr(gm_in',map_in)
cval(cc,2)=corr(gm_out',map_out)
cval(cc,3)=corr(gm_rest',map_rest)
 end

[WCOH_in,WCS,PERIOD,COI] = wcoherence(gm_in',map_in);
[WCOH_out,WCS,PERIOD,COI] = wcoherence(gm_out',map_out);
[WCOH_rest,WCS,PERIOD,COI] = wcoherence(gm_rest',map_rest);


plot(mean(WCOH_in'))
hold on
plot(mean(WCOH_out'))
hold on
plot(mean(WCOH_rest'))

    clf
plot(normalize(gm_rest))
hold on
plot(normalize(map_rest))
%    vec(cc,:)= demean(mapin_fmri)/std(mapin_fmri);
%       vec(cc,:)= demean(mapout_fmri)/std(mapout_fmri);

      
%    vec(cc,:)= demean(hrin_fmri)/std(hrin_fmri);
% vec(cc,:)= demean(hrout_fmri)/std(hrout_fmri);
%end

