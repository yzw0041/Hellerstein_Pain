function [DiceCoef,Cosinesimilarity] = DiceSimilarity2DImage(image1)
%The steps are:
%1. set one image non-zero values as 200
C1=load_nii(image1);
M1=C1.img; 
C2=load_nii('/Users/posnerlab/Dropbox (NYSPI)/Final_Summary/Github_Hellerstein/PainNet_Tor_Wagner/rweights_NSF_positive_smoothed_larger_than_10vox.hdr'); %resliced image
M2=C2.img; 
img1=M1;
img2=M2;
img1(img1>0)=200;
img1=cast(img1,'single');
%2. set second image non-zero values as 300
img2(img2>0.0000000001)=300;

%3. set overlap area 100
OverlapImage = img2-img1;

%4. count the overlap100 pixels
[r,c,v] = find(OverlapImage==100);
countOverlap100=size(r);

%5. count the image200 pixels
[r1,c1,v1] = find(img1==200);
img1_200=size(r1);

%6. count the image300 pixels
[r2,c2,v2] = find(img2==300);
img2_300=size(r2);

%7. calculate Dice Coef
DiceCoef = 2*countOverlap100/(img1_200+img2_300);


% caculate cosine similarity between F test and NSP positive images; 


% caculate cosine similarity between F test and NSP positive images; 
Cosinesimilarity=apply_nps(image1); 




