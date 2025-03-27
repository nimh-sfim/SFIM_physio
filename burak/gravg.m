%group avg
%2 5 15 3 30 =55 x 10

clear;
bpath="/Users/akinb2/Desktop/allbp/";

cc=0;
for zz=10:13
    cc=cc+1;
    
    fpath=strcat(bpath,'bp',num2str(zz,'%0.2d'));
    load(strcat(fpath,'/vitals.mat'));
    load(strcat(fpath,'/gmsig.mat'));
    
%    vec(cc,:)= demean(mapin_fmri)/std(mapin_fmri);
%       vec(cc,:)= 100*demean(mapin_fmri)/mean(mapin_fmri);
            vec(cc,:)= demean(mapin_fmri);


   
   gmin_fmri=interp1(linspace(0,1,length(gm_in)),gm_in,linspace(0,1,length(mapin_fmri)));
%    vec2(cc,:)=demean(gmin_fmri)/std(gmin_fmri);
      vec2(cc,:)=100*demean(gmin_fmri)/mean(gmin_fmri);

%       vec(cc,:)= demean(mapout_fmri)/std(mapout_fmri);

      
%    vec(cc,:)= demean(hrin_fmri)/std(hrin_fmri);
% vec(cc,:)= demean(hrout_fmri)/std(hrout_fmri);

end



indstart=[1:5500:50000];
indstop=[5500:5500:55000];
vol=60000;
omat=zeros([4 5500]);
for kk=1:4
currvox=vec(kk,:);
curravg=zeros([1 5500]);
for jj=1:10
    curravg=curravg+currvox(indstart(jj):indstop(jj));
end
omat(kk,:)=curravg/10;
kk
end


indstart=[1:5500:50000];
indstop=[5500:5500:55000];
vol=60000;
omat2=zeros([4 5500]);
for kk=1:4
currvox=vec2(kk,:);
curravg=zeros([1 5500]);
for jj=1:10
    curravg=curravg+currvox(indstart(jj):indstop(jj));
end
omat2(kk,:)=curravg/10;
kk
end


% sub=4;
% clf
% plot(omat(sub,:))
% hold on
% plot(omat2(sub,:))

mapinresponse=omat;
gminresponse=omat2;