%% Load anatomical MNI
upath='/data/SFIM_physio/scripts/burak/MNIreg.nii';  %path of MNI matches to our group results
uim=load_untouch_nii(upath);
slices=[48 48 58]; %sag cor ax
usag=row_nii(uim.img,slices(1),1)';     %sagittal view
ucor=row_nii(uim.img,slices(2),2)';     %coronal view
uax=row_nii(uim.img,slices(3),3)';      %axial view

under=cat(2,cat(1,zeros([9 114]),usag,zeros([9 114])),cat(1,zeros([9 96]), ucor,zeros([9 96])),... 
    uax); %pad and concat; generates underlying sag, cor, and axial view within one image

%% Load the delay map of interest
oim=load_untouch_nii('avgDelay.nii');


for vol=1:266;
    vol
cvol=squeeze(oim.img(:,:,:,vol));
osag=row_nii(cvol,slices(1),1)';
ocor=row_nii(cvol,slices(2),2)';
oax=row_nii(cvol,slices(3),3)';

over=cat(2,cat(1,zeros([9 114]),osag,zeros([9 114])),cat(1,zeros([9 96]),ocor,zeros([9 96])),oax); %pad and concat
over=mask_nii(under,over); %mask overlay based on underlay(anatomical)

minval=-0.5;maxval=0.5; % lower and upper range
valn=0; valp=0;% zero means no negative threshold
clustn=0;clustp=0; %cluster threshold;
finalim=overlay_nii(under,over,minval,valn,valp,maxval,clustn,clustp);

tspace=linspace(-10,30,266);
clf
image(finalim);
axis off;
set(gcf, 'color', 'none');
text(12,12,strcat(num2str(tspace(vol)),' sec'),'Color',[1 0 1],'FontWeight','bold','FontSize',15);
% saveas(gcf,strcat('./outfig/lfovol_',num2str(vol,'%0.3d'),'.jpg'))
saveas(gcf,strcat('./outfig/lfovol_',num2str(vol,'%0.3d'),'.jpg'))

end