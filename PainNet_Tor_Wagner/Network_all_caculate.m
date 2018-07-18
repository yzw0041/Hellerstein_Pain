% This caculate the overlay between MVPA results and Pain network and other
% networks. 
cd('/Users/posnerlab/Dropbox (NYSPI)/Final_Summary/Github_Hellerstein/Othernetworks')

%Caculate cosine similarity between other networks and Pain signature 
A=apply_nps('/Users/posnerlab/Dropbox (NYSPI)/Final_Summary/Github_Hellerstein/Othernetworks/PNAS_Smith09_rsn10_thr23.nii.gz'); 

%Caculate cosine similarity between pain_nodes (5mm) and pain signature 
B=apply_nps('/Users/posnerlab/Dropbox (NYSPI)/Final_Summary/Github_Hellerstein/Pain_16_nodes/pain_16_5mm.nii'); 

% Caculate cosine similarity between MVPA pattern and pain signature 

C=apply_nps('/Users/posnerlab/Dropbox (NYSPI)/Final_Summary/Github_Hellerstein/PainNet_Tor_Wagner/fMVPA_mask.nii'); %this mask is group* time interaction MVPA result thresholded at p=0.005, cluster size 50
