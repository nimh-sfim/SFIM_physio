ustr=load_untouch_nii('MNIreg.nii');
ostr=load_untouch_nii('Spress_wave_br.nii');


slices=[30:6:75];%adjust for spatial coverage.
under=row_nii(ustr.img,slices)';
imagesc(under); colormap gray

finim=[];
for vol=1:8:110%adjust for time
over=row_nii(squeeze(ostr.img(:,:,:,vol)),slices)';
minval=-0.5;valn=0;
valp=0;maxval=0.5; clustn=0;clustp=0;
currim=overlay_nii(under,over,minval,valn,valp,maxval,clustn,clustp);
finim=cat(1,finim,currim);
end
image(finim);

timegrid=linspace(-10,30,266);
timevals=timegrid(1:8:110)