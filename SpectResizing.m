
%% SPECT cropping and resizing
spectpath ='/Users/neuroimaging/Desktop/DATA/ASVD/Pt6/pt6_SPECT/HIR 14524/ICAD_UC007/study_20220315_0f141984e808c10c_UC-BRAIN/NM8_NM_-_Transaxials_AC_97c46a18/00001_077bbd7177b022b5.dcm';
spect = dicomread(spectpath);
spect_cropped = spect(30:end-30,30:end-30,49:100);
spect_cropped_resized = imresize3(spect_cropped,[128 128 52]);
pt6_spect = flip(imrotate(spect_cropped_resized,270),3);
niftiwrite(pt6_spect,'/Users/neuroimaging/Desktop/DATA/ASVD/Pt6/pt6_niftis/SPECT/pt6_spect.nii');

%% DSC cropping and resizing
load('/Users/neuroimaging/Desktop/DATA/ASVD/Pt6/pt6_DSC_sorted/Result_MSwcf2/P001GE_M.mat','images')
pt6_perf = imrotate(images{15},270);
niftiwrite(pt6_perf,'/Users/neuroimaging/Desktop/DATA/ASVD/Pt6/pt6_niftis/DSCPerf/pt6_dsc.nii');

