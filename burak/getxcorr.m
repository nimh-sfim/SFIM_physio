clear;%by using rigidbody
addpath(genpath('/data/SFIM/akin/bin/burak'));
addpath(genpath('/data/SFIM/akin/bin/NIfTI_20140122'));
basepath=['/data/akinb2/allbp/'];
fname='Rest_mcf.nii';
pname='parcRest.nii';

% fname='BinH_mcf.nii';
% pname='parcBinH.nii'

% fname='BouH_mcf.nii';
% pname='parcBouH.nii'

cc=0;gm=[];
for vv=10:18
cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',fname);
parcname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/',pname);
[tcs,ov]=get_labeled_tc(fullname,parcname);
inds=isnan(sum(ov'));
ov(inds==1,:)=[];
gm(cc,:)=sum(ov(:,1:800));
end

gm(8,:)=[];

cc=0; clear mapmat
for vv=10:13
    cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/','vitalsnew.mat');
load(fullname);
    % mapmat(cc,:)=maprest_fmri(1:800);
    % mapmat(cc,:)=mapin_fmri(1:800);
    mapmat(cc,:)=mapout_fmri(1:800);

    
end
    
     % for vv=[14 15 16  18 19 20 21];
              for vv=[14 15 16 18 ];

cc=cc+1;
fullname=strcat(basepath,'bp',num2str(vv,'%.02d'),'/','vitals.mat');
load(fullname);
% mapmat(cc,:)=maprest_fmri(1:800);
% mapmat(cc,:)=mapin_fmri(1:800);
mapmat(cc,:)=mapout_fmri(1:800);


              end



     for zz=1:8
         [sc(:,zz),~]=brk_shift_corr(mapmat(zz,:),gm(zz,:),20);
     end

figure;
hold on;
x=linspace(-15,15,41);
y=mean(sc');
n=8;
std_err = std(sc, 0, 2) ./ (2*sqrt(n)); % Standard error of the mean (SEM)

    % t-score for confidence level
    confidence=0.95;
    alpha = 1 - confidence;
    t_score = tinv(1 - alpha/2, n - 1); 

    % Confidence interval bounds
    margin = t_score .* std_err;
    lower_CI = y - margin;
    upper_CI = y + margin;

clf ;hold on;
fill([x, fliplr(x)], [lower_CI, fliplr(upper_CI)], [0.7, 0.7, 0.7], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); % Shaded CI
plot(x, y, 'b', 'LineWidth', 2); % Main curve


     plot(,mean(sc'))