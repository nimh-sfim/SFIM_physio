bpath='/vf/users/SFIM_physio/data/derivatives/';
bpath2='/vf/users/SFIM_physio/physio/physio_results/'
cc=0
for sid=[12:21];
    cc=cc+1;
fpath=strcat(bpath,'sub',num2str(sid),'/ponsica/melodic_Tmodes');
tmodes=table2array(readtable(fpath));
fpath2=strcat(bpath2,'sub',num2str(sid),'/sub',num2str(sid),'_resting_card_lfo.txt');
lfo=table2array(readtable(fpath2));

[aa,bb]=max(abs(corr(tmodes,lfo)));%get the max corr
if corr(tmodes(:,bb),lfo)<0 
    comptc=-1*tmodes(:,bb);% flip comptc
end
if corr(tmodes(:,bb),lfo)>0
    comptc=tmodes(:,bb); % take it as is
end
lfmat{cc}=lfo;
compmat{cc}=comptc;
end

bpath3='/vf/users/SFIM_physio/data/'
cc=0;outim=zeros([96 114 96]);
for sid=[12:21];
    cc=cc+1
fpath=strcat(bpath3,'bp',num2str(sid),'/func_rest/pb04.bp',num2str(sid),'.r01.scale.nii');
imo=connii2(fpath,cell2mat(compmat(cc)));
imaj=imo.img;
imaj(isnan(imaj))=0;
outim=outim+imaj;
end
imo.img=outim/10;
save_untouch_nii(imo,'avgpons_corr')
